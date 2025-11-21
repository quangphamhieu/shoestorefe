import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shoestorefe/presentation/admin/provider/login_provider.dart';
import 'package:shoestorefe/core/utils/auth_utils.dart';
import 'package:shoestorefe/presentation/routes/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberLogin = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoginProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        children: [
          // Left side - Login Form
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    color: Colors.grey[100],
                    child: const Text(
                      "Đăng nhập",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Form Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 40,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Đăng nhập",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Nhập số điện thoại và mật khẩu để đăng nhập",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Phone/Email Field
                            TextField(
                              controller: provider.phoneOrEmailController,
                              decoration: InputDecoration(
                                labelText: "Số điện thoại*",
                                labelStyle: TextStyle(color: Colors.grey[600]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF9C27B0),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Password Field
                            TextField(
                              controller: provider.passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Mật khẩu*",
                                labelStyle: TextStyle(color: Colors.grey[600]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF9C27B0),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Remember Login & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberLogin,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberLogin = value ?? false;
                                        });
                                      },
                                      activeColor: const Color(0xFF9C27B0),
                                    ),
                                    const Text(
                                      "Lưu đăng nhập",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF9C27B0),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    // TODO: Implement forgot password
                                  },
                                  child: const Text(
                                    "Quên mật khẩu?",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF9C27B0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Error Message
                            if (provider.error != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        provider.error!,
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed:
                                    provider.isLoading
                                        ? null
                                        : () async {
                                          await provider.login();
                                          if (provider.user != null &&
                                              mounted) {
                                            // Refresh router để trigger redirect logic
                                            appRouter.refresh();
                                            // Điều hướng dựa trên role
                                            final role =
                                                AuthUtils.getUserRole();
                                            if (role == "Super Admin" ||
                                                role == "Admin") {
                                              context.go('/dashboard');
                                            } else if (role == "Customer") {
                                              context.go('/home');
                                            }
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9C27B0),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child:
                                    provider.isLoading
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          "Đăng nhập",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Sign Up Link
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  children: [
                                    const TextSpan(text: "Chưa có tài khoản? "),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () => context.go('/signup'),
                                        child: const Text(
                                          "Tạo tài khoản mới",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF9C27B0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side - Banner
          if (screenWidth > 600)
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  bottomLeft: Radius.circular(32),
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/banner.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
