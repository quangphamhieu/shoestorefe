import '../../repositories/order_repository.dart';

class UpdateOrderInfoUseCase {
  final OrderRepository repository;
  UpdateOrderInfoUseCase(this.repository);

  Future<bool> call({
    required int orderId,
    String? note,
    String? address,
  }) async {
    return await repository.updateInfo(
      orderId: orderId,
      note: note,
      address: address,
    );
  }
}
