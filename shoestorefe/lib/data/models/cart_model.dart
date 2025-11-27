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
    final itemsJson =
        json['items'] as List<dynamic>? ?? [];

    final items = itemsJson
        .map(
          (item) => CartItemModel.fromJson(item as Map<String, dynamic>),
    )
        .toList();

    return CartModel(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      statusId: (json['statusId'] as num).toInt(),
      createAt: DateTime.parse(json['createAt'] as String),
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

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: (json['id'] as num).toInt(),
      cartId: (json['cartId'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }
}
