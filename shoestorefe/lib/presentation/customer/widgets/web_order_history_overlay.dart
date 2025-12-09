import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/order_history_provider.dart';
import '../../../../domain/entities/order.dart'; // Ensure correct import path

class WebOrderHistoryOverlay extends StatelessWidget {
  const WebOrderHistoryOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderHistoryProvider>();
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Đơn hàng của tôi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (provider.isLoading)
                    const SizedBox(
                      width: 16, 
                      height: 16, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
                      onPressed: () => provider.loadOrders(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // List
            Flexible(
              child: provider.isLoading && provider.orders.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : provider.orders.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.history, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Chưa có đơn hàng nào', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.orders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildOrderCard(provider.orders[index], provider, currencyFormat);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    Order order,
    OrderHistoryProvider provider,
    NumberFormat currencyFormat,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Slightly different bg to distinguish from overlay
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.orderNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.getStatusColor(order.statusId).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  provider.getStatusText(order.statusId),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: provider.getStatusColor(order.statusId),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(order.createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          const Divider(height: 16),

          // Items (first 2)
          ...order.details.take(2).map((detail) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                    image: detail.productImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(detail.productImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: detail.productImageUrl == null
                      ? const Icon(Icons.image, size: 16, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.productName ?? 'Sản phẩm',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'x${detail.quantity}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(detail.unitPrice * detail.quantity),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )),

          if (order.details.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                '+ ${order.details.length - 2} sản phẩm khác',
                style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ),

          const Divider(height: 16),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng tiền:', style: TextStyle(fontSize: 12)),
              Text(
                currencyFormat.format(order.totalAmount),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
