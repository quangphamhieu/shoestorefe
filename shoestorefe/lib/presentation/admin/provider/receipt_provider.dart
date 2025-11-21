import 'package:flutter/material.dart';
import '../../../domain/entities/receipt.dart';
import '../../../domain/usecases/receipt/get_all_receipts_usecase.dart';
import '../../../domain/usecases/receipt/get_receipt_by_id_usecase.dart';
import '../../../domain/usecases/receipt/create_receipt_usecase.dart';
import '../../../domain/usecases/receipt/update_receipt_info_usecase.dart';
import '../../../domain/usecases/receipt/update_receipt_received_usecase.dart';
import '../../../domain/usecases/receipt/delete_receipt_usecase.dart';

class ReceiptProvider extends ChangeNotifier {
  final GetAllReceiptsUseCase getAllUseCase;
  final GetReceiptByIdUseCase getByIdUseCase;
  final CreateReceiptUseCase createUseCase;
  final UpdateReceiptInfoUseCase updateInfoUseCase;
  final UpdateReceiptReceivedUseCase updateReceivedUseCase;
  final DeleteReceiptUseCase deleteUseCase;

  ReceiptProvider({
    required this.getAllUseCase,
    required this.getByIdUseCase,
    required this.createUseCase,
    required this.updateInfoUseCase,
    required this.updateReceivedUseCase,
    required this.deleteUseCase,
  });

  List<Receipt> _receipts = [];
  List<Receipt> get receipts => _receipts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _selectedReceiptId;
  int? get selectedReceiptId => _selectedReceiptId;

  String _search = '';
  String get search => _search;

  List<Receipt> get filteredReceipts {
    if (_search.isEmpty) return _receipts;
    final q = _search.toLowerCase();
    return _receipts
        .where(
          (r) =>
              r.receiptNumber.toLowerCase().contains(q) ||
              (r.supplierName ?? '').toLowerCase().contains(q) ||
              (r.storeName ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      _receipts = await getAllUseCase.call();
    } catch (_) {
      _receipts = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String s) {
    _search = s;
    notifyListeners();
  }

  void selectReceipt(int? id) {
    _selectedReceiptId = id;
    notifyListeners();
  }

  Future<Receipt?> getSelectedReceiptDetail() async {
    if (_selectedReceiptId == null) return null;
    return await getByIdUseCase.call(_selectedReceiptId!);
  }

  Future<bool> createReceipt({
    required int supplierId,
    int? storeId,
    required List<Map<String, dynamic>> details,
  }) async {
    try {
      await createUseCase.call(
        supplierId: supplierId,
        storeId: storeId,
        details: details,
      );
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateReceiptInfo(
    int id, {
    required int supplierId,
    int? storeId,
    required List<Map<String, dynamic>> details,
  }) async {
    try {
      await updateInfoUseCase.call(
        id,
        supplierId: supplierId,
        storeId: storeId,
        details: details,
      );
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateReceiptReceived(
    int id, {
    required List<Map<String, dynamic>> details,
  }) async {
    try {
      await updateReceivedUseCase.call(id, details: details);
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSelectedReceipt() async {
    if (_selectedReceiptId == null) return false;
    final result = await deleteUseCase.call(_selectedReceiptId!);
    if (result) {
      await loadAll();
      selectReceipt(null);
    }
    return result;
  }
}
