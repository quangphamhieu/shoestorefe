import 'package:flutter/material.dart';
import 'package:shoestorefe/domain/entities/cart_item.dart';
import 'package:shoestorefe/domain/repositories/order_repository.dart';
import 'package:shoestorefe/core/network/token_handler.dart';

class CheckoutProvider extends ChangeNotifier {
  final OrderRepository orderRepository;

  CheckoutProvider({required this.orderRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int? _createdOrderId;
  int? get createdOrderId => _createdOrderId;

  // Direct buy product (for "MUA NGAY" button)
  Map<String, dynamic>? _directBuyProduct;
  Map<String, dynamic>? get directBuyProduct => _directBuyProduct;

  Future<bool> createOrder({
    required List<CartItem> cartItems,
    required String phone,
    required String address,
    String? note,
  }) async {
    if (cartItems.isEmpty) {
      _error = 'Giỏ hàng trống';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current user ID from token
      final userId = await _getCurrentUserId();

      // Prepare order details from cart items
      final orderDetails =
          cartItems
              .map(
                (item) => {
                  'productId': item.productId,
                  'quantity': item.quantity,
                },
              )
              .toList();

      // Create order
      // Note: Backend expects OrderCreateDto structure
      // Backend enum: OrderType { Online = 0, Offline = 1 }
      // Backend enum: PaymentMethod { Cash = 0, Transfer = 1 }
      final order = await orderRepository.create(
        customerId: userId,
        orderType: 0, // Online order (enum OrderType.Online = 0)
        paymentMethod: 0, // Cash/COD (enum PaymentMethod.Cash = 0)
        storeId: null, // Online orders don't need storeId
        details: orderDetails,
      );
      _createdOrderId = order.id;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Đặt hàng thất bại: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<int> _getCurrentUserId() async {
    final userIdStr = TokenHandler().getUserId();

    if (userIdStr == null) {
      throw Exception('User not authenticated');
    }

    return int.parse(userIdStr);
  }

  // Make this public for CheckoutScreen
  Future<int> getCurrentUserId() async {
    return _getCurrentUserId();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set direct buy product for "MUA NGAY" flow
  void setDirectBuyProduct({
    required int productId,
    required String productName,
    required double unitPrice,
    required int quantity,
    String? imageUrl,
  }) {
    _directBuyProduct = {
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
    print(
      '[CheckoutProvider] setDirectBuyProduct: ProductID=$productId, Name=$productName, Price=$unitPrice, Quantity=$quantity',
    );
    notifyListeners();
  }

  // Clear direct buy product
  void clearDirectBuyProduct() {
    _directBuyProduct = null;
    notifyListeners();
  }
}
