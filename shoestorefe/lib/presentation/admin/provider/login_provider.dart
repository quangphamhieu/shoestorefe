import 'package:flutter/material.dart';
import 'package:shoestorefe/data/models/user_model.dart';
import 'package:shoestorefe/domain/usecases/user/login.dart';
import 'package:shoestorefe/core/network/token_handler.dart';

class LoginProvider extends ChangeNotifier {
  final LoginUser loginUserUsecase;

  LoginProvider(this.loginUserUsecase);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  LoginResponse? _user;
  LoginResponse? get user => _user;

  // TextEditingControllers
  final TextEditingController phoneOrEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final phoneOrEmail = phoneOrEmailController.text.trim();
    final password = passwordController.text;

    if (phoneOrEmail.isEmpty || password.isEmpty) {
      _error = "Vui lòng nhập đầy đủ thông tin";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await loginUserUsecase.call(phoneOrEmail, password);
      if (response == null) {
        _error = "Sai tài khoản hoặc mật khẩu";
      } else {
        // Lưu token
        await TokenHandler().addToken(response.token);
        _user = response;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    phoneOrEmailController.clear();
    passwordController.clear();
    _error = null;
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    phoneOrEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
