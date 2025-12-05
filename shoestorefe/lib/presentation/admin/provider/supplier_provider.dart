import 'package:flutter/material.dart';
import '../../../domain/entities/supplier.dart';
import '../../../domain/usecases/supplier/get_all_suppliers_usecase.dart';
import '../../../domain/usecases/supplier/get_supplier_by_id_usecase.dart';
import '../../../domain/usecases/supplier/create_supplier_usecase.dart';
import '../../../domain/usecases/supplier/update_supplier_usecase.dart';
import '../../../domain/usecases/supplier/delete_supplier_usecase.dart';

class SupplierProvider extends ChangeNotifier {
  final GetAllSuppliersUseCase getAllUseCase;
  final GetSupplierByIdUseCase getByIdUseCase;
  final CreateSupplierUseCase createUseCase;
  final UpdateSupplierUseCase updateUseCase;
  final DeleteSupplierUseCase deleteUseCase;

  SupplierProvider({
    required this.getAllUseCase,
    required this.getByIdUseCase,
    required this.createUseCase,
    required this.updateUseCase,
    required this.deleteUseCase,
  });

  List<Supplier> _suppliers = [];
  List<Supplier> get suppliers => _suppliers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _selectedSupplierId;
  int? get selectedSupplierId => _selectedSupplierId;

  String _search = '';
  String get search => _search;

  List<Supplier> get filteredSuppliers {
    if (_search.isEmpty) return _suppliers;
    final q = _search.toLowerCase();
    return _suppliers
        .where(
          (s) =>
              (s.name.toLowerCase().contains(q) ||
                  (s.code ?? '').toLowerCase().contains(q) ||
                  (s.contactInfo ?? '').toLowerCase().contains(q)),
        )
        .toList();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      _suppliers = await getAllUseCase.call();
    } catch (_) {
      _suppliers = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String s) {
    _search = s;
    notifyListeners();
  }

  void selectSupplier(int? id) {
    _selectedSupplierId = id;
    notifyListeners();
  }

  Future<Supplier?> getSelectedSupplierDetail() async {
    if (_selectedSupplierId == null) return null;
    return await getByIdUseCase.call(_selectedSupplierId!);
  }

  Future<bool> createSupplier({
    required String name,
    String? code,
    String? contactInfo,
  }) async {
    try {
      await createUseCase.call(
        name: name,
        code: code,
        contactInfo: contactInfo,
      );
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSupplier(
    int id, {
    required String name,
    String? code,
    String? contactInfo,
    required int statusId,
  }) async {
    try {
      await updateUseCase.call(
        id,
        name: name,
        code: code,
        contactInfo: contactInfo,
        statusId: statusId,
      );
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSelectedSupplier() async {
    if (_selectedSupplierId == null) return false;
    final result = await deleteUseCase.call(_selectedSupplierId!);
    if (result) {
      await loadAll();
      selectSupplier(null);
    }
    return result;
  }
}
