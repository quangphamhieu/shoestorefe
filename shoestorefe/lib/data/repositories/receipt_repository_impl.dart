import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/receipt_remote_data_source.dart';
import '../models/receipt_model.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final ReceiptRemoteDataSource remote;

  ReceiptRepositoryImpl(this.remote);

  @override
  Future<List<Receipt>> getAll() async {
    return await remote.getAll();
  }

  @override
  Future<Receipt?> getById(int id) async {
    return await remote.getById(id);
  }

  @override
  Future<Receipt> create({
    required int supplierId,
    int? storeId,
    required List<Map<String, dynamic>> details,
  }) async {
    final receipt = ReceiptModel(
      id: 0,
      receiptNumber: '',
      supplierId: supplierId,
      storeId: storeId,
      createdBy: 1,
      statusId: 1,
      createdAt: DateTime.now(),
      totalAmount: 0,
      details:
          details
              .map(
                (d) => ReceiptDetailModel(
                  id: 0,
                  productId: d['productId'] as int,
                  quantityOrdered: d['quantityOrdered'] as int,
                  unitPrice: 0,
                ),
              )
              .toList(),
    );
    return await remote.create(receipt);
  }

  @override
  Future<Receipt?> updateInfo(
    int id, {
    required int supplierId,
    int? storeId,
    required List<Map<String, dynamic>> details,
  }) async {
    final receipt = ReceiptModel(
      id: id,
      receiptNumber: '',
      supplierId: supplierId,
      storeId: storeId,
      createdBy: 1,
      statusId: 1,
      createdAt: DateTime.now(),
      totalAmount: 0,
      details:
          details
              .map(
                (d) => ReceiptDetailModel(
                  id: 0,
                  productId: d['productId'] as int,
                  quantityOrdered: d['quantityOrdered'] as int,
                  unitPrice: 0,
                ),
              )
              .toList(),
    );
    return await remote.updateInfo(id, receipt);
  }

  @override
  Future<Receipt?> updateReceived(
    int id, {
    required List<Map<String, dynamic>> details,
  }) async {
    final receipt = ReceiptModel(
      id: id,
      receiptNumber: '',
      supplierId: 0,
      createdBy: 1,
      statusId: 1,
      createdAt: DateTime.now(),
      totalAmount: 0,
      details:
          details
              .map(
                (d) => ReceiptDetailModel(
                  id: d['receiptDetailId'] as int,
                  productId: 0,
                  quantityOrdered: 0,
                  receivedQuantity: d['receivedQuantity'] as int,
                  unitPrice: 0,
                ),
              )
              .toList(),
    );
    return await remote.updateReceived(id, receipt);
  }

  @override
  Future<bool> delete(int id) async {
    return await remote.delete(id);
  }
}
