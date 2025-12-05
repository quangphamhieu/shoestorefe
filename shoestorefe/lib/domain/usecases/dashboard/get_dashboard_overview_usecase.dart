import '../../entities/dashboard.dart';
import '../../repositories/dashboard_repository.dart';

class GetDashboardOverviewUseCase {
  final DashboardRepository repository;

  GetDashboardOverviewUseCase(this.repository);

  Future<DashboardSummary> call({int? storeId, int months = 6}) {
    return repository.fetchOverview(storeId: storeId, months: months);
  }
}

