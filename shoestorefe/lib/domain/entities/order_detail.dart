class OrderDetail {
  final int id;
  final int productId;
  final String? productName;
  final String? productImageUrl;
  final int quantity;
  final double unitPrice;

  OrderDetail({
    required this.id,
    required this.productId,
    this.productName,
    this.productImageUrl,
    required this.quantity,
    required this.unitPrice,
  });
}
