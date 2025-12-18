import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shoestorefe/presentation/customer/provider/order_history_provider.dart';
import 'package:shoestorefe/domain/entities/order.dart';

class MobileOrderDetailScreen extends StatefulWidget {
  final Order order;
  const MobileOrderDetailScreen({super.key, required this.order});

  @override
  State<MobileOrderDetailScreen> createState() => _MobileOrderDetailScreenState();
}

class _MobileOrderDetailScreenState extends State<MobileOrderDetailScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
    // Replaced OrderProvider with OrderHistoryProvider for Customer App consistency
    final provider = context.watch<OrderHistoryProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(provider),
            const SizedBox(height: 16),
            _buildInfoSection(context, provider),
            const SizedBox(height: 16),
            _buildProductList(),
            const SizedBox(height: 16),
            _buildTotalSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(OrderHistoryProvider provider) {
    // Try to find the latest version of the order in the provider to reflect updates
    final liveOrder = provider.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đơn hàng ${liveOrder.orderNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatus(liveOrder.statusId),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(liveOrder.createdAt)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(int statusId) {
    String text;
    Color color;

    switch (statusId) {
      case 3: // Paid/Success
        text = 'Đã thanh toán'; // Or 'Thành công'
        color = Colors.green;
        break;
      case 4: // Pending
        text = 'Chờ xác nhận';
        color = Colors.orange;
        break;
      case 5: // Completed
        text = 'Hoàn thành';
        color = Colors.blue;
        break;
      case 6: // Cancelled
        text = 'Đã hủy';
        color = Colors.red;
        break;
      default:
        text = 'Không xác định';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      constraints: const BoxConstraints(maxWidth: 120), // Prevent overflow
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, OrderHistoryProvider provider) {
    final liveOrder = provider.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );
    final isEditable = liveOrder.statusId == 4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thông tin giao hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (isEditable)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                  onPressed: () => _showEditDialog(context, provider, liveOrder),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person_outline, liveOrder.customerName ?? 'Khách lẻ'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on_outlined, liveOrder.address ?? 'Chưa có địa chỉ'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.note_outlined, (liveOrder.note != null && liveOrder.note!.isNotEmpty) ? liveOrder.note! : 'Không có ghi chú'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.order.details.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final detail = widget.order.details[index];
              return Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: detail.productImageUrl != null
                        ? Image.network(
                            detail.productImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(Icons.checkroom, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.productName ?? 'Sản phẩm',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${detail.size != null ? "Size: ${detail.size}" : ""}${detail.size != null && detail.color != null ? " - " : ""}${detail.color != null ? "Màu: ${detail.color}" : ""}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'x${detail.quantity}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormat.format(detail.unitPrice * detail.quantity),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tổng cộng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            currencyFormat.format(widget.order.totalAmount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, OrderHistoryProvider provider, Order order) {
    final addressController = TextEditingController(text: order.address);
    final noteController = TextEditingController(text: order.note);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cập nhật thông tin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2933),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(addressController, 'Địa chỉ giao hàng', Icons.location_on_outlined, maxLines: 2),
                const SizedBox(height: 16),
                _buildTextField(noteController, 'Ghi chú', Icons.note_outlined, maxLines: 2),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Hủy', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                           Navigator.pop(ctx);
                           // Use OrderHistoryProvider's updateOrderInfo
                           await provider.updateOrderInfo(
                             orderId: order.id,
                             address: addressController.text.trim(),
                             note: noteController.text.trim()
                           );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0
                        ),
                        child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey[400], size: 20),
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }

}
