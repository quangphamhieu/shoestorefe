import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shoestorefe/presentation/admin/provider/order_provider.dart';
import 'package:shoestorefe/domain/entities/order.dart';

class WebOrderDetailScreen extends StatefulWidget {
  final Order order;
  const WebOrderDetailScreen({super.key, required this.order});

  @override
  State<WebOrderDetailScreen> createState() => _WebOrderDetailScreenState();
}

class _WebOrderDetailScreenState extends State<WebOrderDetailScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  late Order _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  void _manualUpdateOrder({String? address, String? note, int? statusId}) {
    setState(() {
      _currentOrder = Order(
        id: _currentOrder.id,
        orderNumber: _currentOrder.orderNumber,
        customerId: _currentOrder.customerId,
        customerName: _currentOrder.customerName,
        createdBy: _currentOrder.createdBy,
        creatorName: _currentOrder.creatorName,
        storeId: _currentOrder.storeId,
        storeName: _currentOrder.storeName,
        statusId: statusId ?? _currentOrder.statusId,
        totalAmount: _currentOrder.totalAmount,
        orderType: _currentOrder.orderType,
        paymentMethod: _currentOrder.paymentMethod,
        createdAt: _currentOrder.createdAt,
        updatedAt: DateTime.now(),
        address: address ?? _currentOrder.address,
        note: note ?? _currentOrder.note,
        details: _currentOrder.details,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Reuse OrderProvider for update logic (shared with Admin/Mobile)
    final provider = context.watch<OrderProvider>(); 
    
    // Prioritize provider data if it exists (for external updates), otherwise local state
    // Note: If provider update fails to update list logic (e.g. list empty), local state handles it.
    // However, to ensure "instant" update from OUR actions, we use _currentOrder which we update manually.
    // Actually, let's stick to _currentOrder as the source of truth for this view, 
    // but listen to provider changes if they affect this order.
    
    // Merging logic: 
    // If provider has this order, use it. IF NOT, use _currentOrder.
    // But when we update, we update _currentOrder immediately.
    
    // Better: Just use local _currentOrder and update it. 
    // If we want real-time sync with other devices, we'd need more complex logic.
    // For now, "DB updates -> UI updates instantly" is solved by manual local update.

    final isEditable = _currentOrder.statusId == 3 || _currentOrder.statusId == 4 || _currentOrder.statusId == 5; // Paid, Pending, Confirmed
    final isCancelled = _currentOrder.statusId == 6; // Cancelled

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Order #, Date, Status, Actions)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Đơn hàng ${_currentOrder.orderNumber}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                           const SizedBox(height: 8),
                           Text('Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(_currentOrder.createdAt)}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        ],
                      ),
                      Row(
                        children: [
                          _buildStatusBadge(_currentOrder.statusId),
                          const SizedBox(width: 16),
                          // Action Buttons
                          if (isEditable)
                            ElevatedButton.icon(
                              onPressed: () => _cancelOrder(context, provider),
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text('Hủy đơn'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          if (isCancelled)
                            ElevatedButton.icon(
                              onPressed: () => _restoreOrder(context, provider),
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Đặt lại (Khôi phục)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Items
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sản phẩm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 24),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _currentOrder.details.length,
                              separatorBuilder: (_, __) => const Divider(height: 32),
                              itemBuilder: (context, index) {
                                final detail = _currentOrder.details[index];
                                return Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: detail.productImageUrl != null
                                          ? Image.network(detail.productImageUrl!, fit: BoxFit.cover)
                                          : const Icon(Icons.image, color: Colors.grey),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(detail.productName ?? 'Sản phẩm', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 4),
                                          Text('${detail.size != null ? "Size: ${detail.size}" : ""}${detail.size != null && detail.color != null ? " - " : ""}${detail.color != null ? "Màu: ${detail.color}" : ""}', style: TextStyle(color: Colors.grey[600])),
                                          const SizedBox(height: 4),
                                          Text('Số lượng: ${detail.quantity}', style: TextStyle(color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                    Text(currencyFormat.format(detail.unitPrice * detail.quantity), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                );
                              },
                            ),
                            const Divider(height: 48),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tổng cộng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(currencyFormat.format(_currentOrder.totalAmount), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    
                    // Shipping Info
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Thông tin giao hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                // Edit button only if pending (4)
                                if (isEditable)
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showEditDialog(context, provider),
                                    tooltip: 'Chỉnh sửa',
                                  )
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildInfoRow(Icons.person, 'Người nhận', _currentOrder.customerName ?? 'Khách lẻ'),
                            const SizedBox(height: 16),
                            _buildInfoRow(Icons.location_on, 'Địa chỉ', _currentOrder.address ?? 'Chưa cập nhật'),
                            const SizedBox(height: 16),
                            _buildInfoRow(Icons.note, 'Ghi chú', (_currentOrder.note != null && _currentOrder.note!.isNotEmpty) ? _currentOrder.note! : 'Không có'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(int statusId) {
    String text;
    Color color;
    switch (statusId) {
      case 3: text = 'Đã thanh toán'; color = Colors.green; break;
      case 4: text = 'Chờ xác nhận'; color = Colors.orange; break;
      case 5: text = 'Hoàn thành'; color = Colors.blue; break;
      case 6: text = 'Đã hủy'; color = Colors.red; break;
      default: text = 'Không xác định'; color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, OrderProvider provider) {
    final addressController = TextEditingController(text: _currentOrder.address);
    final noteController = TextEditingController(text: _currentOrder.note);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cập nhật thông tin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ nhận hàng',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.note_outlined),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                     final newAddress = addressController.text.trim();
                     final newNote = noteController.text.trim();
                     
                     // Optimistic UI Update or Wait? User wants instant.
                     // But we should allow provider to call api.
                     Navigator.pop(ctx);
                     
                     final success = await provider.updateOrderInfo(
                       orderId: _currentOrder.id,
                       address: newAddress,
                       note: newNote
                     );

                     if (success) {
                       _manualUpdateOrder(address: newAddress, note: newNote);
                       if (mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công'), backgroundColor: Colors.green));
                       }
                     } else {
                       if (mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại'), backgroundColor: Colors.red));
                       }
                     }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('LƯU THAY ĐỔI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _cancelOrder(BuildContext context, OrderProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Có, Hủy', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    
    if (confirmed == true) {
      // 6 = Cancelled
      final success = await provider.updateStatusUseCase.call(orderId: _currentOrder.id, statusId: 6);
      if (success && mounted) {
        _manualUpdateOrder(statusId: 6);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy đơn hàng'), backgroundColor: Colors.orange));
        // Need to update list in provider if possible, but manual update handles UI
        provider.loadAll(); // Optional: Refresh list in background
      }
    }
  }

  void _restoreOrder(BuildContext context, OrderProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đặt lại'),
        content: const Text('Bạn có muốn khôi phục đơn hàng này về trạng thái chờ xác nhận?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đồng ý', style: TextStyle(color: Colors.green))),
        ],
      ),
    );

    if (confirmed == true) {
      // 4 = Pending
      final success = await provider.updateStatusUseCase.call(orderId: _currentOrder.id, statusId: 4);
      if (success && mounted) {
        _manualUpdateOrder(statusId: 4);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã khôi phục đơn hàng'), backgroundColor: Colors.green));
        provider.loadAll();
      }
    }
  }
}
