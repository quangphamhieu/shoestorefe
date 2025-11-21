import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json_utils.dart';
import '../models/receipt_model.dart';

class ReceiptRemoteDataSource {
  final ApiClient client;
  ReceiptRemoteDataSource(this.client);

  Future<List<ReceiptModel>> getAll() async {
    final response = await client.get(ApiEndpoint.receipts);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => ReceiptModel.fromJson(JsonUtils.normalizeMap(e)))
          .toList();
    }
    return [];
  }

  Future<ReceiptModel?> getById(int id) async {
    final response = await client.get('${ApiEndpoint.receipts}/$id');
    final data = response.data;
    if (data is Map || data is Map<String, dynamic>) {
      return ReceiptModel.fromJson(JsonUtils.normalizeMap(data));
    }
    return null;
  }

  Future<ReceiptModel> create(ReceiptModel receipt) async {
    final response = await client.post(
      ApiEndpoint.receipts,
      receipt.toCreateJson(),
    );
    return ReceiptModel.fromJson(JsonUtils.normalizeMap(response.data));
  }

  Future<ReceiptModel?> updateInfo(int id, ReceiptModel receipt) async {
    final response = await client.put(
      '${ApiEndpoint.receipts}/$id/info',
      receipt.toUpdateJson(),
    );
    final data = response.data;
    if (data is Map || data is Map<String, dynamic>) {
      return ReceiptModel.fromJson(JsonUtils.normalizeMap(data));
    }
    return null;
  }

  Future<ReceiptModel?> updateReceived(int id, ReceiptModel receipt) async {
    final response = await client.put(
      '${ApiEndpoint.receipts}/$id/receive',
      receipt.toUpdateReceivedJson(),
    );
    final data = response.data;
    if (data is Map || data is Map<String, dynamic>) {
      return ReceiptModel.fromJson(JsonUtils.normalizeMap(data));
    }
    return null;
  }

  Future<bool> delete(int id) async {
    final response = await client.delete('${ApiEndpoint.receipts}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
