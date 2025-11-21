import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserRemoteDataSource {
  final ApiClient client;
  UserRemoteDataSource(this.client);

  Future<List<UserModel>> getAll() async {
    final response = await client.get(ApiEndpoint.user);
    final data = response.data;

    if (data is List) {
      return data.map((e) => UserModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<UserModel?> getById(int id) async {
    final response = await client.get("${ApiEndpoint.user}/$id");
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return UserModel.fromJson(data);
    }
    return null;
  }

  Future<UserModel> create(Map<String, dynamic> body) async {
    final response = await client.post(ApiEndpoint.user, body);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return UserModel.fromJson(data);
    }
    throw Exception('Invalid response format');
  }

  Future<UserModel?> update(int id, Map<String, dynamic> body) async {
    final response = await client.put("${ApiEndpoint.user}/$id", body);
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return UserModel.fromJson(data);
    }
    return null;
  }

  Future<bool> delete(int id) async {
    final response = await client.delete("${ApiEndpoint.user}/$id");
    return response.statusCode == 200;
  }

  Future<LoginResponseModel?> login(
    String phoneOrEmail,
    String password,
  ) async {
    final response = await client.post("${ApiEndpoint.user}/login", {
      "phoneOrEmail": phoneOrEmail,
      "password": password,
    });

    if (response.data is Map<String, dynamic>) {
      return LoginResponseModel.fromJson(response.data);
    }
    return null;
  }

  Future<UserModel> signup(Map<String, dynamic> body) async {
    final response = await client.post("${ApiEndpoint.user}/signup", body);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return UserModel.fromJson(data);
    }
    throw Exception('Invalid response format');
  }

  Future<bool> resetPassword(Map<String, dynamic> body) async {
    final response = await client.post(
      "${ApiEndpoint.user}/reset-password",
      body,
    );
    return response.statusCode == 200;
  }
}
