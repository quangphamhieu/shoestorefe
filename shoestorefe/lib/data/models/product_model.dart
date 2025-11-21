import '../../domain/entities/product.dart';
import '../../domain/entities/store_quantity.dart';

class ProductModel extends Product {
  ProductModel({
    required int id,
    String? sku,
    required String name,
    int? brandId,
    int? supplierId,
    required double costPrice,
    required double originalPrice,
    String? color,
    String? size,
    String? description,
    String? imageUrl,
    required int statusId,
    required DateTime createdAt,
    List<StoreQuantity> stores = const [],
  }) : super(
         id: id,
         sku: sku,
         name: name,
         brandId: brandId,
         supplierId: supplierId,
         costPrice: costPrice,
         originalPrice: originalPrice,
         color: color,
         size: size,
         description: description,
         imageUrl: imageUrl,
         statusId: statusId,
         createdAt: createdAt,
         stores: stores,
       );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final storesJson = json['stores'] as List<dynamic>?;
    final stores =
        storesJson
            ?.map((s) => StoreQuantityModel.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    // Xử lý imageUrl an toàn
    String? imageUrl;
    if (json['imageUrl'] != null) {
      final url = json['imageUrl'].toString().trim();
      imageUrl = url.isNotEmpty ? url : null;
    }

    return ProductModel(
      id: json['id'] is int ? json['id'] as int : (json['id'] as num).toInt(),
      sku: json['sku']?.toString(),
      name: json['name']?.toString() ?? '',
      brandId:
          json['brandId'] is int
              ? json['brandId'] as int
              : (json['brandId'] is num
                  ? (json['brandId'] as num).toInt()
                  : null),
      supplierId:
          json['supplierId'] is int
              ? json['supplierId'] as int
              : (json['supplierId'] is num
                  ? (json['supplierId'] as num).toInt()
                  : null),
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      color: json['color']?.toString(),
      size: json['size']?.toString(),
      description: json['description']?.toString(),
      imageUrl: imageUrl,
      statusId:
          json['statusId'] is int
              ? json['statusId'] as int
              : (json['statusId'] is num
                  ? (json['statusId'] as num).toInt()
                  : 1),
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt'] is String
                  ? DateTime.parse(json['createdAt'] as String)
                  : DateTime.now())
              : DateTime.now(),
      stores: stores,
    );
  }
}

class StoreQuantityModel extends StoreQuantity {
  StoreQuantityModel({
    required int storeId,
    required String storeName,
    required int quantity,
    required double salePrice,
  }) : super(
         storeId: storeId,
         storeName: storeName,
         quantity: quantity,
         salePrice: salePrice,
       );

  factory StoreQuantityModel.fromJson(Map<String, dynamic> json) =>
      StoreQuantityModel(
        storeId: json['storeId'] as int,
        storeName: json['storeName'] as String,
        quantity: json['quantity'] as int,
        salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0,
      );
}
