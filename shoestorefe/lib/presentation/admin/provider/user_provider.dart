// ...existing code...
import 'package:flutter/material.dart';
import 'package:shoestorefe/domain/entities/user.dart';
import 'package:shoestorefe/domain/usecases/user/get_all_user.dart';
import 'package:shoestorefe/domain/usecases/user/get_user_by_id.dart';
import 'package:shoestorefe/domain/usecases/user/create_user.dart';
import 'package:shoestorefe/domain/usecases/user/update_user.dart';
import 'package:shoestorefe/domain/usecases/user/delete_user.dart';

class UserProvider extends ChangeNotifier {
  final GetAllUsers getAllUsers;
  final GetUserById getUserById;
  final CreateUser createUserUc;
  final UpdateUser updateUserUc;
  final DeleteUser deleteUserUc;

  UserProvider({
    required this.getAllUsers,
    required this.getUserById,
    required this.createUserUc,
    required this.updateUserUc,
    required this.deleteUserUc,
  });

  // general loading for list fetching
  bool isLoading = false;

  // operation-specific loading flags
  bool isCreating = false;
  bool isUpdating = false;
  bool isDeleting = false;
  bool isDetailLoading = false;

  List<User> users = [];
  String _filter = '';
  int? selectedUserId;

  List<User> get filteredUsers {
    final q = _filter.trim().toLowerCase();
    if (q.isEmpty) return users;
    return users.where((u) {
      return u.fullName.toLowerCase().contains(q) ||
          u.phone.toLowerCase().contains(q) ||
          (u.email ?? '').toLowerCase().contains(q) ||
          u.roleName.toLowerCase().contains(q);
    }).toList();
  }

  void setFilter(String q) {
    _filter = q;
    notifyListeners();
  }

  Future<void> loadAll() async {
    isLoading = true;
    notifyListeners();
    try {
      final list = await getAllUsers.call();
      users = list;
    } catch (_) {
      users = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectUser(int? id) {
    selectedUserId = id;
    notifyListeners();
  }

  Future<User?> getSelectedUserDetail() async {
    if (selectedUserId == null) return null;
    isDetailLoading = true;
    notifyListeners();
    try {
      return await getUserById.call(selectedUserId!);
    } catch (_) {
      return null;
    } finally {
      isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser({
    required String fullName,
    required String phone,
    String? email,
    required String password,
    required int gender,
    required int roleId,
    int? storeId,
  }) async {
    isCreating = true;
    notifyListeners();
    try {
      final u = await createUserUc.call(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
        gender: gender,
        roleId: roleId,
        storeId: storeId,
      );
      // append to list and refresh
      users.insert(0, u);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser({
    required int id,
    required String fullName,
    required String phone,
    String? email,
    required int gender,
    required int roleId,
    int? storeId,
    required int statusId,
  }) async {
    isUpdating = true;
    notifyListeners();
    try {
      final u = await updateUserUc.call(
        id: id,
        fullName: fullName,
        phone: phone,
        email: email,
        gender: gender,
        roleId: roleId,
        storeId: storeId,
        statusId: statusId,
      );
      if (u != null) {
        final idx = users.indexWhere((e) => e.id == u.id);
        if (idx >= 0) users[idx] = u;
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(int id) async {
    isDeleting = true;
    notifyListeners();
    try {
      final ok = await deleteUserUc.call(id);
      if (ok) {
        users.removeWhere((u) => u.id == id);
        if (selectedUserId == id) selectedUserId = null;
        notifyListeners();
      }
      return ok;
    } catch (_) {
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }
}
