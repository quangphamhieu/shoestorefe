import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/staff_order_provider.dart';
import 'staff_order_form_dialog.dart';

class StaffOrderToolbar extends StatelessWidget {
  const StaffOrderToolbar({super.key});

  static const Map<int, String> statusLabels = {
    3: 'Đã thanh toán thành công',
    6: 'Đã hủy',
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffOrderProvider>();
    final theme = Theme.of(context);
    final hasSelection = provider.selectedOrderIds.isNotEmpty;

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
          final isCompact = constraints.maxWidth < 1000;
          final searchField = SizedBox(
            width: isCompact ? double.infinity : 320,
            child: TextField(
              onChanged: provider.setSearch,
              decoration: InputDecoration(
                hintText: 'Tìm theo khách hàng hoặc mã đơn...',
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

          final statusChips = Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                statusLabels.entries.map((entry) {
                  final isSelected = provider.statusFilters.contains(entry.key);
                  return FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (_) => provider.toggleStatusFilter(entry.key),
                    selectedColor: const Color(0xFFE0F2FE),
                    checkmarkColor: Colors.deepOrange,
                  );
                }).toList(),
          );

          final actionButtons = Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: provider.isCreating
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (context) => const StaffOrderFormDialog(),
                        );
                      },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tạo đơn hàng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
              if (hasSelection) ...[
                _StatusActionButton(
                  label: 'Hủy đơn hàng',
                  color: const Color(0xFFDC2626),
                  icon: Icons.cancel_outlined,
                  onPressed:
                      !provider.isUpdatingStatus
                          ? () => _handleCancel(context, provider)
                          : null,
                ),
              ],
            ],
          );

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quản lý Đơn hàng',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quản lý các đơn hàng offline bạn đã tạo',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isCompact) ...[
                    searchField,
                  ],
                ],
              ),
              if (isCompact) ...[
                const SizedBox(height: 16),
                searchField,
              ],
              const SizedBox(height: 18),
              Text(
                'Lọc theo trạng thái',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              statusChips,
              if (hasSelection || !isCompact) ...[
                const SizedBox(height: 18),
                actionButtons,
              ],
            ],
          );

          return content;
        },
      ),
    );
  }

  Future<void> _handleCancel(
    BuildContext context,
    StaffOrderProvider provider,
  ) async {
    final success = await provider.updateSelectedOrdersStatus(6);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Hủy đơn hàng thành công' : 'Hủy đơn hàng thất bại',
        ),
      ),
    );
  }
}

class _StatusActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onPressed;

  const _StatusActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}

