import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../models/cart_model.dart';

class CartRemoteDataSource {
  final ApiClient client;

  CartRemoteDataSource(this.client);

  /// Lấy giỏ hàng hiện tại của user
  Future<CartModel> getCart() async {
    final response = await client.get("${ApiEndpoint.cart}/getCart");

    if (response.data is Map<String, dynamic>) {
      return CartModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw Exception('Invalid cart response format');
  }

  /// Thêm sản phẩm vào giỏ hàng
  Future<void> addToCart(Map<String, dynamic> requestBody) async {
    final response = await client.post(
      "${ApiEndpoint.cart}/add",
      requestBody,
    );

    // API chỉ cần trả success, không cần parse cart
    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception('Invalid add-to-cart response format');
  }

  /// Cập nhật số lượng sản phẩm
  Future<void> updateQuantity(Map<String, dynamic> requestBody) async {
    final response = await client.put(
      "${ApiEndpoint.cart}/update",
      requestBody,
    );

    if (response.statusCode == 200) {
      return;
    }

    throw Exception('Invalid update-quantity response format');
  }

  /// Xóa 1 item khỏi giỏ hàng
  Future<void> removeItem(int cartItemId) async {
    final response = await client.delete(
      '${ApiEndpoint.cart}/remove/$cartItemId',
    );

    if (response.statusCode == 200) {
      return;
    }

    throw Exception('Invalid remove-item response format');
  }

  /// Xóa toàn bộ giỏ hàng
  Future<void> clearCart() async {
    final response = await client.delete("${ApiEndpoint.cart}/clear");

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception('Failed to clear cart');
  }
}
