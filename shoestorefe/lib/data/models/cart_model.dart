import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';

class CartModel extends Cart {
  CartModel({
    required super.id,
    required super.userId,
    required super.statusId,
    required super.createAt,
    required super.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final cartId = (json['id'] as num).toInt();

    final items =
        itemsJson
            .map(
              (item) => CartItemModel.fromJson(
                item as Map<String, dynamic>,
                cartId, // Pass cartId from parent
              ),
            )
            .toList();

    return CartModel(
      id: cartId,
      userId: (json['userId'] as num).toInt(),
      statusId:
          (json['statusId'] as num?)?.toInt() ??
          1, // Default to 1 if not present
      createAt:
          json['createAt'] != null
              ? DateTime.parse(json['createAt'] as String)
              : DateTime.now(), // Default to now if not present
      items: items,
    );
  }
}

class CartItemModel extends CartItem {
  CartItemModel({
    required super.id,
    required super.cartId,
    required super.productId,
    required super.quantity,
    required super.unitPrice,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json, int parentCartId) {
    print('[CartItemModel] Parsing JSON: $json');

    final id = (json['id'] as num).toInt();
    // Use cartId from JSON if present, otherwise use parent cart's ID
    final cartId = (json['cartId'] as num?)?.toInt() ?? parentCartId;
    final productId = (json['productId'] as num).toInt();
    final quantity = (json['quantity'] as num).toInt();

    // Try both camelCase and PascalCase
    final unitPrice =
        (json['unitPrice'] as num?)?.toDouble() ??
        (json['UnitPrice'] as num?)?.toDouble() ??
        0.0;

    print(
      '[CartItemModel] Parsed - ID: $id, CartID: $cartId, ProductID: $productId, Quantity: $quantity, UnitPrice: $unitPrice',
    );

    return CartItemModel(
      id: id,
      cartId: cartId,
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }
}
