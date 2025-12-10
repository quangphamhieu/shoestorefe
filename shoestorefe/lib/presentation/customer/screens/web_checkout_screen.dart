import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added import
import 'package:shoestorefe/domain/repositories/user_repository.dart'; // Added import
import 'package:shoestorefe/injection_container.dart'; // Added import
import '../provider/checkout_provider.dart';
import '../provider/cart_provider.dart';

class WebCheckoutScreen extends StatefulWidget {
  const WebCheckoutScreen({super.key});

  @override
  State<WebCheckoutScreen> createState() => _WebCheckoutScreenState();
}

class _WebCheckoutScreenState extends State<WebCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoadingProfile = false; // Added loading state

  final currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Load data on init
  }

  // Load profile data logic from mobile CheckoutScreen
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final checkoutProvider = context.read<CheckoutProvider>();
      final userId = await checkoutProvider.getCurrentUserId(); // Assuming this method exists and is public

      // Load user profile
      final userRepo = sl<UserRepository>();
      final user = await userRepo.getById(userId);

      if (user != null && mounted) {
        // Auto-fill phone
        if (user.phone.isNotEmpty) {
           _phoneController.text = user.phone;
        }

        // Load address from SharedPreferences (same as profile screen)
        final prefs = await SharedPreferences.getInstance();
        final correctSavedAddress = prefs.getString('user_address_$userId');
        
        if (correctSavedAddress != null && correctSavedAddress.isNotEmpty) {
          _addressController.text = correctSavedAddress;
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
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
    final checkoutProvider = context.watch<CheckoutProvider>();
    final cartProvider = context.watch<CartProvider>();
    
    // Use selected items from cart
    final items = cartProvider.selectedItems; 
    final totalAmount = cartProvider.selectedTotal;

    if (items.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Chưa có sản phẩm nào được chọn để thanh toán'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Quay lại trang chủ'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Thanh toán', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/'), // Or pop
        ),
      ),
      body: _isLoadingProfile 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Form(
          key: _formKey,
          child: Center(
             child: Container(
               constraints: const BoxConstraints(maxWidth: 1200),
               child: Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // Left Column: Shipping Info (Payment Method removed)
                   Expanded(
                     flex: 2,
                     child: Column(
                       children: [
                         _buildSection(
                           title: 'Thông tin giao hàng',
                           children: [
                             _buildTextField(
                               controller: _phoneController, 
                               label: 'Số điện thoại', 
                               icon: Icons.phone_outlined,
                               validator: (v) => v!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                             ),
                             const SizedBox(height: 16),
                             _buildTextField(
                               controller: _addressController, 
                               label: 'Địa chỉ nhận hàng', 
                               icon: Icons.location_on_outlined,
                               maxLines: 2,
                               validator: (v) => v!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                             ),
                             const SizedBox(height: 16),
                             _buildTextField(
                               controller: _noteController, 
                               label: 'Ghi chú đơn hàng (Tùy chọn)', 
                               icon: Icons.note_outlined,
                               maxLines: 2,
                             ),
                           ],
                         ),
                         // Payment Method Section Removed
                       ],
                     ),
                   ),
                   const SizedBox(width: 32),
                   
                   // Right Column: Order Summary
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
                           const Text('Đơn hàng của bạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                           const SizedBox(height: 24),
                           ListView.separated(
                             shrinkWrap: true,
                             physics: const NeverScrollableScrollPhysics(),
                             itemCount: items.length,
                             separatorBuilder: (_, __) => const Divider(height: 24),
                             itemBuilder: (context, index) {
                               final item = items[index];
                               final product = cartProvider.getProduct(item.productId);
                               return Row(
                                 children: [
                                   Container(
                                     width: 50,
                                     height: 50,
                                     decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                        image: product?.imageUrl != null 
                                          ? DecorationImage(image: NetworkImage(product!.imageUrl!), fit: BoxFit.cover)
                                          : null
                                     ),
                                   ),
                                   const SizedBox(width: 12),
                                   Expanded(
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Text(product?.name ?? 'Sản phẩm', style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                                         Text('${item.quantity} x ${currencyFormat.format(item.unitPrice)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                         if (product?.size != null || product?.color != null)
                                            Text(
                                              '${product?.size ?? ''} - ${product?.color ?? ''}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                            ),
                                       ],
                                     ),
                                   ),
                                   Text(currencyFormat.format(item.unitPrice * item.quantity), style: const TextStyle(fontWeight: FontWeight.bold)),
                                 ],
                               );
                             },
                           ),
                           const Divider(height: 32, thickness: 1),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               const Text('Tổng cộng', style: TextStyle(fontSize: 16)),
                               Text(currencyFormat.format(totalAmount), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                             ],
                           ),
                           const SizedBox(height: 32),
                           SizedBox(
                             width: double.infinity,
                             child: ElevatedButton(
                               onPressed: checkoutProvider.isLoading 
                                 ? null 
                                 : () async {
                                    if (_formKey.currentState!.validate()) {
                                      final success = await checkoutProvider.createOrder(
                                        cartItems: items,
                                        phone: _phoneController.text.trim(),
                                        address: _addressController.text.trim(),
                                        note: _noteController.text.trim(),
                                      );
                                      
                                      if (success && mounted) {
                                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đặt hàng thành công!"), backgroundColor: Colors.green));
                                         
                                         context.read<CartProvider>().removeSelectedItems();
                                         
                                         context.go('/');
                                      } else if (mounted) {
                                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(checkoutProvider.error ?? "Có lỗi xảy ra"), backgroundColor: Colors.red));
                                      }
                                    }
                                 },
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: const Color(0xFFE53935),
                                 foregroundColor: Colors.white,
                                 padding: const EdgeInsets.symmetric(vertical: 20),
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                               ),
                               child: checkoutProvider.isLoading 
                                 ? const CircularProgressIndicator(color: Colors.white)
                                 : const Text('ĐẶT HÀNG NGAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                             ),
                           ),
                         ],
                       ),
                     ),
                   )
                 ],
               ),
             ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
