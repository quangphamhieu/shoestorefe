import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remote;
  OrderRepositoryImpl(this.remote);

  @override
  Future<List<Order>> getAll() async {
    return await remote.getAll();
  }

  @override
  Future<Order> create({
    required int customerId,
    required int orderType,
    required int paymentMethod,
    int? storeId,
    required List<Map<String, dynamic>> details,
  }) async {
    final body = {
      'customerId': customerId,
      'orderType': orderType,
      'paymentMethod': paymentMethod,
      if (storeId != null) 'storeId': storeId,
      'details': details,
    };
    return await remote.create(body);
  }

  @override
  Future<bool> updateStatus({
    required int orderId,
    required int statusId,
  }) async {
    return await remote.updateStatus(orderId: orderId, statusId: statusId);
  }

  @override
  Future<bool> updateDetail({
    required int orderDetailId,
    required int quantity,
  }) async {
    return await remote.updateDetail(
      orderDetailId: orderDetailId,
      quantity: quantity,
    );
  }

  @override
  Future<bool> deleteDetail(int orderDetailId) async {
    return await remote.deleteDetail(orderDetailId);
  }
}
