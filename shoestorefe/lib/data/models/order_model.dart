import '../../domain/entities/order.dart';
import '../../domain/entities/order_detail.dart';

class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.orderNumber,
    required super.customerId,
    super.customerName,
    super.createdBy,
    super.creatorName,
    super.storeId,
    super.storeName,
    required super.statusId,
    required super.totalAmount,
    required super.orderType,
    required super.paymentMethod,
    required super.createdAt,
    super.updatedAt,
    required super.details,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final detailsJson =
        json['details'] as List<dynamic>? ??
        json['items'] as List<dynamic>? ??
        [];
    final details =
        detailsJson
            .map(
              (detail) =>
                  OrderDetailModel.fromJson(detail as Map<String, dynamic>),
            )
            .toList();

    return OrderModel(
      id: (json['id'] as num).toInt(),
      orderNumber: json['orderNumber'] as String,
      customerId: (json['customerId'] as num).toInt(),
      customerName: json['customerName'] as String?,
      createdBy:
          json['createdBy'] != null ? (json['createdBy'] as num).toInt() : null,
      creatorName: json['creatorName'] as String?,
      storeId:
          json['storeId'] != null ? (json['storeId'] as num).toInt() : null,
      storeName: json['storeName'] as String?,
      statusId: (json['statusId'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      orderType: (json['orderType'] as num).toInt(),
      paymentMethod: (json['paymentMethod'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'] as String)
              : null,
      details: details,
    );
  }
}

class OrderDetailModel extends OrderDetail {
  OrderDetailModel({
    required super.id,
    required super.productId,
    super.productName,
    required super.quantity,
    required super.unitPrice,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: (json['id'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      productName: json['productName'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }
}
