import '../../repositories/receipt_repository.dart';

class DeleteReceiptUseCase {
  final ReceiptRepository repository;
  DeleteReceiptUseCase(this.repository);

  Future<bool> call(int id) => repository.delete(id);
}
