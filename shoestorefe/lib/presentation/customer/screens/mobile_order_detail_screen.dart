import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shoestorefe/presentation/customer/provider/order_history_provider.dart';
import 'package:shoestorefe/presentation/admin/provider/order_provider.dart';
import 'package:shoestorefe/domain/entities/order.dart';

class MobileOrderDetailScreen extends StatefulWidget {
  final Order order;
  const MobileOrderDetailScreen({super.key, required this.order});

  @override
  State<MobileOrderDetailScreen> createState() => _MobileOrderDetailScreenState();
}

class _MobileOrderDetailScreenState extends State<MobileOrderDetailScreen> {
  Order? _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  // Safe currency formatter that falls back to default if locale data is missing
  NumberFormat get _currencyFormat {
    try {
      return NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    } catch (e) {
      // Fallback if locale data is not available
      return NumberFormat.currency(symbol: '₫', decimalDigits: 0);
    }
  }

  void _manualUpdateLocalState(Order baseOrder, {String? address, String? note, int? statusId}) {
    setState(() {
      _currentOrder = Order(
        id: baseOrder.id,
        orderNumber: baseOrder.orderNumber,
        customerId: baseOrder.customerId,
        customerName: baseOrder.customerName,
        createdBy: baseOrder.createdBy,
        creatorName: baseOrder.creatorName,
        storeId: baseOrder.storeId,
        storeName: baseOrder.storeName,
        statusId: statusId ?? baseOrder.statusId,
        totalAmount: baseOrder.totalAmount,
        orderType: baseOrder.orderType,
        paymentMethod: baseOrder.paymentMethod,
        createdAt: baseOrder.createdAt,
        updatedAt: DateTime.now(),
        address: address ?? baseOrder.address,
        note: note ?? baseOrder.note,
        details: baseOrder.details,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ultimate safety: Wrap the entire build in try-catch to prevent "Gray Screen of Death"
    try {
      OrderHistoryProvider? provider;
      try {
        provider = context.watch<OrderHistoryProvider>();
      } catch (_) {
        // Provider not found, acceptable to be null
      }

      final currencyFormat = _currencyFormat;
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

      // 1. Start with widget.order (cleanest)
      // 2. Override with local optimistic state (_currentOrder) if exists
      // 3. Override with Live Provider data if found (Best source of truth)
      
      Order displayOrder = _currentOrder ?? widget.order;

      if (provider != null && provider.orders.isNotEmpty) {
        try {
          // Try to find updated data from provider
          final foundLive = provider.orders.firstWhere((o) => o.id == widget.order.id);
          displayOrder = foundLive;
          // Sync local state to live state to keep them consistent
          if (_currentOrder != foundLive) {
             _currentOrder = foundLive;
          }
        } catch (_) {
          // Not found in provider (maybe loading?), keep using current optimistic state
        }
      }

      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Chi tiết đơn hàng',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(displayOrder, provider, dateFormat),
                    const SizedBox(height: 16),
                    _buildInfoSection(context, displayOrder, provider),
                    const SizedBox(height: 16),
                    _buildProductList(displayOrder, currencyFormat),
                    const SizedBox(height: 16),
                    _buildTotalSection(displayOrder, currencyFormat),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      // If ANY error occurs, show it on screen instead of gray screen
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Lỗi hiển thị: $e\n\n$stackTrace",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }
  }

  // ... (Methods _buildHeader, _buildStatusWidget, _buildSimpleStatus, _buildInfoSection, _buildInfoRow, _buildProductList, _buildTotalSection remain technically unchanged but need to be careful with replace range)
  // Since I am replacing the TOP part of the file including build method, I assume the rest are below.
  
  // Wait, I need to verify where _showEditDialog is to update it.
  // It is likely further down. I'll split this into two edits if needed, or replace a larger chunk.
  // The replace tool works best with contiguous blocks.
  // I will replace from "class _MobileOrderDetailScreenState" down to the end of "build" method.



  Widget _buildHeader(Order liveOrder, OrderHistoryProvider? provider, DateFormat dateFormat) {
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
              Expanded(
                child: Text(
                  'Đơn hàng ${liveOrder.orderNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (provider != null)
                _buildStatusWidget(liveOrder.statusId, provider)
              else
                _buildSimpleStatus(liveOrder.statusId),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ngày đặt: ${dateFormat.format(liveOrder.createdAt)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusWidget(int statusId, OrderHistoryProvider provider) {
    final text = provider.getStatusText(statusId);
    final color = provider.getStatusColor(statusId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildSimpleStatus(int statusId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '...',
        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, Order liveOrder, OrderHistoryProvider? provider) {
    final isEditable = liveOrder.statusId == 3 || liveOrder.statusId == 4 || liveOrder.statusId == 5; // Paid, Pending, Confirmed
    final isCancellable = isEditable; // Same condition for now

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
              if (isEditable && provider != null)
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
          if (isCancellable && provider != null) ..[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _cancelOrder(context, provider, liveOrder),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Hủy đơn hàng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
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
            style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildProductList(Order liveOrder, NumberFormat currencyFormat) {
    final details = liveOrder.details;

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
          if (details.isEmpty)
             const Text('Không có thông tin sản phẩm', style: TextStyle(color: Colors.grey))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: details.length,
              separatorBuilder: (_, __) => const Divider(height: 24, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                final detail = details[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: detail.productImageUrl != null && detail.productImageUrl!.isNotEmpty
                          ? Image.network(
                              detail.productImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
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
                            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currencyFormat.format(detail.unitPrice * detail.quantity),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(Order liveOrder, NumberFormat currencyFormat) {
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
            currencyFormat.format(liveOrder.totalAmount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
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
                        child: Text('Hủy', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                           final newAddress = addressController.text.trim();
                           final newNote = noteController.text.trim();
                           
                           Navigator.pop(ctx);
                           
                           // Use OrderHistoryProvider's updateOrderInfo
                           final success = await provider.updateOrderInfo(
                             orderId: order.id,
                             address: newAddress,
                             note: newNote
                           );

                           if (success && mounted) {
                              _manualUpdateLocalState(address: newAddress, note: newNote);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cập nhật thành công'), backgroundColor: Colors.green)
                              );
                           } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cập nhật thất bại'), backgroundColor: Colors.red)
                              );
                           }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey[400], size: 20),
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ),
    );
  }

  void _cancelOrder(BuildContext context, OrderHistoryProvider provider, Order order) async {
    final orderProvider = context.read<OrderProvider>();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận hủy đơn'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
            ),
            child: const Text('Có, Hủy đơn'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Status 6 = Cancelled
      final success = await orderProvider.updateStatusUseCase.call(
        orderId: order.id,
        statusId: 6,
      );

      if (success && mounted) {
        // Update local state
        _manualUpdateLocalState(order, statusId: 6);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy đơn hàng thành công'),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể hủy đơn hàng'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
