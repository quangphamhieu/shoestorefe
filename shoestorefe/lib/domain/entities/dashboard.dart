class DashboardSummary {
  final List<TopProductStat> topProducts;
  final ProfitSummary profitSummary;
  final List<MonthlyProfitStat> monthlyProfits;
  final List<BrandSalesStat> topBrands;
  final GrowthOverview profitGrowth;

  DashboardSummary({
    required this.topProducts,
    required this.profitSummary,
    required this.monthlyProfits,
    required this.topBrands,
    required this.profitGrowth,
  });
}

class TopProductStat {
  final int productId;
  final String productName;
  final String? sku;
  final int quantitySold;
  final double revenue;

  TopProductStat({
    required this.productId,
    required this.productName,
    this.sku,
    required this.quantitySold,
    required this.revenue,
  });
}

class ProfitSummary {
  final double revenue;
  final double cost;
  final double profit;

  ProfitSummary({
    required this.revenue,
    required this.cost,
    required this.profit,
  });
}

class MonthlyProfitStat {
  final int year;
  final int month;
  final double revenue;
  final double cost;
  final double profit;

  MonthlyProfitStat({
    required this.year,
    required this.month,
    required this.revenue,
    required this.cost,
    required this.profit,
  });
}

class BrandSalesStat {
  final int? brandId;
  final String brandName;
  final int quantitySold;
  final double revenue;

  BrandSalesStat({
    required this.brandId,
    required this.brandName,
    required this.quantitySold,
    required this.revenue,
  });
}

class GrowthOverview {
  final double currentMonthProfit;
  final double previousMonthProfit;
  final double growthPercentage;

  GrowthOverview({
    required this.currentMonthProfit,
    required this.previousMonthProfit,
    required this.growthPercentage,
  });
}

