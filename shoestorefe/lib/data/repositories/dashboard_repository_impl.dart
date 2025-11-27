import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<DashboardSummary> fetchOverview({int? storeId, int months = 6}) {
    return remoteDataSource.fetchOverview(storeId: storeId, months: months);
  }
}

