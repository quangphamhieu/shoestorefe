import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shoestorefe/core/utils/auth_utils.dart';

class WebProfileOverlay extends StatelessWidget {
  const WebProfileOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            label: 'Thông tin cá nhân',
            onTap: () => context.go('/profile'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.edit_outlined,
            label: 'Chỉnh sửa thông tin',
            onTap: () => context.go('/profile'), // Assuming profile page has edit
          ),
          _buildMenuItem(
            context,
            icon: Icons.lock_outline,
            label: 'Đổi mật khẩu',
            onTap: () => context.go('/profile'), // Assuming profile page has change password section
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            label: 'Đăng xuất',
            color: Colors.red,
            onTap: () => AuthUtils.logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: color ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
