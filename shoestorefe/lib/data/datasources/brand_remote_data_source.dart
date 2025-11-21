import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../models/brand_model.dart';

class BrandRemoteDataSource {
  final ApiClient client;
  BrandRemoteDataSource(this.client);

  Future<List<BrandModel>> getAll() async {
    final response = await client.get(ApiEndpoint.brands);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<BrandModel?> getById(int id) async {
    final response = await client.get('${ApiEndpoint.brands}/$id');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return BrandModel.fromJson(data);
    }
    return null;
  }

  Future<BrandModel> create(
    String name, {
    String? code,
    String? description,
  }) async {
    final body = {'code': code, 'name': name, 'description': description};
    final response = await client.post(ApiEndpoint.brands, body);
    return BrandModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BrandModel?> update(
    int id, {
    required String name,
    String? code,
    String? description,
    required int statusId,
  }) async {
    final body = {
      'code': code,
      'name': name,
      'description': description,
      'statusId': statusId,
    };
    final response = await client.put('${ApiEndpoint.brands}/$id', body);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return BrandModel.fromJson(data);
    }
    return null;
  }

  Future<bool> delete(int id) async {
    final response = await client.delete('${ApiEndpoint.brands}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
