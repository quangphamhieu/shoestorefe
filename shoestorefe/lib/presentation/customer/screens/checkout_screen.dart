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

        print(
          '[CheckoutScreen] Loaded profile - Phone: ${user.phone}, Address: $savedAddress',
        );
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

    // Check if this is direct buy mode (MUA NGAY)
    final directBuy = checkoutProvider.directBuyProduct;
    final isDirectBuy = directBuy != null;

    // Use direct buy product or cart items
    final List<CartItem> selectedItems =
        isDirectBuy
            ? [] // No cart items in direct buy mode
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

    print(
      '[CheckoutScreen] Mode: ${isDirectBuy ? "Direct Buy" : "Cart"}, Items: ${isDirectBuy ? 1 : selectedItems.length}, Total: $total',
    );

    // Debug: Print items
    if (isDirectBuy) {
      print(
        '[CheckoutScreen] Direct Buy: ProductID=${directBuy['productId']}, Qty=${directBuy['quantity']}, Price=${directBuy['unitPrice']}',
      );
    } else {
      for (var item in selectedItems) {
        print(
          '[CheckoutScreen] Cart Item ${item.id}: ProductID=${item.productId}, Qty=${item.quantity}, Price=${item.unitPrice}',
        );
      }
    }

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Contact Information
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại *',
                      hintText: '0912345678',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Địa chỉ giao hàng *',
                      hintText: 'Số nhà, đường, phường, quận, thành phố',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Ghi chú (tùy chọn)',
                      hintText: 'Ghi chú cho đơn hàng',
                      prefixIcon: const Icon(Icons.note_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Order Summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Show direct buy product or cart items
                  if (isDirectBuy)
                    _buildDirectBuyProductItem(directBuy!, currencyFormat)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 20),
                      itemBuilder: (context, index) {
                        final item = selectedItems[index];
                        final product = cartProvider.getProduct(item.productId);

                        return Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                image:
                                    product?.imageUrl != null
                                        ? DecorationImage(
                                          image: NetworkImage(
                                            product!.imageUrl!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              ),
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
                              currencyFormat.format(
                                item.unitPrice * item.quantity,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
            child: ElevatedButton(
              onPressed:
                  checkoutProvider.isLoading
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

                        // Prepare cart items (direct buy or from cart)
                        final List<CartItem> orderItems;
                        if (isDirectBuy) {
                          // Create temporary CartItem for direct buy
                          orderItems = [
                            CartItem(
                              id: 0, // Temporary ID
                              productId: directBuy['productId'] as int,
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
                          // Clear direct buy or remove cart items
                          if (isDirectBuy) {
                            checkoutProvider.clearDirectBuyProduct();
                          } else {
                            await cartProvider.removeSelectedItems();
                          }

                          // Show success and navigate
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đặt hàng thành công!'),
                              backgroundColor: Colors.green,
                            ),
                          );
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
                elevation: 0,
              ),
              child:
                  checkoutProvider.isLoading
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
            ),
          ),
        ),
      ),
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
            image:
                product['imageUrl'] != null
                    ? DecorationImage(
                      image: NetworkImage(product['imageUrl']!),
                      fit: BoxFit.cover,
                    )
                    : null,
          ),
          child:
              product['imageUrl'] == null
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
}
