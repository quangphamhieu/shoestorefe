import '../entities/receipt.dart';

abstract class ReceiptRepository {
  Future<List<Receipt>> getAll();
  Future<Receipt?> getById(int id);
  Future<Receipt> create({
    required int supplierId,
    int? storeId,
    required List<Map<String, dynamic>>
    details, // [{productId, quantityOrdered}]
  });
  Future<Receipt?> updateInfo(
    int id, {
    required int supplierId,
    int? storeId,
    required List<Map<String, dynamic>> details,
  });
  Future<Receipt?> updateReceived(
    int id, {
    required List<Map<String, dynamic>>
    details, // [{receiptDetailId, receivedQuantity}]
  });
  Future<bool> delete(int id);
}
