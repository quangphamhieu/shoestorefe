import '../../domain/entities/promotion.dart';
import '../../domain/entities/promotion_product.dart';
import '../../domain/entities/promotion_store.dart';

class PromotionModel extends Promotion {
  PromotionModel({
    required super.id,
    super.code,
    required super.name,
    required super.startDate,
    required super.endDate,
    required super.statusId,
    super.statusName,
    required super.products,
    required super.stores,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'] as List<dynamic>?;
    final products =
        productsJson
            ?.map(
              (p) => PromotionProductModel.fromJson(p as Map<String, dynamic>),
            )
            .toList() ??
        [];

    final storesJson = json['stores'] as List<dynamic>?;
    final stores =
        storesJson
            ?.map(
              (s) => PromotionStoreModel.fromJson(s as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return PromotionModel(
      id: json['id'] as int,
      code: json['code'] as String?,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      statusId: json['statusId'] as int,
      statusName: json['statusName'] as String?,
      products: products,
      stores: stores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'statusId': statusId,
      'statusName': statusName,
      'products':
          products.map((p) => (p as PromotionProductModel).toJson()).toList(),
      'stores': stores.map((s) => (s as PromotionStoreModel).toJson()).toList(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'statusId': statusId,
      'products':
          products
              .map(
                (p) => {
                  'productId': p.productId,
                  'discountPercent': p.discountPercent,
                },
              )
              .toList(),
      'stores': stores.map((s) => {'storeId': s.storeId}).toList(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'statusId': statusId,
      'products':
          products
              .map(
                (p) => {
                  'productId': p.productId,
                  'discountPercent': p.discountPercent,
                },
              )
              .toList(),
      'stores': stores.map((s) => {'storeId': s.storeId}).toList(),
    };
  }
}

class PromotionProductModel extends PromotionProduct {
  PromotionProductModel({
    required super.productId,
    required super.productName,
    super.sku,
    super.salePrice,
    required super.discountPercent,
  });

  factory PromotionProductModel.fromJson(Map<String, dynamic> json) =>
      PromotionProductModel(
        productId: json['productId'] as int,
        productName: json['productName'] as String,
        sku: json['sku'] as String?,
        salePrice:
            json['salePrice'] != null
                ? (json['salePrice'] as num).toDouble()
                : null,
        discountPercent: (json['discountPercent'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'sku': sku,
    'salePrice': salePrice,
    'discountPercent': discountPercent,
  };
}

class PromotionStoreModel extends PromotionStore {
  PromotionStoreModel({required super.storeId, super.storeName});

  factory PromotionStoreModel.fromJson(Map<String, dynamic> json) =>
      PromotionStoreModel(
        storeId: json['storeId'] as int,
        storeName: json['storeName'] as String?,
      );

  Map<String, dynamic> toJson() => {'storeId': storeId, 'storeName': storeName};
}
