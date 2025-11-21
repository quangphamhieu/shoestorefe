using Microsoft.EntityFrameworkCore;
using ShoeStore.Domain.Entities;
using ShoeStore.Infrastructure.Persistence;

public class DashboardService : IDashboardService
{
    private readonly ShoeStoreDbContext _context;

    public DashboardService(ShoeStoreDbContext context)
    {
        _context = context;
    }

    public async Task<DashboardDto> GetDashboardAsync(DashboardFilterDto filter)
    {
        // Filter Receipts & Orders trước khi Include
        var receiptsQuery = _context.Receipts.AsQueryable();
        var ordersQuery = _context.Orders.AsQueryable();

        if (filter.StoreId.HasValue)
        {
            receiptsQuery = receiptsQuery.Where(r => r.StoreId == filter.StoreId.Value);
            ordersQuery = ordersQuery.Where(o => o.StoreId == filter.StoreId.Value);
        }

        if (filter.FromDate.HasValue)
        {
            receiptsQuery = receiptsQuery.Where(r => r.CreatedAt >= filter.FromDate.Value);
            ordersQuery = ordersQuery.Where(o => o.CreatedAt >= filter.FromDate.Value);
        }

        if (filter.ToDate.HasValue)
        {
            receiptsQuery = receiptsQuery.Where(r => r.CreatedAt <= filter.ToDate.Value);
            ordersQuery = ordersQuery.Where(o => o.CreatedAt <= filter.ToDate.Value);
        }

        // Include ReceiptDetails -> Product
        var receipts = await receiptsQuery
            .Include(r => r.ReceiptDetails!)
                .ThenInclude(rd => rd.Product!)
            .ToListAsync();

        // Include OrderDetails -> Product, loại bỏ Cancelled
        var orders = await ordersQuery
            .Where(o => o.StatusId != 6)
            .Include(o => o.OrderDetails!)
                .ThenInclude(od => od.Product!)
            .ToListAsync();

        // Tổng chi phí nhập hàng (dựa trên số lượng nhận thực tế)
        var totalReceiptCost = receipts.Sum(r => (r.ReceiptDetails ?? Enumerable.Empty<ReceiptDetail>())
            .Sum(rd => (rd.ReceivedQuantity ?? 0) * (rd.UnitPrice)));

        // Tổng doanh thu
        var totalRevenue = orders.Sum(o => (o.OrderDetails ?? Enumerable.Empty<OrderDetail>())
            .Sum(od => od.Quantity * od.UnitPrice));

        // Lợi nhuận = doanh thu - chi phí tương ứng số lượng bán
        var totalCostOfSold = orders.Sum(o => (o.OrderDetails ?? Enumerable.Empty<OrderDetail>())
            .Sum(od => od.Quantity * (od.Product?.CostPrice ?? 0)));
        var totalProfit = totalRevenue - totalCostOfSold;

        // Thống kê đơn
        var totalOrders = orders.Count;
        var onlineOrders = orders.Count(o => o.OrderType == OrderType.Online);
        var offlineOrders = orders.Count(o => o.OrderType == OrderType.Offline);

        // Số đơn bị hủy
        var cancelledOrders = await _context.Orders.CountAsync(o =>
            o.StatusId == 6 &&
            (!filter.StoreId.HasValue || o.StoreId == filter.StoreId.Value) &&
            (!filter.FromDate.HasValue || o.CreatedAt >= filter.FromDate.Value) &&
            (!filter.ToDate.HasValue || o.CreatedAt <= filter.ToDate.Value)
        );

        var summary = new DashboardSummaryDto
        {
            TotalReceiptCost = totalReceiptCost,
            TotalRevenue = totalRevenue,
            TotalProfit = totalProfit,
            TotalOrders = totalOrders,
            OnlineOrders = onlineOrders,
            OfflineOrders = offlineOrders,
            CancelledOrders = cancelledOrders
        };

        // Thống kê sản phẩm
        var productStats = orders
            .SelectMany(o => o.OrderDetails ?? Enumerable.Empty<OrderDetail>())
            .Where(od => od.Product != null)
            .GroupBy(od => od.ProductId)
            .Select(g => new ProductStatsDto
            {
                ProductName = g.First().Product!.Name,
                QuantitySold = g.Sum(x => x.Quantity),
                Revenue = g.Sum(x => x.Quantity * x.UnitPrice)
            })
            .ToList();

        var topProducts = productStats.OrderByDescending(x => x.QuantitySold).Take(5).ToList();
        var leastProducts = productStats.OrderBy(x => x.QuantitySold).Take(5).ToList();

        return new DashboardDto
        {
            Summary = summary,
            TopSellingProducts = topProducts,
            LeastSellingProducts = leastProducts
        };
    }
}
