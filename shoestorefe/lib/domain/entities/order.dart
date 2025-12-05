import 'order_detail.dart';

class Order {
  final int id;
  final String orderNumber;
  final int customerId;
  final String? customerName;
  final int? createdBy;
  final String? creatorName;
  final int? storeId;
  final String? storeName;
  final int statusId;
  final double totalAmount;
  final int orderType;
  final int paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderDetail> details;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    this.customerName,
    this.createdBy,
    this.creatorName,
    this.storeId,
    this.storeName,
    required this.statusId,
    required this.totalAmount,
    required this.orderType,
    required this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
    required this.details,
  });
}
