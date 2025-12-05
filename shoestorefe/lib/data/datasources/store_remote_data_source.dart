import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../models/store_model.dart';

class StoreRemoteDataSource {
  final ApiClient client;
  StoreRemoteDataSource(this.client);

  Future<List<StoreModel>> getAll() async {
    final response = await client.get(ApiEndpoint.stores);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => StoreModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<StoreModel?> getById(int id) async {
    final response = await client.get('${ApiEndpoint.stores}/$id');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return StoreModel.fromJson(data);
    }
    return null;
  }

  Future<StoreModel> create({
    required String name,
    required String code,
    required String address,
    required String phone,
  }) async {
    final body = {
      'code': code,
      'name': name,
      'address': address,
      'phone': phone,
    };
    final response = await client.post(ApiEndpoint.stores, body);
    return StoreModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<StoreModel?> update(
    int id, {
    required String name,
    required String code,
    required String address,
    required String phone,
    required int statusId,
  }) async {
    final body = {
      'code': code,
      'name': name,
      'address': address,
      'phone': phone,
      'statusId': statusId,
    };
    final response = await client.put('${ApiEndpoint.stores}/$id', body);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return StoreModel.fromJson(data);
    }
    return null;
  }

  Future<bool> delete(int id) async {
    final response = await client.delete('${ApiEndpoint.stores}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
