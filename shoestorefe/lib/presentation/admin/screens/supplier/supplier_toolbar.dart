import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/supplier_provider.dart';
import '../supplier/supplier_form_dialog.dart';
import '../../widgets/confirm_delete_dialog.dart';

class SupplierToolbar extends StatelessWidget {
  const SupplierToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProvider>();
    final hasSelection = provider.selectedSupplierId != null;
    final theme = Theme.of(context);

    final searchField = SizedBox(
      width: 320,
      child: TextField(
        onChanged: provider.setSearch,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo tên, mã hoặc thông tin liên hệ...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );

    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasSelection) ...[
          Tooltip(
            message: 'Sửa nhà cung cấp',
            child: OutlinedButton.icon(
              onPressed: () async {
                final success = await showDialog<bool>(
                  context: context,
                  builder: (_) => const SupplierFormDialog(editMode: true),
                );
                if (success == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật nhà cung cấp thành công'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF2563EB)),
              label: const Text(
                'Sửa',
                style: TextStyle(color: Color(0xFF2563EB)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFBFDBFE)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: 'Xóa nhà cung cấp',
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showConfirmDeleteDialog(
                  context,
                  title: 'Xác nhận',
                  content: 'Bạn có chắc muốn xóa nhà cung cấp này?',
                );
                if (confirm == true) {
                  final ok = await provider.deleteSelectedSupplier();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Xóa nhà cung cấp thành công'
                              : 'Xóa nhà cung cấp thất bại',
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
              label: const Text(
                'Xóa',
                style: TextStyle(color: Color(0xFFDC2626)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFECACA)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        ElevatedButton.icon(
          onPressed: () async {
            final created = await showDialog<bool>(
              context: context,
              builder: (_) => const SupplierFormDialog(editMode: false),
            );
            if (created == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thêm nhà cung cấp thành công')),
              );
            }
          },
          icon: const Icon(Icons.add, size: 20, color: Colors.black),
          label: const Text('Thêm mới', style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF90EE90),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            elevation: 0,
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 860;
          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản lý Nhà cung cấp',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Quản lý danh sách nhà cung cấp và thông tin liên hệ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: searchField),
                const SizedBox(height: 16),
                actionButtons,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý Nhà cung cấp',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Quản lý danh sách nhà cung cấp và thông tin liên hệ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              searchField,
              const SizedBox(width: 20),
              actionButtons,
            ],
          );
        },
      ),
    );
  }
}
