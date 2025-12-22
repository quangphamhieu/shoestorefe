import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/role_permission_provider.dart';
import 'role_permission_dialog.dart';

class RolePermissionToolbar extends StatelessWidget {
  const RolePermissionToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RolePermissionProvider>();
    final selectedRoleId = provider.selectedRoleId;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quản lý phân quyền',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Kiểm soát danh sách quyền hạn của từng vai trò',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: selectedRoleId == null
                ? null
                : () {
                    final role = provider.roles.firstWhere((r) => r.id == selectedRoleId);
                    showDialog(
                      context: context,
                      builder: (context) => RolePermissionDialog(
                        roleId: role.id,
                        roleName: role.name,
                      ),
                    );
                  },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              'Cập nhật quyền',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedRoleId == null ? Colors.grey : const Color(0xFF4CAF50),
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
