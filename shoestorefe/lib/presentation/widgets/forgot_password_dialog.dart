import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoestorefe/presentation/admin/provider/forgot_password_provider.dart';

class ForgotPasswordDialog extends StatelessWidget {
  const ForgotPasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => context.read<ForgotPasswordProvider>(),
      child: Consumer<ForgotPasswordProvider>(
        builder: (context, provider, _) {
          // Listen for success
          if (provider.success) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mật khẩu mới đã được gửi đến email của bạn'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
              provider.clear();
            });
          }

          return AlertDialog(
            title: const Text('Quên mật khẩu'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nhập email hoặc số điện thoại của bạn. Chúng tôi sẽ gửi mật khẩu mới đến email của bạn.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: provider.emailController,
                  decoration: InputDecoration(
                    labelText: 'Email hoặc số điện thoại',
                    hintText: 'example@gmail.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                if (provider.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(
                                color: Colors.red[700], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: provider.isLoading
                    ? null
                    : () {
                        provider.clear();
                        Navigator.of(context).pop();
                      },
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed:
                    provider.isLoading ? null : () => provider.submitForgotPassword(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Gửi'),
              ),
            ],
          );
        },
      ),
    );
  }
}
