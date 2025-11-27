import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remote;

  CartRepositoryImpl(this.remote);

  @override
  Future<Cart> getCartByUserId() async {
    try {
      final CartModel cartModel = await remote.getCart();
      return cartModel;
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  @override
  Future<void> addItemToCart(int productId, int quantity) async {
    try {
      final requestBody = {
        'productId': productId,
        'quantity': quantity,
      };
      print("Request Body: $requestBody");
      await remote.addToCart(requestBody);
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  @override
  Future<void> updateItemQuantity(int cartItemId, int quantity) async {
    try {
      final requestBody = {
        'cartItemId': cartItemId,
        'quantity': quantity,
      };
      await remote.updateQuantity(requestBody);
    } catch (e) {
      throw Exception('Failed to update item quantity: $e');
    }
  }

  @override
  Future<void> removeItemFromCart(int cartItemId) async {
    try {
      await remote.removeItem(cartItemId);
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await remote.clearCart();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}
