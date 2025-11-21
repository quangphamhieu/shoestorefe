public class DashboardFilterDto
{
    public int? StoreId { get; set; }
    public DateTime? FromDate { get; set; }
    public DateTime? ToDate { get; set; }
}

public class DashboardSummaryDto
{
    public decimal TotalReceiptCost { get; set; } // tổng tiền nhập hàng
    public decimal TotalRevenue { get; set; }     // doanh thu
    public decimal TotalProfit { get; set; }      // lợi nhuận
    public int TotalOrders { get; set; }
    public int OnlineOrders { get; set; }
    public int OfflineOrders { get; set; }
    public int CancelledOrders { get; set; }
}

public class ProductStatsDto
{
    public string ProductName { get; set; } = string.Empty;
    public int QuantitySold { get; set; }
    public decimal Revenue { get; set; }
}

public class DashboardDto
{
    public DashboardSummaryDto Summary { get; set; } = new DashboardSummaryDto();
    public IEnumerable<ProductStatsDto> TopSellingProducts { get; set; } = new List<ProductStatsDto>();
    public IEnumerable<ProductStatsDto> LeastSellingProducts { get; set; } = new List<ProductStatsDto>();
}
