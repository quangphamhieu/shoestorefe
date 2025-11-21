import '../../repositories/order_repository.dart';

class DeleteOrderDetailUseCase {
  final OrderRepository repository;
  DeleteOrderDetailUseCase(this.repository);

  Future<bool> call(int orderDetailId) {
    return repository.deleteDetail(orderDetailId);
  }
}
