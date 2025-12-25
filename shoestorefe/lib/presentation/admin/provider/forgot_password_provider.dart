import 'package:flutter/material.dart';
import 'package:shoestorefe/domain/usecases/user/forgot_password.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  final ForgotPassword forgotPasswordUsecase;

  ForgotPasswordProvider(this.forgotPasswordUsecase);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _success = false;
  bool get success => _success;

  final TextEditingController emailController = TextEditingController();

  Future<void> submitForgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _error = 'Vui lòng nhập email hoặc số điện thoại';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      final result = await forgotPasswordUsecase.call(phoneOrEmail: email);
      _success = result;
      if (!result) {
        _error = 'Khôi phục mật khẩu thất bại';
      }
    } catch (e) {
      _error = e.toString();
      _success = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    emailController.clear();
    _error = null;
    _success = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
