import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getAll();
  Future<Order> create({
    required int customerId,
    required int orderType,
    required int paymentMethod,
    int? storeId,
    required List<Map<String, dynamic>> details,
  });
  Future<bool> updateStatus({required int orderId, required int statusId});
  Future<bool> updateDetail({
    required int orderDetailId,
    required int quantity,
  });
  Future<bool> deleteDetail(int orderDetailId);
}
