class OrderDetail {
  final int id;
  final int productId;
  final String? productName;
  final String? productImageUrl;
  final String? color;
  final String? size;
  final int quantity;
  final double unitPrice;

  OrderDetail({
    required this.id,
    required this.productId,
    this.productName,
    this.productImageUrl,
    this.color,
    this.size,
    required this.quantity,
    required this.unitPrice,
  });
}
