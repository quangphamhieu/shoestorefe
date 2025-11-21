import '../../entities/receipt.dart';
import '../../repositories/receipt_repository.dart';

class UpdateReceiptInfoUseCase {
  final ReceiptRepository repository;
  UpdateReceiptInfoUseCase(this.repository);

  Future<Receipt?> call(
    int id, {
    required int supplierId,
    int? storeId,
    required List<Map<String, dynamic>> details,
  }) => repository.updateInfo(
    id,
    supplierId: supplierId,
    storeId: storeId,
    details: details,
  );
}
