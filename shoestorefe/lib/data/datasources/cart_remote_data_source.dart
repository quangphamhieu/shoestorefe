import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../models/cart_model.dart';

class CartRemoteDataSource {
  final ApiClient client;

  CartRemoteDataSource(this.client);

  /// Lấy giỏ hàng hiện tại của user
  Future<CartModel> getCart() async {
    print(
      '[CartRemoteDataSource] 🔍 Fetching cart from: ${ApiEndpoint.cart}/getCart',
    );

    try {
      final response = await client.get("${ApiEndpoint.cart}/getCart");

      print('[CartRemoteDataSource] ✅ Response status: ${response.statusCode}');
      print(
        '[CartRemoteDataSource] 📦 Response type: ${response.data.runtimeType}',
      );
      print('[CartRemoteDataSource] 📦 Response data: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        final cart = CartModel.fromJson(response.data as Map<String, dynamic>);
        print(
          '[CartRemoteDataSource] ✅ Parsed cart with ${cart.items.length} items',
        );
        return cart;
      }

      print('[CartRemoteDataSource] ❌ Invalid response format - not a Map');
      throw Exception('Invalid cart response format');
    } catch (e, stackTrace) {
      print('[CartRemoteDataSource] ❌ Error fetching cart: $e');
      print('[CartRemoteDataSource] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Thêm sản phẩm vào giỏ hàng
  Future<void> addToCart(Map<String, dynamic> requestBody) async {
    print('[CartRemoteDataSource] 🛒 Adding to cart with body: $requestBody');

    try {
      final response = await client.post(
        "${ApiEndpoint.cart}/add",
        requestBody,
      );

      print(
        '[CartRemoteDataSource] ✅ Add to cart status: ${response.statusCode}',
      );
      print('[CartRemoteDataSource] 📦 Add to cart response: ${response.data}');

      // API chỉ cần trả success, không cần parse cart
      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw Exception('Invalid add-to-cart response format');
    } catch (e, stackTrace) {
      print('[CartRemoteDataSource] ❌ Error adding to cart: $e');
      print('[CartRemoteDataSource] Stack trace: $stackTrace');
      rethrow;
    }
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
