using System.Collections.Generic;

namespace ShoeStore.Application.Dtos.Dashboard
{
    public class DashboardResponseDto
    {
        public List<TopProductDto> TopProducts { get; set; } = new();
        public ProfitSummaryDto ProfitSummary { get; set; } = new();
        public List<MonthlyProfitDto> MonthlyProfits { get; set; } = new();
        public List<BrandSalesDto> TopBrands { get; set; } = new();
        public GrowthOverviewDto ProfitGrowth { get; set; } = new();
    }

    public class TopProductDto
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string? SKU { get; set; }
        public int QuantitySold { get; set; }
        public decimal Revenue { get; set; }
    }

    public class ProfitSummaryDto
    {
        public decimal Revenue { get; set; }
        public decimal Cost { get; set; }
        public decimal Profit { get; set; }
    }

    public class MonthlyProfitDto
    {
        public int Year { get; set; }
        public int Month { get; set; }
        public decimal Revenue { get; set; }
        public decimal Cost { get; set; }
        public decimal Profit { get; set; }
    }

    public class BrandSalesDto
    {
        public int? BrandId { get; set; }
        public string BrandName { get; set; } = string.Empty;
        public int QuantitySold { get; set; }
        public decimal Revenue { get; set; }
    }

    public class GrowthOverviewDto
    {
        public decimal CurrentMonthProfit { get; set; }
        public decimal PreviousMonthProfit { get; set; }
        public decimal GrowthPercentage { get; set; }
    }
}

