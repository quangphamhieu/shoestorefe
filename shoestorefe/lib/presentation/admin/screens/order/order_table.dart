import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/order.dart';
import '../../provider/order_provider.dart';

class OrderTable extends StatelessWidget {
  final List<Order> orders;
  OrderTable({super.key, required this.orders});

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  static const Map<int, String> statusLabels = {
    3: 'Đã thanh toán',
    4: 'Chờ xác nhận',
    5: 'Hoàn tất',
    6: 'Đã hủy',
  };

  static const Map<int, Color> statusColors = {
    3: Color(0xFF10B981),
    4: Color(0xFF0EA5E9),
    5: Color(0xFF10B981),
    6: Color(0xFFDC2626),
  };

  static const Map<int, String> typeLabels = {0: 'Online', 1: 'Offline'};

  static const Map<int, String> paymentLabels = {
    0: 'Tiền mặt',
    1: 'Chuyển khoản',
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              showCheckboxColumn: false,
              columnSpacing: 20,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2933),
              ),
              dataTextStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
              ),
              dividerThickness: 0.3,
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF1F5F9),
              ),
              dataRowColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const Color(0xFFEFF6FF);
                }
                return Colors.white;
              }),
              columns: const [
                DataColumn(label: SizedBox(width: 32)),
                DataColumn(label: Text('Mã đơn')),
                DataColumn(label: Text('Khách hàng')),
                DataColumn(label: Text('Người tạo')),
                DataColumn(label: Text('Loại đơn')),
                DataColumn(label: Text('Thanh toán')),
                DataColumn(label: Text('Trạng thái')),
                DataColumn(label: Text('Tổng tiền')),
                DataColumn(label: Text('Ngày tạo')),
              ],
              rows:
                  orders.map((order) {
                    final selected = provider.isSelected(order.id);
                    return DataRow(
                      selected: selected,
                      onSelectChanged: (v) {
                        if (v == true) {
                          provider.selectOrder(order.id);
                        } else {
                          provider.selectOrder(null);
                        }
                      },
                      cells: [
                        DataCell(
                          Center(
                            child: Checkbox(
                              value: selected,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              onChanged: (v) {
                                if (v == true) {
                                  provider.selectOrder(order.id);
                                } else {
                                  provider.selectOrder(null);
                                }
                              },
                            ),
                          ),
                        ),
                        DataCell(Text(order.orderNumber)),
                        DataCell(
                          Text(
                            (order.customerName != null &&
                                    order.customerName!.trim().isNotEmpty)
                                ? order.customerName!
                                : 'Khách hàng #${order.customerId}',
                          ),
                        ),
                        DataCell(
                          Text(
                            (order.creatorName != null &&
                                    order.creatorName!.trim().isNotEmpty)
                                ? order.creatorName!
                                : (order.createdBy != null
                                    ? 'Nhân viên #${order.createdBy}'
                                    : '-'),
                          ),
                        ),
                        DataCell(Text(typeLabels[order.orderType] ?? '-')),
                        DataCell(
                          Text(paymentLabels[order.paymentMethod] ?? '-'),
                        ),
                        DataCell(
                          _StatusChip(
                            label:
                                statusLabels[order.statusId] ??
                                'Không xác định',
                            color: statusColors[order.statusId] ?? Colors.grey,
                          ),
                        ),
                        DataCell(
                          Text(currencyFormat.format(order.totalAmount)),
                        ),
                        DataCell(Text(dateFormat.format(order.createdAt))),
                      ],
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
