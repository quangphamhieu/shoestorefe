import '../../entities/receipt.dart';
import '../../repositories/receipt_repository.dart';

class UpdateReceiptReceivedUseCase {
  final ReceiptRepository repository;
  UpdateReceiptReceivedUseCase(this.repository);

  Future<Receipt?> call(
    int id, {
    required List<Map<String, dynamic>> details,
  }) => repository.updateReceived(id, details: details);
}
