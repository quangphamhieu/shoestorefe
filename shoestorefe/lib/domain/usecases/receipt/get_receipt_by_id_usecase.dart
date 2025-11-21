import '../../entities/receipt.dart';
import '../../repositories/receipt_repository.dart';

class GetReceiptByIdUseCase {
  final ReceiptRepository repository;
  GetReceiptByIdUseCase(this.repository);

  Future<Receipt?> call(int id) => repository.getById(id);
}
