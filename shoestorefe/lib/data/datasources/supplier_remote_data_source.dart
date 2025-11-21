import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../models/supplier_model.dart';

class SupplierRemoteDataSource {
  final ApiClient client;
  SupplierRemoteDataSource(this.client);

  Future<List<SupplierModel>> getAll() async {
    final response = await client.get(ApiEndpoint.suppliers);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => SupplierModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<SupplierModel?> getById(int id) async {
    final response = await client.get('${ApiEndpoint.suppliers}/$id');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return SupplierModel.fromJson(data);
    }
    return null;
  }

  Future<SupplierModel> create(
    String name, {
    String? code,
    String? contactInfo,
  }) async {
    final body = {'code': code, 'name': name, 'contactInfo': contactInfo};
    final response = await client.post(ApiEndpoint.suppliers, body);
    return SupplierModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SupplierModel?> update(
    int id, {
    required String name,
    String? code,
    String? contactInfo,
    required int statusId,
  }) async {
    final body = {
      'code': code,
      'name': name,
      'contactInfo': contactInfo,
      'statusId': statusId,
    };
    final response = await client.put('${ApiEndpoint.suppliers}/$id', body);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return SupplierModel.fromJson(data);
    }
    return null;
  }

  Future<bool> delete(int id) async {
    final response = await client.delete('${ApiEndpoint.suppliers}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
