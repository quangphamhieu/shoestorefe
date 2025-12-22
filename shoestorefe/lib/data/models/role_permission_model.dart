import '../../domain/entities/role_permission.dart';

class RoleModel extends Role {
  RoleModel({
    required int id,
    required String name,
    required String code,
  }) : super(id: id, name: name, code: code);

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class PermissionModel extends Permission {
  PermissionModel({
    required int id,
    required String code,
    required String description,
  }) : super(id: id, code: code, description: description);

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class RolePermissionModel extends RolePermission {
  RolePermissionModel({
    required int roleId,
    required String roleName,
    required String roleCode,
    required List<PermissionModel> permissions,
  }) : super(
          roleId: roleId,
          roleName: roleName,
          roleCode: roleCode,
          permissions: permissions,
        );

  factory RolePermissionModel.fromJson(Map<String, dynamic> json) {
    return RolePermissionModel(
      roleId: json['roleId'] ?? 0,
      roleName: json['roleName'] ?? '',
      roleCode: json['roleCode'] ?? '',
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => PermissionModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
