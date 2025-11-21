import '../../repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository repository;
  UpdateOrderStatusUseCase(this.repository);

  Future<bool> call({required int orderId, required int statusId}) async {
    return await repository.updateStatus(orderId: orderId, statusId: statusId);
  }
}
