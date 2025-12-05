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

namespace ShoeStore.Infrastructure.Services
{
    public class OrderService : IOrderService
    {
        private readonly ShoeStoreDbContext _context;
        private readonly IMapper _mapper;
        private const int WarehouseStoreId = 1;
        private const int StatusPaymentSuccess = 3;
        private const int StatusPendingConfirmation = 4;
        private const int StatusCancelled = 6;

        public OrderService(ShoeStoreDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // ================= CREATE ORDER =================
        public async Task<OrderResponseDto> CreateOrderAsync(OrderCreateDto dto, long userId)
        {
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

            foreach (var item in dto.Details)
            {
                if (!storeProducts.TryGetValue(item.ProductId, out var storeProduct))
                    throw new InvalidOperationException($"Product '{products[item.ProductId].Name}' is not available in the selected store.");

                EnsureDetailQuantity(item.Quantity);

                if (storeProduct.Quantity < item.Quantity)
                    throw new InvalidOperationException($"Product '{products[item.ProductId].Name}' only has {storeProduct.Quantity} unit(s) left.");

                storeProduct.Quantity -= item.Quantity;

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
                OrderDetails = orderDetails
            };

            await _context.Orders.AddAsync(order);
            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            return await GetOrderByIdAsync(order.Id) ?? throw new InvalidOperationException("Failed to load the created order.");
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
            ArgumentNullException.ThrowIfNull(dto);

            var statusExists = await _context.Statuses.AsNoTracking().AnyAsync(s => s.Id == dto.StatusId);
            if (!statusExists)
                throw new ArgumentException("Status does not exist.", nameof(dto.StatusId));

            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                .FirstOrDefaultAsync(o => o.Id == dto.OrderId);

            if (order == null) return false;

            if (order.OrderDetails == null || !order.OrderDetails.Any())
                throw new InvalidOperationException("Order has no items.");

            if (order.StatusId == dto.StatusId)
                return true;

            await using var transaction = await _context.Database.BeginTransactionAsync();

            if (dto.StatusId == StatusCancelled && order.StatusId != StatusCancelled)
            {
                var storeId = order.StoreId ?? WarehouseStoreId;
                var storeProducts = await LoadStoreProductsAsync(order.OrderDetails, storeId);

                foreach (var detail in order.OrderDetails)
                {
                    if (storeProducts.TryGetValue(detail.ProductId, out var sp))
                        sp.Quantity += detail.Quantity;
                }
            }

            order.StatusId = dto.StatusId;
            order.UpdatedAt = DateTime.UtcNow;

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

    }
}
