import '../../entities/receipt.dart';
import '../../repositories/receipt_repository.dart';

class CreateReceiptUseCase {
  final ReceiptRepository repository;
  CreateReceiptUseCase(this.repository);

  Future<Receipt> call({
    required int supplierId,
    int? storeId,
    required List<Map<String, dynamic>> details,
  }) => repository.create(
    supplierId: supplierId,
    storeId: storeId,
    details: details,
  );
}
