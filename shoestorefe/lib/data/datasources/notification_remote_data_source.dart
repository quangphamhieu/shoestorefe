import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final ApiClient client;
  NotificationRemoteDataSource(this.client);

  Future<List<NotificationModel>> getAll() async {
    final response = await client.get(ApiEndpoint.notifications);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<NotificationModel?> getById(int id) async {
    final response = await client.get('${ApiEndpoint.notifications}/$id');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return NotificationModel.fromJson(data);
    }
    return null;
  }

  Future<bool> delete(int id) async {
    final response = await client.delete('${ApiEndpoint.notifications}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
