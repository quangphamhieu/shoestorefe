class PromotionProduct {
  final int productId;
  final String productName;
  final String? sku;
  final double? salePrice;
  final double discountPercent;

  PromotionProduct({
    required this.productId,
    required this.productName,
    this.sku,
    this.salePrice,
    required this.discountPercent,
  });
}
