using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using ShoeStore.Application.Dtos.Order;
using ShoeStore.Application.Interfaces.Services;
using ShoeStore.Domain.Entities;
using ShoeStore.Infrastructure.Persistence;

using Microsoft.Extensions.Logging;

namespace ShoeStore.Infrastructure.Services
{
    public class OrderService : IOrderService
    {
        private readonly ShoeStoreDbContext _context;
        private readonly IMapper _mapper;
        private readonly ILogger<OrderService> _logger;
        private const int WarehouseStoreId = 1;
        private const int StatusPaymentSuccess = 3;       // Đã thanh toán
        private const int StatusPendingConfirmation = 4;  // Đang giao / chờ xác nhận
        private const int StatusCompleted = 5;            // Hoàn tất
        private const int StatusCancelled = 6;            // Hủy

        public OrderService(ShoeStoreDbContext context, IMapper mapper, ILogger<OrderService> logger)
        {
            _context = context;
            _mapper = mapper;
            _logger = logger;
        }

        // ================= CREATE ORDER =================
        public async Task<OrderResponseDto> CreateOrderAsync(OrderCreateDto dto, long userId)
        {
            _logger.LogInformation("CreateOrderAsync started: Type={OrderType}, Customer={CustomerId}, Store={StoreId}", dto.OrderType, dto.CustomerId, dto.StoreId);

            ArgumentNullException.ThrowIfNull(dto);
            ValidateOrderDetails(dto);

            var isOffline = dto.OrderType == OrderType.Offline;
            var isOnline = dto.OrderType == OrderType.Online;

            if (!isOffline && !isOnline)
                throw new ValidationException("Invalid order type.");

            if (isOffline && !dto.StoreId.HasValue)
                throw new ValidationException("Offline orders require a store id.");

            if (isOnline && dto.StoreId.HasValue && dto.StoreId.Value != WarehouseStoreId)
                throw new ValidationException("Online orders must target the warehouse store.");

            if (isOnline && string.IsNullOrWhiteSpace(dto.Address))
                throw new ValidationException("Online orders require delivery address.");

            if (isOffline && string.IsNullOrWhiteSpace(dto.Address))
                throw new ValidationException("Offline orders require store address.");

            var customerExists = await _context.Users.AsNoTracking().AnyAsync(u => u.Id == dto.CustomerId);
            if (!customerExists)
                throw new ArgumentException("Customer does not exist.", nameof(dto.CustomerId));

            var storeId = isOffline ? dto.StoreId!.Value : WarehouseStoreId;

            if (isOffline)
            {
                var storeExists = await _context.Stores.AsNoTracking().AnyAsync(s => s.Id == storeId);
                if (!storeExists)
                    throw new ArgumentException("Store does not exist.", nameof(dto.StoreId));
            }

            var distinctProductIds = dto.Details.Select(i => i.ProductId).Distinct().ToList();
            if (distinctProductIds.Count != dto.Details.Count)
                throw new InvalidOperationException("Order contains duplicated products. Please consolidate quantities.");

            var products = await _context.Products
                .Where(p => distinctProductIds.Contains(p.Id))
                .ToDictionaryAsync(p => p.Id);

            if (products.Count != distinctProductIds.Count)
                throw new InvalidOperationException("One or more products do not exist.");

            var storeProducts = await _context.StoreProducts
                .Where(sp => sp.StoreId == storeId && distinctProductIds.Contains(sp.ProductId))
                .ToDictionaryAsync(sp => sp.ProductId);

            var orderDetails = new List<OrderDetail>();
            decimal totalAmount = 0m;

            await using var transaction = await _context.Database.BeginTransactionAsync();

            try {
                foreach (var item in dto.Details)
                {
                    if (!storeProducts.TryGetValue(item.ProductId, out var storeProduct))
                        throw new InvalidOperationException($"Product '{products[item.ProductId].Name}' is not available in the selected store.");

                    EnsureDetailQuantity(item.Quantity);

                    // Inventory check
                    if (storeProduct.Quantity < item.Quantity)
                    {
                        _logger.LogError("Out of stock: Product {ProductId} has {Qty} but requested {Req}", item.ProductId, storeProduct.Quantity, item.Quantity);
                        throw new InvalidOperationException($"Product '{products[item.ProductId].Name}' only has {storeProduct.Quantity} unit(s) left.");
                    }

                    // ALWAYS deduct inventory immediately (Online needs to reserve stock)
                    // User requested explicit check
                    if (isOffline || isOnline)
                    {
                        var oldQty = storeProduct.Quantity;
                        storeProduct.Quantity -= item.Quantity;
                        _logger.LogInformation("Deducted stock for Product {ProductId}: {Old} -> {New} (Store {StoreId})", item.ProductId, oldQty, storeProduct.Quantity, storeId);
                    }

                    var detail = new OrderDetail
                    {
                        ProductId = item.ProductId,
                        Quantity = item.Quantity,
                        UnitPrice = storeProduct.SalePrice
                    };

                    orderDetails.Add(detail);
                    totalAmount += detail.UnitPrice * detail.Quantity;
                }

                var order = new Order
                {
                    OrderNumber = $"OD-{DateTime.UtcNow:yyyyMMddHHmmssfff}",
                    CustomerId = dto.CustomerId,
                    CreatedBy = userId,
                    StoreId = storeId,
                    OrderType = dto.OrderType,
                    PaymentMethod = dto.PaymentMethod,
                    StatusId = isOffline ? StatusPaymentSuccess : StatusPendingConfirmation,
                    TotalAmount = totalAmount,
                    CreatedAt = DateTime.UtcNow,
                    Address = dto.Address,
                    Note = dto.Note,
                    OrderDetails = orderDetails
                };

                await _context.Orders.AddAsync(order);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                _logger.LogInformation("CreateOrderAsync success: OrderId={OrderId}, Status={Status}", order.Id, order.StatusId);

                return await GetOrderByIdAsync(order.Id) ?? throw new InvalidOperationException("Failed to load the created order.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "CreateOrderAsync failed");
                throw;
            }
        }

        // ================= GET ORDER BY ID =================
        public async Task<OrderResponseDto?> GetOrderByIdAsync(long id)
        {
            var order = await _context.Orders
                .AsNoTracking()
                .Include(x => x.Customer)
                .Include(x => x.Creator)
                .Include(x => x.Status)
                .Include(x => x.OrderDetails)!.ThenInclude(d => d.Product)
                .FirstOrDefaultAsync(x => x.Id == id);

            return order == null ? null : _mapper.Map<OrderResponseDto>(order);
        }

        // ================= GET ALL ORDERS =================
        public async Task<IEnumerable<OrderResponseDto>> GetAllOrdersAsync()
        {
            var orders = await _context.Orders
                .AsNoTracking()
                .Include(o => o.Customer)
                .Include(o => o.Creator)
                .Include(o => o.Status)
                .Include(o => o.OrderDetails).ThenInclude(d => d.Product)
                .OrderByDescending(o => o.Id)
                .ToListAsync();

            return _mapper.Map<IEnumerable<OrderResponseDto>>(orders);
        }

        // ================= GET ORDERS BY USER =================
        public async Task<IEnumerable<OrderResponseDto>> GetOrderByUserAsync(long userId)
        {
            var orders = await _context.Orders
                .AsNoTracking()
                .Include(o => o.Customer)
                .Include(o => o.Creator)
                .Include(o => o.Status)
                .Include(o => o.OrderDetails).ThenInclude(d => d.Product)
                .Where(o => o.CustomerId == userId)
                .OrderByDescending(o => o.Id)
                .ToListAsync();

            return _mapper.Map<IEnumerable<OrderResponseDto>>(orders);
        }

        // ================= UPDATE ORDER DETAIL (quantity only) =================
        // Only allowed when order is in PENDING_CONFIRMATION (statusId == 4)
        public async Task<bool> UpdateOrderDetailAsync(OrderDetailUpdateDto dto)
        {
            ArgumentNullException.ThrowIfNull(dto);
            EnsureDetailQuantity(dto.Quantity);

            var detail = await _context.OrderDetails
                .Include(d => d.Order)
                .FirstOrDefaultAsync(d => d.Id == dto.OrderDetailId);

            if (detail == null) return false;

            var order = detail.Order ?? throw new InvalidOperationException("Order does not exist.");

            if (order.StatusId != StatusPendingConfirmation)
                throw new InvalidOperationException("Only orders pending confirmation can be edited.");

            var storeId = order.StoreId ?? WarehouseStoreId;

            if (dto.Quantity != detail.Quantity)
            {
                var storeProduct = await _context.StoreProducts
                    .FirstOrDefaultAsync(sp => sp.StoreId == storeId && sp.ProductId == detail.ProductId)
                    ?? throw new InvalidOperationException("Inventory record not found for this product.");

                var delta = dto.Quantity - detail.Quantity;

                if (delta > 0 && storeProduct.Quantity < delta)
                    throw new InvalidOperationException($"Only {storeProduct.Quantity} unit(s) are available for this product.");

                storeProduct.Quantity -= delta;
            }

            detail.Quantity = dto.Quantity;

            await RecalculateOrderTotalAsync(order.Id);
            await _context.SaveChangesAsync();
            return true;
        }

        // ================= DELETE ORDER DETAIL =================
        // Only allowed when order is pending (statusId == 4)
        public async Task<bool> DeleteOrderDetailAsync(long orderDetailId)
        {
            var detail = await _context.OrderDetails
                .Include(d => d.Order)
                .FirstOrDefaultAsync(d => d.Id == orderDetailId);

            if (detail == null) return false;

            var order = detail.Order ?? throw new InvalidOperationException("Order does not exist.");

            if (order.StatusId != StatusPendingConfirmation)
                throw new InvalidOperationException("Only orders pending confirmation can be updated.");

            var storeId = order.StoreId ?? WarehouseStoreId;
            var storeProduct = await _context.StoreProducts
                .FirstOrDefaultAsync(sp => sp.StoreId == storeId && sp.ProductId == detail.ProductId);

            if (storeProduct != null)
                storeProduct.Quantity += detail.Quantity;

            _context.OrderDetails.Remove(detail);

            await RecalculateOrderTotalAsync(order.Id);

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UpdateOrderStatusAsync(OrderStatusUpdateDto dto)
        {
            _logger.LogInformation("UpdateOrderStatusAsync: Order={OrderId}, NewStatus={Status}", dto.OrderId, dto.StatusId);
            ArgumentNullException.ThrowIfNull(dto);

            var statusExists = await _context.Statuses.AsNoTracking().AnyAsync(s => s.Id == dto.StatusId);
            if (!statusExists)
                throw new ArgumentException("Status does not exist.", nameof(dto.StatusId));

            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                .Include(o => o.OrderDetails)!.ThenInclude(d => d.Product)
                .FirstOrDefaultAsync(o => o.Id == dto.OrderId);

            if (order == null) return false;

            if (order.OrderDetails == null || !order.OrderDetails.Any())
                throw new InvalidOperationException("Order has no items.");

            var current = order.StatusId;
            var next = dto.StatusId;
            _logger.LogInformation("Transition: {Current} -> {Next}", current, next);

            if (current == next)
            {
                order.Note = dto.Note ?? order.Note;
                await _context.SaveChangesAsync();
                return true;
            }

            // Allowed transitions logic:
            // 3: Paid, 4: Pending, 5: Completed, 6: Cancelled
            // 3 -> 4 (Allowed by user req? "from 3 to 4 then to 5"? User said "from 3 to 4 is from 3 to 5". Wait. 
            // User said: "from 4 to 3... from 3 to 5". "from 3 4 5 to 6". "from 6 to 3 and 5". "from 6 to 4".
            // 3 -> 4 might not be common if 3 is Paid and 4 is Pending. Usually 4->3. 
            // Let's stick strictly to user's graph: 
            // 4 -> 3
            // 3 -> 5
            // 3 -> 6, 4 -> 6, 5 -> 6
            // 6 -> 3, 6 -> 4, 6 -> 5
            
            bool allowed = (current == StatusPendingConfirmation && next == StatusPaymentSuccess) // 4 -> 3
                           || (current == StatusPaymentSuccess && next == StatusCompleted)        // 3 -> 5
                           || (next == StatusCancelled)                                           // Any -> 6
                           || (current == StatusCancelled && (next == StatusPaymentSuccess || next == StatusPendingConfirmation || next == StatusCompleted)); // 6 -> 3/4/5

            if (!allowed)
            {
                _logger.LogWarning("Invalid transition attempted: {Current} -> {Next}", current, next);
                throw new InvalidOperationException($"Transition {current} -> {next} is not allowed.");
            }

            await using var transaction = await _context.Database.BeginTransactionAsync();

            var storeId = order.StoreId ?? WarehouseStoreId;
            var storeProducts = await LoadStoreProductsAsync(order.OrderDetails, storeId);

            // Inventory adjustments
            
            // Deduct: 6 -> 3, 6 -> 4, 6 -> 5
            // Note: 4 -> 3 does NOT deduct anymore (already deducted at creation)
            if (current == StatusCancelled && (next == StatusPaymentSuccess || next == StatusPendingConfirmation || next == StatusCompleted))
            {
                _logger.LogInformation("Restocking from Cancelled state.");
                foreach (var detail in order.OrderDetails)
                {
                    if (storeProducts.TryGetValue(detail.ProductId, out var sp))
                    {
                        if (sp.Quantity < detail.Quantity)
                            throw new InvalidOperationException($"Product {sp.ProductId} out of stock for transition.");
                        sp.Quantity -= detail.Quantity;
                    }
                }
            }
            else 
            {
                 _logger.LogInformation("No stock deduction for this transition (already deducted or not applicable).");
            }

            // Restore: 3 -> 6, 4 -> 6, 5 -> 6
            // All statuses (3/4/5) have inventory deducted at creation, so all must restore when cancelled
            if ((current == StatusPaymentSuccess || current == StatusPendingConfirmation || current == StatusCompleted) && next == StatusCancelled)
            {
                _logger.LogInformation("Restoring stock (Paid/Pending/Completed -> Cancelled).");
                foreach (var detail in order.OrderDetails)
                {
                    if (storeProducts.TryGetValue(detail.ProductId, out var sp))
                        sp.Quantity += detail.Quantity;
                }
            }

            order.StatusId = next;
            order.UpdatedAt = DateTime.UtcNow;
            order.Note = dto.Note ?? order.Note;

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();
            return true;
        }

        // ================= HELPER: recalc total from order details =================
        private async Task RecalculateOrderTotalAsync(long orderId)
        {
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                .FirstOrDefaultAsync(o => o.Id == orderId);

            if (order == null) throw new InvalidOperationException("Order does not exist.");

            order.TotalAmount = order.OrderDetails?.Sum(d => d.UnitPrice * d.Quantity) ?? 0m;
            order.UpdatedAt = DateTime.UtcNow;
        }

        private async Task<Dictionary<int, StoreProduct>> LoadStoreProductsAsync(IEnumerable<OrderDetail> details, int storeId)
        {
            var detailList = details?.ToList() ?? new List<OrderDetail>();
            if (!detailList.Any())
                return new Dictionary<int, StoreProduct>();

            var productIds = detailList.Select(d => d.ProductId).Distinct().ToList();
            return await _context.StoreProducts
                .Where(sp => sp.StoreId == storeId && productIds.Contains(sp.ProductId))
                .ToDictionaryAsync(sp => sp.ProductId);
        }

        private static void ValidateOrderDetails(OrderCreateDto dto)
        {
            if (dto.Details == null || !dto.Details.Any())
                throw new ValidationException("Order must contain at least one product.");

            foreach (var detail in dto.Details)
            {
                EnsureDetailQuantity(detail.Quantity);
            }
        }

        private static void EnsureDetailQuantity(int quantity)
        {
            if (quantity <= 0)
                throw new ValidationException("Quantity must be greater than zero.");
        }

        public async Task<bool> UpdateOrderInfoAsync(OrderInfoUpdateDto dto)
        {
            var order = await _context.Orders.FirstOrDefaultAsync(o => o.Id == dto.OrderId);
            if (order == null) return false;

            order.Note = dto.Note;
            order.Address = dto.Address;
            order.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return true;
        }

    }
}
