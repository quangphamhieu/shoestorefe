import 'package:flutter/material.dart';
import '../../../../domain/entities/role_permission.dart';
import '../../../../domain/repositories/role_permission_repository.dart';

import '../../../../core/network/token_handler.dart';

class RolePermissionProvider extends ChangeNotifier {
  final RolePermissionRepository repository;

  List<Role> _roles = [];
  List<Permission> _allPermissions = [];
  RolePermission? _selectedRolePermissions;
  int? _selectedRoleId; // Track selected role for checkbox
  bool _isLoading = false;
  String? _error;

  List<Role> get roles => _roles;
  List<Permission> get allPermissions => _allPermissions;
  RolePermission? get selectedRolePermissions => _selectedRolePermissions;
  int? get selectedRoleId => _selectedRoleId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RolePermissionProvider({required this.repository});

  Future<void> fetchRoles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _roles = await repository.getAllRoles();
    } catch (e) {
      _error = e.toString();
      debugPrint("JWT Payload: ${TokenHandler().decodeToken()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPermissions() async {
    try {
      _allPermissions = await repository.getAllPermissions();
    } catch (e) {
      print('Error fetching permissions: $e');
    }
  }

  Future<void> fetchRolePermissions(int roleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Ensure we have all permissions loaded too, for the UI
      if (_allPermissions.isEmpty) {
        await fetchPermissions();
      }
      _selectedRolePermissions = await repository.getRolePermissions(roleId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRolePermissions(int roleId, List<int> permissionIds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await repository.updateRolePermissions(roleId, permissionIds);
      // Refresh the selected role permissions to verify sync
      await fetchRolePermissions(roleId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectRole(int? roleId) {
    _selectedRoleId = roleId;
    notifyListeners();
  }
}
