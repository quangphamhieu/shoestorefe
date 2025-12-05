import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardRemoteDataSource {
  final ApiClient client;

  DashboardRemoteDataSource(this.client);

  Future<DashboardSummaryModel> fetchOverview({
    int? storeId,
    int months = 6,
  }) async {
    final queryParams = <String, dynamic>{
      'months': months,
      if (storeId != null) 'storeId': storeId,
    };

    final response = await client.get(
      ApiEndpoint.dashboard,
      queryParameters: queryParams,
    );

    if (response.data is Map<String, dynamic>) {
      return DashboardSummaryModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    throw Exception('Invalid dashboard response format');
  }
}

