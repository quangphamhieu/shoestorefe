import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoestorefe/domain/entities/user.dart';
import 'package:shoestorefe/domain/repositories/user_repository.dart';
import 'package:shoestorefe/core/network/token_handler.dart';

class ProfileProvider extends ChangeNotifier {
  final UserRepository userRepository;

  ProfileProvider({required this.userRepository});

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  String? _error;
  String? get error => _error;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = await _getCurrentUserId();
      _user = await userRepository.getById(userId);

      // Populate controllers
      if (_user != null) {
        nameController.text = _user!.fullName;
        phoneController.text = _user!.phone ?? '';

        // Load address from SharedPreferences (backend doesn't support address yet)
        final prefs = await SharedPreferences.getInstance();
        final savedAddress = prefs.getString('user_address_${_user!.id}') ?? '';
        addressController.text = savedAddress;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleEditMode() async {
    _isEditing = !_isEditing;
    if (!_isEditing) {
      // Reset controllers if cancel editing
      if (_user != null) {
        nameController.text = _user!.fullName;
        phoneController.text = _user!.phone ?? '';

        // Reload address from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final savedAddress = prefs.getString('user_address_${_user!.id}') ?? '';
        addressController.text = savedAddress;
      }
    }
    notifyListeners();
  }

  Future<bool> updateProfile() async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get roleId from roleName
      int roleId = 4; // Default customer
      if (_user!.roleName == 'Admin') roleId = 1;
      if (_user!.roleName == 'Manager') roleId = 2;
      if (_user!.roleName == 'Employee') roleId = 3;

      // Get statusId (assuming active = 1)
      int statusId = 1; // Active

      print('[ProfileProvider] Updating profile for user ID: ${_user!.id}');
      print('[ProfileProvider] Name: ${nameController.text.trim()}');
      print('[ProfileProvider] Phone: ${phoneController.text.trim()}');

      // Use updateMyProfile instead of update (no admin permission required)
      final updatedUser = await userRepository.updateMyProfile(
        id: _user!.id,
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: _user!.email,
        gender: _user!.gender,
        roleId: roleId,
        storeId: _user!.storeId,
        statusId: statusId,
      );

      if (updatedUser != null) {
        _user = updatedUser;
        print('[ProfileProvider] ✅ Profile updated successfully');

        // Update controllers with new data
        nameController.text = _user!.fullName;
        phoneController.text = _user!.phone ?? '';

        // Save address to SharedPreferences (backend doesn't support address yet)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'user_address_${_user!.id}',
          addressController.text.trim(),
        );
        print('[ProfileProvider] ✅ Address saved to local storage');

        _isEditing = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Update failed - returned null');
      }
    } catch (e) {
      print('[ProfileProvider] ❌ Error updating profile: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      _error = 'Mật khẩu xác nhận không khớp';
      notifyListeners();
      return false;
    }

    if (_user == null) {
      _error = 'Không tìm thấy thông tin người dùng';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call API to change password
      final success = await userRepository.resetPassword(
        phoneOrEmail: _user!.phone ?? _user!.email ?? '',
        newPassword: newPasswordController.text,
        oldPassword: currentPasswordController.text,
      );

      if (!success) {
        _error = 'Đổi mật khẩu thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await TokenHandler().clearToken();
    _user = null;
    notifyListeners();
  }

  Future<int> _getCurrentUserId() async {
    final userIdStr = TokenHandler().getUserId();

    if (userIdStr == null) {
      throw Exception('User not authenticated');
    }

    return int.parse(userIdStr);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
