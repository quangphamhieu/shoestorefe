import 'store_quantity.dart';

class Product {
  final int id;
  final String? sku;
  final String name;
  final int? brandId;
  final int? supplierId;
  final double costPrice;
  final double originalPrice;
  final String? color;
  final String? size;
  final String? description;
  final String? imageUrl;
  final int statusId;
  final DateTime createdAt;
  final List<StoreQuantity> stores;

  Product({
    required this.id,
    this.sku,
    required this.name,
    this.brandId,
    this.supplierId,
    required this.costPrice,
    required this.originalPrice,
    this.color,
    this.size,
    this.description,
    this.imageUrl,
    required this.statusId,
    required this.createdAt,
    this.stores = const [],
  });
}
