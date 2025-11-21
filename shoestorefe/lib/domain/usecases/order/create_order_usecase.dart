import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;
  CreateOrderUseCase(this.repository);

  Future<Order> call({
    required int customerId,
    required int orderType,
    required int paymentMethod,
    int? storeId,
    required List<Map<String, dynamic>> details,
  }) {
    return repository.create(
      customerId: customerId,
      orderType: orderType,
      paymentMethod: paymentMethod,
      storeId: storeId,
      details: details,
    );
  }
}

