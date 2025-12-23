import '../entities/dashboard.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> fetchOverview({int? storeId, int? brandId, int months = 6});
}

