class CartItem {
  final int id;
  final int cartId;
  final int productId;
  final int quantity;
  final double unitPrice;
  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });
}