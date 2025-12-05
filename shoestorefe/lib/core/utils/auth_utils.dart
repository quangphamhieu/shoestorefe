import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../network/token_handler.dart';
import '../../presentation/admin/screens/user/login_screen.dart';

class AuthUtils {
  static String? fetchUserIdFromToken({required BuildContext context}) {
    if (!TokenHandler().hasToken()) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
      return null;
    }

    final userId = TokenHandler().getUserId();
    if (userId == null || userId.isEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
      return null;
    }

    return userId;
  }

  static String? fetchUserNameFromToken({required BuildContext context}) {
    if (!TokenHandler().hasToken()) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
      return null;
    }

    final userName = TokenHandler().getUserName();
    return userName;
  }

  static void checkAdminRole(BuildContext context) {
    if (!TokenHandler().hasToken()) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
      return;
    }

    final role = TokenHandler().getUserRole();

    if (role != "Super Admin" && role != "Admin") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  static void checkCustomerRole(BuildContext context) {
    if (!TokenHandler().hasToken()) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
      return;
    }

    final role = TokenHandler().getUserRole();

    if (role != "Customer") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  static String? getUserRole() {
    if (!TokenHandler().hasToken()) {
      return null;
    }
    return TokenHandler().getUserRole();
  }

  static bool isAdmin() {
    final role = getUserRole();
    return role == "Super Admin" || role == "Admin";
  }

  static bool isCustomer() {
    final role = getUserRole();
    return role == "Customer";
  }

  static Future<void> logout(BuildContext context) async {
    // Xóa token
    await TokenHandler().clearToken();
    // Điều hướng về màn hình login và refresh router
    if (context.mounted) {
      // Import appRouter để refresh
      final router = GoRouter.of(context);
      router.refresh();
      context.go('/');
    }
  }
}
