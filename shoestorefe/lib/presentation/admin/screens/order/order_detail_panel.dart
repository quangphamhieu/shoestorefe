import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/order.dart';
import '../../../../domain/entities/order_detail.dart';
import '../../provider/order_provider.dart';

class OrderDetailPanel extends StatelessWidget {
  final Order order;
  OrderDetailPanel({super.key, required this.order});

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chi tiết đơn hàng',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.orderNumber,
                    style: const TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              Text(
                'Tổng tiền: ${currencyFormat.format(order.totalAmount)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.isDetailMutating)
            const LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Color(0xFFE2E8F0),
            ),
          if (provider.isDetailMutating) const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Sản phẩm',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Đơn giá',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Số lượng',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Thành tiền',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(width: 80),
                    ],
                  ),
                ),
                if (order.details.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Đơn hàng hiện chưa có sản phẩm nào.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                else
                  ...List.generate(order.details.length, (index) {
                    final detail = order.details[index];
                    final isFirst = index == 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color:
                                isFirst
                                    ? Colors.transparent
                                    : const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail.productName ??
                                      'Sản phẩm #${detail.productId}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              currencyFormat.format(detail.unitPrice),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF334155)),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              detail.quantity.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              currencyFormat.format(
                                detail.unitPrice * detail.quantity,
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF0F9D58),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  tooltip: 'Sửa số lượng',
                                  onPressed:
                                      provider.isDetailMutating
                                          ? null
                                          : () async {
                                            final newQuantity =
                                                await _promptQuantity(
                                                  context,
                                                  detail.quantity,
                                                );
                                            if (newQuantity != null &&
                                                context.mounted) {
                                              final success = await provider
                                                  .updateOrderDetailQuantity(
                                                    orderDetailId: detail.id,
                                                    quantity: newQuantity,
                                                  );
                                              if (success && context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Cập nhật số lượng thành công',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Color(0xFF2563EB),
                                    size: 20,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Xóa sản phẩm',
                                  onPressed:
                                      provider.isDetailMutating
                                          ? null
                                          : () async {
                                            final confirm =
                                                await _confirmDelete(
                                                  context,
                                                  detail,
                                                );
                                            if (confirm == true &&
                                                context.mounted) {
                                              final success = await provider
                                                  .deleteOrderDetail(detail.id);
                                              if (success && context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Xóa sản phẩm khỏi đơn hàng',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFFDC2626),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<int?> _promptQuantity(
    BuildContext context,
    int currentQuantity,
  ) async {
    final controller = TextEditingController(text: currentQuantity.toString());
    final formKey = GlobalKey<FormState>();

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cập nhật số lượng'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Số lượng'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số lượng';
                }
                final parsed = int.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return 'Số lượng phải lớn hơn 0';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() == true) {
                  Navigator.of(context).pop(int.parse(controller.text));
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, OrderDetail detail) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa sản phẩm khỏi đơn hàng'),
          content: Text(
            'Bạn có chắc muốn xóa "${detail.productName ?? 'Sản phẩm #${detail.productId}'}" khỏi đơn hàng?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}
