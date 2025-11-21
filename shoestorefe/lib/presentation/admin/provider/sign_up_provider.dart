import 'package:flutter/material.dart';
import 'package:shoestorefe/domain/usecases/user/sign_up.dart';
import '../../../domain/entities/user.dart';

class SignUpProvider extends ChangeNotifier {
  final SignupUser signupUserUseCases;
  SignUpProvider(this.signupUserUseCases);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  int gender = 0;

  bool isLoading = false;
  String? error;
  User? user;

  void setGender(String value) {
    if (value == "Nam") {
      gender = 0;
    } else {
      gender = 1;
    }
    notifyListeners();
  }

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || (email.isEmpty && phone.isEmpty) || password.isEmpty) {
      error = "Vui lòng điền đầy đủ thông tin";
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // ensure we never pass null for email (use empty string if not provided)
      user = await signupUserUseCases.call(
        fullName: name,
        email: email.isNotEmpty ? email : '',
        phone: phone,
        password: password,
        gender: gender,
      );
    } catch (e) {
      error = e.toString();
      print(error);
      user = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
