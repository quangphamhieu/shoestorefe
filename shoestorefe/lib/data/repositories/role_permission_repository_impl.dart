import '../../domain/entities/role_permission.dart';
import '../../domain/repositories/role_permission_repository.dart';
import '../datasources/role_permission_remote_data_source.dart';

class RolePermissionRepositoryImpl implements RolePermissionRepository {
  final RolePermissionRemoteDataSource remoteDataSource;

  RolePermissionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Role>> getAllRoles() async {
    return await remoteDataSource.getAllRoles();
  }

  @override
  Future<List<Permission>> getAllPermissions() async {
    return await remoteDataSource.getAllPermissions();
  }

  @override
  Future<RolePermission> getRolePermissions(int roleId) async {
    return await remoteDataSource.getRolePermissions(roleId);
  }

  @override
  Future<void> updateRolePermissions(int roleId, List<int> permissionIds) async {
    await remoteDataSource.updateRolePermissions(roleId, permissionIds);
  }
}
