import '../../domain/entities/dashboard.dart';

class DashboardSummaryModel extends DashboardSummary {
  DashboardSummaryModel({
    required super.topProducts,
    required super.profitSummary,
    required super.monthlyProfits,
    required super.topBrands,
    required super.profitGrowth,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final topProducts = (json['topProducts'] as List<dynamic>? ?? [])
        .map(
          (item) => TopProductStat(
            productId: item['productId'] as int? ?? 0,
            productName: (item['productName'] as String?) ?? '',
            sku: item['sku'] as String?,
            quantitySold: item['quantitySold'] as int? ?? 0,
            revenue: (item['revenue'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();

    final monthlyProfits = (json['monthlyProfits'] as List<dynamic>? ?? [])
        .map(
          (item) => MonthlyProfitStat(
            year: item['year'] as int? ?? 0,
            month: item['month'] as int? ?? 0,
            revenue: (item['revenue'] as num?)?.toDouble() ?? 0,
            cost: (item['cost'] as num?)?.toDouble() ?? 0,
            profit: (item['profit'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();

    final brands = (json['topBrands'] as List<dynamic>? ?? [])
        .map(
          (item) => BrandSalesStat(
            brandId: item['brandId'] as int?,
            brandName: (item['brandName'] as String?) ?? 'Chưa xác định',
            quantitySold: item['quantitySold'] as int? ?? 0,
            revenue: (item['revenue'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();

    final profitSummaryJson =
        json['profitSummary'] as Map<String, dynamic>? ?? {};
    final growthJson = json['profitGrowth'] as Map<String, dynamic>? ?? {};

    return DashboardSummaryModel(
      topProducts: topProducts,
      profitSummary: ProfitSummary(
        revenue: (profitSummaryJson['revenue'] as num?)?.toDouble() ?? 0,
        cost: (profitSummaryJson['cost'] as num?)?.toDouble() ?? 0,
        profit: (profitSummaryJson['profit'] as num?)?.toDouble() ?? 0,
      ),
      monthlyProfits: monthlyProfits,
      topBrands: brands,
      profitGrowth: GrowthOverview(
        currentMonthProfit:
            (growthJson['currentMonthProfit'] as num?)?.toDouble() ?? 0,
        previousMonthProfit:
            (growthJson['previousMonthProfit'] as num?)?.toDouble() ?? 0,
        growthPercentage:
            (growthJson['growthPercentage'] as num?)?.toDouble() ?? 0,
      ),
    );
  }
}

