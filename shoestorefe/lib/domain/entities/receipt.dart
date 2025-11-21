import 'receipt_detail.dart';

class Receipt {
  final int id;
  final String receiptNumber;
  final int supplierId;
  final String? supplierName;
  final int? storeId;
  final String? storeName;
  final int createdBy;
  final String? creatorName;
  final int statusId;
  final DateTime createdAt;
  final DateTime? receivedDate;
  final double totalAmount;
  final List<ReceiptDetail> details;

  Receipt({
    required this.id,
    required this.receiptNumber,
    required this.supplierId,
    this.supplierName,
    this.storeId,
    this.storeName,
    required this.createdBy,
    this.creatorName,
    required this.statusId,
    required this.createdAt,
    this.receivedDate,
    required this.totalAmount,
    required this.details,
  });
}
