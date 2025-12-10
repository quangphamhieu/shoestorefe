import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../provider/cart_provider.dart';
import '../../../../domain/entities/cart_item.dart';

class WebCartOverlay extends StatelessWidget {
  const WebCartOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // Force cart reload or check? 
    // The provider should be available.
    // If not loaded, maybe load?
    // context.read<CartProvider>().loadCart(); // Better do this in parent or on open.

    final provider = context.watch<CartProvider>();
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
        width: 350,
        constraints: const BoxConstraints(maxHeight: 500),
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
                  Text(
                    'Giỏ hàng (${provider.cart?.items.length ?? 0})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // List
            Flexible(
              child: provider.isLoading
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ))
                  : provider.cart == null || provider.cart!.items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Giỏ hàng trống', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.separated( // removed shrinkWrap to allow scrolling in Flexible
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.cart!.items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = provider.cart!.items[index];
                            final product = provider.getProduct(item.productId);
                            return _buildCartItem(context, item, product, provider, currencyFormat);
                          },
                        ),
            ),
            
            const Divider(height: 1),
            
            // Footer (Total & Checkout)
            if (provider.cart != null && provider.cart!.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng cộng:', style: TextStyle(color: Colors.grey)),
                        Text(
                          currencyFormat.format(provider.selectedTotal > 0 ? provider.selectedTotal : 0), // Should we show total of ALL items or selected? Usually cart popup shows total.
                          // But CartProvider has selectedTotal.
                          // Let's assume user wants to buy selected. But initially maybe none selected?
                          // Let's rely on provider state.
                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Ensure items are selected?
                          // If not, maybe select all?
                          if (provider.selectedItems.isEmpty) {
                             provider.selectAll(true);
                          }
                          context.go('/web-checkout');
                          // Close overlay? handled by parent usually (click outside)
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Thanh toán ngay'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    dynamic product,
    CartProvider provider,
    NumberFormat currencyFormat,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Checkbox
        Checkbox(
          value: provider.isSelected(item.id),
          onChanged: (_) => provider.toggleSelection(item.id),
          activeColor: Colors.black,
        ),
        
        // Image
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            image: product?.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(product!.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: product?.imageUrl == null
              ? const Icon(Icons.image, color: Colors.grey, size: 20)
              : null,
        ),
        const SizedBox(width: 12),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product?.name ?? 'Loading...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              if (product?.size != null || product?.color != null)
                Text(
                  '${product?.size ?? ''} ${product?.color != null ? "- ${product!.color}" : ""}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              Text(
                currencyFormat.format(item.unitPrice),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        
        // Quantity
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => provider.updateQuantity(item.id, item.quantity - 1),
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('${item.quantity}', style: const TextStyle(fontSize: 13)),
            ),
             IconButton(
              onPressed: () => provider.updateQuantity(item.id, item.quantity + 1),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
          ],
        ),
        
        const SizedBox(width: 8),

        // Delete
        IconButton(
          onPressed: () => provider.removeItem(item.id),
          icon: const Icon(Icons.close, size: 16, color: Colors.grey),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
