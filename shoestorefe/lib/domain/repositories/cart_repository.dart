import 'package:shoestorefe/domain/entities/cart.dart';

abstract class CartRepository {
  Future<Cart> getCartByUserId();
  Future<void> addItemToCart(int productId,int quantity);
  Future<void> updateItemQuantity(int cartItemId,int quantity);
  Future<void> removeItemFromCart(int cartItemId);
  Future<void> clearCart();

}