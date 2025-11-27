using Microsoft.EntityFrameworkCore;
using ShoeStore.Application.Dtos.Dashboard;
using ShoeStore.Application.Interfaces.Services;
using ShoeStore.Infrastructure.Persistence;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ShoeStore.Infrastructure.Services
{
    public class DashboardService : IDashboardService
    {
        private readonly ShoeStoreDbContext _context;
        private static readonly int[] CompletedStatuses = { 3, 5 };

        public DashboardService(ShoeStoreDbContext context)
        {
            _context = context;
        }

        public async Task<DashboardResponseDto> GetOverviewAsync(int? storeId, int monthCount = 6)
        {
            if (monthCount <= 0)
                monthCount = 6;

            var detailQuery = _context.OrderDetails
                .AsNoTracking()
                .Where(d => CompletedStatuses.Contains(d.Order.StatusId));

            if (storeId.HasValue)
            {
                detailQuery = detailQuery.Where(d => d.Order.StoreId == storeId.Value);
            }

            var topProducts = await detailQuery
                .GroupBy(d => new { d.ProductId, d.Product.Name, d.Product.SKU })
                .Select(g => new TopProductDto
                {
                    ProductId = g.Key.ProductId,
                    ProductName = g.Key.Name,
                    SKU = g.Key.SKU,
                    QuantitySold = g.Sum(x => x.Quantity),
                    Revenue = g.Sum(x => x.UnitPrice * x.Quantity)
                })
                .OrderByDescending(x => x.QuantitySold)
                .ThenByDescending(x => x.Revenue)
                .Take(5)
                .ToListAsync();

            var profitSummary = await detailQuery
                .GroupBy(_ => 1)
                .Select(g => new ProfitSummaryDto
                {
                    Revenue = g.Sum(x => x.UnitPrice * x.Quantity),
                    Cost = g.Sum(x => x.Product.CostPrice * x.Quantity),
                    Profit = g.Sum(x => (x.UnitPrice - x.Product.CostPrice) * x.Quantity)
                })
                .FirstOrDefaultAsync() ?? new ProfitSummaryDto();

            var now = DateTime.UtcNow;
            var startMonth = new DateTime(now.Year, now.Month, 1).AddMonths(-(monthCount - 1));

            var monthlyProfits = await detailQuery
                .Where(d => d.Order.CreatedAt >= startMonth)
                .GroupBy(d => new { d.Order.CreatedAt.Year, d.Order.CreatedAt.Month })
                .Select(g => new MonthlyProfitDto
                {
                    Year = g.Key.Year,
                    Month = g.Key.Month,
                    Revenue = g.Sum(x => x.UnitPrice * x.Quantity),
                    Cost = g.Sum(x => x.Product.CostPrice * x.Quantity),
                    Profit = g.Sum(x => (x.UnitPrice - x.Product.CostPrice) * x.Quantity)
                })
                .OrderBy(g => g.Year)
                .ThenBy(g => g.Month)
                .ToListAsync();

            var brandStats = await detailQuery
                .Where(d => d.Product.BrandId != null)
                .GroupBy(d => new { d.Product.BrandId, d.Product.Brand!.Name })
                .Select(g => new BrandSalesDto
                {
                    BrandId = g.Key.BrandId,
                    BrandName = g.Key.Name,
                    QuantitySold = g.Sum(x => x.Quantity),
                    Revenue = g.Sum(x => x.UnitPrice * x.Quantity)
                })
                .OrderByDescending(x => x.QuantitySold)
                .ThenByDescending(x => x.Revenue)
                .ToListAsync();

            var currentMonthStart = new DateTime(now.Year, now.Month, 1);
            var previousMonthStart = currentMonthStart.AddMonths(-1);

            var currentMonthProfit = await detailQuery
                .Where(d => d.Order.CreatedAt >= currentMonthStart)
                .SumAsync(x => (x.UnitPrice - x.Product.CostPrice) * x.Quantity);

            var previousMonthProfit = await detailQuery
                .Where(d => d.Order.CreatedAt >= previousMonthStart && d.Order.CreatedAt < currentMonthStart)
                .SumAsync(x => (x.UnitPrice - x.Product.CostPrice) * x.Quantity);

            var growthPercentage = CalculateGrowthPercentage(previousMonthProfit, currentMonthProfit);

            return new DashboardResponseDto
            {
                TopProducts = topProducts,
                ProfitSummary = profitSummary,
                MonthlyProfits = FillMissingMonths(monthlyProfits, startMonth, monthCount),
                TopBrands = brandStats,
                ProfitGrowth = new GrowthOverviewDto
                {
                    CurrentMonthProfit = currentMonthProfit,
                    PreviousMonthProfit = previousMonthProfit,
                    GrowthPercentage = growthPercentage
                }
            };
        }

        private static decimal CalculateGrowthPercentage(decimal previous, decimal current)
        {
            if (previous == 0)
            {
                return current == 0 ? 0 : 100;
            }

            return Math.Round(((current - previous) / Math.Abs(previous)) * 100, 2);
        }

        private static List<MonthlyProfitDto> FillMissingMonths(
            List<MonthlyProfitDto> existing,
            DateTime startMonth,
            int monthCount)
        {
            var result = new List<MonthlyProfitDto>();
            var lookup = existing.ToDictionary(
                x => (x.Year, x.Month),
                x => x);

            for (var i = 0; i < monthCount; i++)
            {
                var target = startMonth.AddMonths(i);
                if (lookup.TryGetValue((target.Year, target.Month), out var value))
                {
                    result.Add(value);
                }
                else
                {
                    result.Add(new MonthlyProfitDto
                    {
                        Year = target.Year,
                        Month = target.Month,
                        Revenue = 0,
                        Cost = 0,
                        Profit = 0
                    });
                }
            }

            return result
                .OrderBy(x => x.Year)
                .ThenBy(x => x.Month)
                .ToList();
        }
    }
}
