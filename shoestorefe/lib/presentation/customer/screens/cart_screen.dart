import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shoestorefe/presentation/customer/provider/cart_provider.dart';
import 'package:shoestorefe/presentation/customer/widgets/customer_bottom_nav.dart';
import 'package:shoestorefe/domain/entities/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Giỏ Hàng',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (provider.cart != null && provider.cart!.items.isNotEmpty)
            TextButton(
              onPressed: () {
                final allSelected = provider.cart!.items.every(
                  (item) => provider.isSelected(item.id),
                );
                provider.selectAll(!allSelected);
              },
              child: Text(
                provider.cart!.items.every(
                      (item) => provider.isSelected(item.id),
                    )
                    ? 'Bỏ chọn'
                    : 'Chọn tất cả',
                style: const TextStyle(color: Colors.black),
              ),
            ),
        ],
      ),
      body:
          provider.isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
              : provider.cart == null || provider.cart!.items.isEmpty
              ? _buildEmptyCart()
              : _buildCartList(provider, currencyFormat),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (provider.cart != null && provider.cart!.items.isNotEmpty)
            _buildCheckoutBar(provider, currencyFormat),
          const CustomerBottomNav(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(CartProvider provider, NumberFormat currencyFormat) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.cart!.items.length,
      itemBuilder: (context, index) {
        final item = provider.cart!.items[index];
        final product = provider.getProduct(item.productId);

        return _buildCartItem(item, product, provider, currencyFormat);
      },
    );
  }

  Widget _buildCartItem(
    CartItem item,
    dynamic product,
    CartProvider provider,
    NumberFormat currencyFormat,
  ) {
    final isSelected = provider.isSelected(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: isSelected,
              onChanged: (value) {
                provider.toggleSelection(item.id);
              },
              activeColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),

            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                image:
                    product?.imageUrl != null
                        ? DecorationImage(
                          image: NetworkImage(product!.imageUrl!),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  product?.imageUrl == null
                      ? Icon(Icons.image, color: Colors.grey[400])
                      : null,
            ),
            const SizedBox(width: 12),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?.name ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product != null)
                    Text(
                      '${product.color} - Size ${product.size}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(item.unitPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildQuantityControl(item, provider),
                ],
              ),
            ),

            // Delete Button
            IconButton(
              onPressed: () {
                _showDeleteConfirmation(context, item, provider);
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl(CartItem item, CartProvider provider) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (item.quantity > 1) {
                provider.updateQuantity(item.id, item.quantity - 1);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.remove,
                size: 16,
                color: item.quantity > 1 ? Colors.black : Colors.grey[400],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          InkWell(
            onTap: () {
              provider.updateQuantity(item.id, item.quantity + 1);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.add, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(CartProvider provider, NumberFormat currencyFormat) {
    final hasSelection = provider.selectedItems.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tổng cộng',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(provider.selectedTotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed:
                  hasSelection
                      ? () {
                        context.push('/checkout');
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasSelection ? Colors.black : Colors.grey[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Thanh toán (${provider.selectedItems.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    CartItem item,
    CartProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa sản phẩm'),
            content: const Text(
              'Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  provider.removeItem(item.id);
                  Navigator.pop(context);
                },
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
