class ReceiptDetail {
  final int id;
  final int productId;
  final String? productName;
  final String? sku;
  final int quantityOrdered;
  final int? receivedQuantity;
  final double unitPrice;

  ReceiptDetail({
    required this.id,
    required this.productId,
    this.productName,
    this.sku,
    required this.quantityOrdered,
    this.receivedQuantity,
    required this.unitPrice,
  });
}
