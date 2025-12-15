import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoestorefe/presentation/customer/provider/cart_provider.dart';
import 'package:shoestorefe/presentation/customer/provider/checkout_provider.dart';
import 'package:shoestorefe/domain/repositories/user_repository.dart';
import 'package:shoestorefe/domain/entities/cart_item.dart';
import 'package:shoestorefe/injection_container.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final checkoutProvider = context.read<CheckoutProvider>();
      final userId = await checkoutProvider.getCurrentUserId();

      // Load user profile
      final userRepo = sl<UserRepository>();
      final user = await userRepo.getById(userId);

      if (user != null && mounted) {
        _phoneController.text = user.phone ?? '';

        // Load address from SharedPreferences (same as profile screen)
        final prefs = await SharedPreferences.getInstance();
        final savedAddress = prefs.getString('user_address_$userId') ?? '';
        _addressController.text = savedAddress;
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final checkoutProvider = context.watch<CheckoutProvider>();
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    final directBuy = checkoutProvider.directBuyProduct;
    final isDirectBuy = directBuy != null;

    final List<CartItem> selectedItems =
        isDirectBuy
            ? []
            : (cartProvider.selectedItems.isNotEmpty
                ? cartProvider.selectedItems
                : cartProvider.cart?.items ?? []);

    final total =
        isDirectBuy
            ? (directBuy['unitPrice'] as double) *
                (directBuy['quantity'] as int)
            : selectedItems.fold<double>(
              0,
              (sum, item) => sum + (item.unitPrice * item.quantity),
            );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Thanh Toán',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          
          if (isWide) {
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3, 
                      child: SingleChildScrollView(
                        child: _buildContactForm()
                      )
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2, 
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildOrderSummary(
                              selectedItems, 
                              isDirectBuy, 
                              directBuy, 
                              total, 
                              cartProvider, 
                              currencyFormat
                            ),
                            const SizedBox(height: 24),
                            _buildSubmitButton(
                              context, 
                              checkoutProvider, 
                              cartProvider, 
                              selectedItems, 
                              isDirectBuy, 
                              directBuy
                            ),
                          ],
                        )
                      )
                    ),
                  ],
                ),
              ),
            );
          }
          
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildContactForm(),
                _buildOrderSummary(
                  selectedItems, 
                  isDirectBuy, 
                  directBuy, 
                  total, 
                  cartProvider, 
                  currencyFormat
                ),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) return const SizedBox.shrink(); // Hide bottom bar on wide screens (button moved to right col)
          
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
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: _buildSubmitButton(
                  context, 
                  checkoutProvider, 
                  cartProvider, 
                  selectedItems, 
                  isDirectBuy, 
                  directBuy
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin liên hệ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Số điện thoại *',
              hintText: '0912345678',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Địa chỉ giao hàng *',
              hintText: 'Số nhà, đường, phường, quận, thành phố',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Ghi chú (tùy chọn)',
              hintText: 'Ghi chú cho đơn hàng',
              prefixIcon: const Icon(Icons.note_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(
    List<CartItem> selectedItems,
    bool isDirectBuy,
    Map<String, dynamic>? directBuy,
    double total,
    CartProvider cartProvider,
    NumberFormat currencyFormat,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đơn hàng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (isDirectBuy)
            _buildDirectBuyProductItem(directBuy!, currencyFormat)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedItems.length,
              separatorBuilder: (_, __) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final item = selectedItems[index];
                final product = cartProvider.getProduct(item.productId);
                return _buildCartItemRow(item, product, currencyFormat);
              },
            ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                currencyFormat.format(total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemRow(CartItem item, dynamic product, NumberFormat currencyFormat) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
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
              ? Icon(Icons.image, color: Colors.grey[400])
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product?.name ?? 'Product',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'x${item.quantity}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          currencyFormat.format(item.unitPrice * item.quantity),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDirectBuyProductItem(
    Map<String, dynamic> product,
    NumberFormat currencyFormat,
  ) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            image: product['imageUrl'] != null
                ? DecorationImage(
                    image: NetworkImage(product['imageUrl']!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: product['imageUrl'] == null
              ? Icon(Icons.image, color: Colors.grey[400])
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['productName'] ?? 'Product',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'x${product['quantity']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Text(
          currencyFormat.format(
            (product['unitPrice'] as double) * (product['quantity'] as int),
          ),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    CheckoutProvider checkoutProvider,
    CartProvider cartProvider,
    List<CartItem> selectedItems,
    bool isDirectBuy,
    Map<String, dynamic>? directBuy,
  ) {
    return ElevatedButton(
      onPressed: checkoutProvider.isLoading
          ? null
          : () async {
              if (_phoneController.text.trim().isEmpty ||
                  _addressController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng điền đầy đủ thông tin'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final List<CartItem> orderItems;
              if (isDirectBuy) {
                orderItems = [
                  CartItem(
                    id: 0,
                    productId: directBuy!['productId'] as int,
                    quantity: directBuy['quantity'] as int,
                    unitPrice: directBuy['unitPrice'] as double,
                  ),
                ];
              } else {
                orderItems = selectedItems;
              }

              final success = await checkoutProvider.createOrder(
                cartItems: orderItems,
                phone: _phoneController.text.trim(),
                address: _addressController.text.trim(),
                note: _noteController.text.trim(),
              );

              if (success && mounted) {
                if (isDirectBuy) {
                  checkoutProvider.clearDirectBuyProduct();
                } else {
                  await cartProvider.removeSelectedItems();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đặt hàng thành công!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Navigate to orders instead of popping? OR pop to home then orders?
                // Context.go('/orders') might replace stack.
                context.go('/orders'); 
              } else if (mounted && checkoutProvider.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(checkoutProvider.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
      ),
      child: checkoutProvider.isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Đặt Hàng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
