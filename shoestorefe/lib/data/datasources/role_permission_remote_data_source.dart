import 'package:dio/dio.dart';
import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json_utils.dart';
import '../models/role_permission_model.dart';

class RolePermissionRemoteDataSource {
  final ApiClient client;

  RolePermissionRemoteDataSource(this.client);

  Future<List<RoleModel>> getAllRoles() async {
    final response = await client.get('${ApiEndpoint.rolePermissions}/roles');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => RoleModel.fromJson(JsonUtils.normalizeMap(e)))
          .toList();
    }
    return [];
  }

  Future<List<PermissionModel>> getAllPermissions() async {
    final response = await client.get('${ApiEndpoint.rolePermissions}/permissions');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => PermissionModel.fromJson(JsonUtils.normalizeMap(e)))
          .toList();
    }
    return [];
  }

  Future<RolePermissionModel> getRolePermissions(int roleId) async {
    final response = await client.get('${ApiEndpoint.rolePermissions}/$roleId');
    final data = response.data;
    if (data is Map || data is Map<String, dynamic>) {
      return RolePermissionModel.fromJson(JsonUtils.normalizeMap(data));
    }
    throw Exception('Failed to load role permissions');
  }

  Future<void> updateRolePermissions(int roleId, List<int> permissionIds) async {
    final body = {
      'roleId': roleId,
      'permissionIds': permissionIds,
    };
    await client.put(ApiEndpoint.rolePermissions, body);
  }
}
