import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/order_provider.dart';

class OrderToolbar extends StatelessWidget {
  const OrderToolbar({super.key});

  static const Map<int, String> statusLabels = {
    3: 'Đã thanh toán thành công',
    4: 'Chờ xác nhận',
    5: 'Giao hàng thành công',
    6: 'Đã hủy',
  };

  static const Map<int, String> typeLabels = {0: 'Online', 1: 'Offline'};

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
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
                hintText: 'Tìm theo khách hàng hoặc người tạo...',
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

          final typeFilter = DropdownButton<int?>(
            value: provider.typeFilter,
            hint: const Text('Loại đơn hàng'),
            underline: const SizedBox.shrink(),
            onChanged: provider.setTypeFilter,
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Tất cả loại đơn'),
              ),
              ...typeLabels.entries.map(
                (entry) => DropdownMenuItem<int?>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              ),
            ],
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
              if (hasSelection) ...[
                _StatusActionButton(
                  label: 'Xác nhận thanh toán',
                  color: const Color(0xFF0EA5E9),
                  icon: Icons.check_circle_outline,
                  onPressed:
                      !provider.isUpdatingStatus
                          ? () => _handleUpdate(context, provider, 3)
                          : null,
                ),
                _StatusActionButton(
                  label: 'Giao hàng thành công',
                  color: const Color(0xFF10B981),
                  icon: Icons.local_shipping_outlined,
                  onPressed:
                      !provider.isUpdatingStatus
                          ? () => _handleUpdate(context, provider, 5)
                          : null,
                ),
                _StatusActionButton(
                  label: 'Hủy đơn hàng',
                  color: const Color(0xFFDC2626),
                  icon: Icons.cancel_outlined,
                  onPressed:
                      !provider.isUpdatingStatus
                          ? () => _handleUpdate(context, provider, 6)
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
                          'Theo dõi và cập nhật trạng thái các đơn hàng',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isCompact) ...[
                    searchField,
                    const SizedBox(width: 16),
                    typeFilter,
                  ],
                ],
              ),
              if (isCompact) ...[
                const SizedBox(height: 16),
                searchField,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: typeFilter),
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
              if (hasSelection) ...[const SizedBox(height: 18), actionButtons],
            ],
          );

          return content;
        },
      ),
    );
  }

  Future<void> _handleUpdate(
    BuildContext context,
    OrderProvider provider,
    int statusId,
  ) async {
    final success = await provider.updateSelectedOrdersStatus(statusId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Cập nhật trạng thái thành công' : 'Cập nhật thất bại',
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
