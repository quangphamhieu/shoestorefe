import '../../repositories/order_repository.dart';

class UpdateOrderDetailUseCase {
  final OrderRepository repository;
  UpdateOrderDetailUseCase(this.repository);

  Future<bool> call({required int orderDetailId, required int quantity}) {
    return repository.updateDetail(
      orderDetailId: orderDetailId,
      quantity: quantity,
    );
  }
}
