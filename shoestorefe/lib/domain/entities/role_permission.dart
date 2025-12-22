class Role {
  final int id;
  final String name;
  final String code;

  Role({required this.id, required this.name, required this.code});
}

class Permission {
  final int id;
  final String code;
  final String description;

  Permission({required this.id, required this.code, required this.description});
}

class RolePermission {
  final int roleId;
  final String roleName;
  final String roleCode;
  final List<Permission> permissions;

  RolePermission({
    required this.roleId,
    required this.roleName,
    required this.roleCode,
    required this.permissions,
  });
}
