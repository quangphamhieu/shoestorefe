import '../../domain/entities/receipt.dart';
import '../../domain/entities/receipt_detail.dart';

class ReceiptModel extends Receipt {
  ReceiptModel({
    required super.id,
    required super.receiptNumber,
    required super.supplierId,
    super.supplierName,
    super.storeId,
    super.storeName,
    required super.createdBy,
    super.creatorName,
    required super.statusId,
    required super.createdAt,
    super.receivedDate,
    required super.totalAmount,
    required super.details,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    final detailsJson = json['details'] as List<dynamic>?;
    final details =
        detailsJson
            ?.map((d) => ReceiptDetailModel.fromJson(d as Map<String, dynamic>))
            .toList() ??
        [];

    return ReceiptModel(
      id: json['id'] as int,
      receiptNumber: json['receiptNumber'] as String,
      supplierId: json['supplierId'] as int,
      supplierName: json['supplierName'] as String?,
      storeId: json['storeId'] as int?,
      storeName: json['storeName'] as String?,
      createdBy: json['createdBy'] as int,
      creatorName: json['creatorName'] as String?,
      statusId: json['statusId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      receivedDate:
          json['receivedDate'] != null
              ? DateTime.parse(json['receivedDate'] as String)
              : null,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      details: details,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'supplierId': supplierId,
      'storeId': storeId,
      'details':
          details
              .map(
                (d) => {
                  'productId': d.productId,
                  'quantityOrdered': d.quantityOrdered,
                },
              )
              .toList(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'supplierId': supplierId,
      'storeId': storeId,
      'details':
          details
              .map(
                (d) => {
                  'productId': d.productId,
                  'quantityOrdered': d.quantityOrdered,
                },
              )
              .toList(),
    };
  }

  Map<String, dynamic> toUpdateReceivedJson() {
    return {
      'details':
          details
              .map(
                (d) => {
                  'receiptDetailId': d.id,
                  'receivedQuantity': d.receivedQuantity ?? 0,
                },
              )
              .toList(),
    };
  }
}

class ReceiptDetailModel extends ReceiptDetail {
  ReceiptDetailModel({
    required super.id,
    required super.productId,
    super.productName,
    super.sku,
    required super.quantityOrdered,
    super.receivedQuantity,
    required super.unitPrice,
  });

  factory ReceiptDetailModel.fromJson(Map<String, dynamic> json) =>
      ReceiptDetailModel(
        id: json['id'] as int,
        productId: json['productId'] as int,
        productName: json['productName'] as String?,
        sku: json['sku'] as String?,
        quantityOrdered: json['quantityOrdered'] as int,
        receivedQuantity: json['receivedQuantity'] as int?,
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );
}
