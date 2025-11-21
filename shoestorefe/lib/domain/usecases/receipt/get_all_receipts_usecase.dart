import '../../entities/receipt.dart';
import '../../repositories/receipt_repository.dart';

class GetAllReceiptsUseCase {
  final ReceiptRepository repository;
  GetAllReceiptsUseCase(this.repository);

  Future<List<Receipt>> call() => repository.getAll();
}
