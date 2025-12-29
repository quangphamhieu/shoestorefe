import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoestorefe/presentation/customer/provider/profile_provider.dart';

class WebProfileDialog extends StatelessWidget {
  const WebProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Thông tin cá nhân',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (provider.isLoading && provider.user == null)
              const Center(child: CircularProgressIndicator())
            else if (provider.user == null)
              const Center(child: Text('Không thể tải thông tin'))
            else ...[
              _buildInfoRow('Họ và tên', provider.user!.fullName),
              const SizedBox(height: 16),
              _buildInfoRow('Email', provider.user!.email ?? 'Chưa cập nhật'),
              const SizedBox(height: 16),
              _buildInfoRow('Số điện thoại', provider.user!.phone),
              const SizedBox(height: 16),
              _buildInfoRow('Giới tính', provider.user!.gender == 0 ? 'Nam' : 'Nữ'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
