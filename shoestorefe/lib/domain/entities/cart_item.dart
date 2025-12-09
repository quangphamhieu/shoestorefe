class CartItem {
  final int id;
  final int? cartId; // Nullable since API may not return it
  final int productId;
  final int quantity;
  final double unitPrice;
  CartItem({
    required this.id,
    this.cartId, // Optional
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });
}
