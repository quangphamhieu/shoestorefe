import '../entities/dashboard.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> fetchOverview({int? storeId, int months = 6});
}

