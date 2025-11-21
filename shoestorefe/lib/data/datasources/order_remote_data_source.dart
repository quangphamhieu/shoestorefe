import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  final ApiClient client;
  OrderRemoteDataSource(this.client);

  Future<List<OrderModel>> getAll() async {
    final response = await client.get(ApiEndpoint.orders);
    final data = response.data;
    if (data is List) {
      return data
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<OrderModel> create(Map<String, dynamic> body) async {
    final response = await client.post(ApiEndpoint.orders, body);
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<bool> updateStatus({
    required int orderId,
    required int statusId,
  }) async {
    final body = {'orderId': orderId, 'statusId': statusId};
    final response = await client.put('${ApiEndpoint.orders}/status', body);
    final successCodes = {200, 204};
    return successCodes.contains(response.statusCode);
  }

  Future<bool> updateDetail({
    required int orderDetailId,
    required int quantity,
  }) async {
    final body = {'quantity': quantity};
    final response = await client.put(
      '${ApiEndpoint.orders}/detail/$orderDetailId',
      body,
    );
    final successCodes = {200, 204};
    return successCodes.contains(response.statusCode);
  }

  Future<bool> deleteDetail(int orderDetailId) async {
    final response = await client.delete(
      '${ApiEndpoint.orders}/detail/$orderDetailId',
    );
    final successCodes = {200, 204};
    return successCodes.contains(response.statusCode);
  }
}
