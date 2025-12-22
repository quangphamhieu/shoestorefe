import '../entities/role_permission.dart';

abstract class RolePermissionRepository {
  Future<List<Role>> getAllRoles();
  Future<List<Permission>> getAllPermissions();
  Future<RolePermission> getRolePermissions(int roleId);
  Future<void> updateRolePermissions(int roleId, List<int> permissionIds);
}
