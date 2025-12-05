import 'package:flutter/material.dart';
import '../../../domain/entities/store.dart';
import '../../../domain/usecases/store/get_all_stores_usecase.dart';
import '../../../domain/usecases/store/get_store_by_id_usecase.dart';
import '../../../domain/usecases/store/create_store_usecase.dart';
import '../../../domain/usecases/store/update_store_usecase.dart';
import '../../../domain/usecases/store/delete_store_usecase.dart';

class StoreProvider extends ChangeNotifier {
  final GetAllStoresUseCase getAllUseCase;
  final GetStoreByIdUseCase getByIdUseCase;
  final CreateStoreUseCase createUseCase;
  final UpdateStoreUseCase updateUseCase;
  final DeleteStoreUseCase deleteUseCase;

  StoreProvider({
    required this.getAllUseCase,
    required this.getByIdUseCase,
    required this.createUseCase,
    required this.updateUseCase,
    required this.deleteUseCase,
  });

  List<Store> _stores = [];
  List<Store> get stores => _stores;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _selectedStoreId;
  int? get selectedStoreId => _selectedStoreId;

  String _search = '';
  String get search => _search;

  List<Store> get filteredStores {
    if (_search.isEmpty) return _stores;
    final keyword = _search.toLowerCase();
    return _stores.where((store) {
      final code = store.code?.toLowerCase() ?? '';
      final name = store.name.toLowerCase();
      final address = store.address?.toLowerCase() ?? '';
      final phone = store.phone?.toLowerCase() ?? '';
      return code.contains(keyword) ||
          name.contains(keyword) ||
          address.contains(keyword) ||
          phone.contains(keyword);
    }).toList();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      _stores = await getAllUseCase.call();
    } catch (_) {
      _stores = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void selectStore(int? id) {
    _selectedStoreId = id;
    notifyListeners();
  }

  Future<Store?> getSelectedStoreDetail() async {
    final id = _selectedStoreId;
    if (id == null) return null;
    return await getByIdUseCase.call(id);
  }

  Future<bool> createStore({
    required String name,
    required String code,
    required String address,
    required String phone,
  }) async {
    try {
      await createUseCase.call(
        name: name,
        code: code,
        address: address,
        phone: phone,
      );
      await loadAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateStore(
    int id, {
    required String name,
    required String code,
    required String address,
    required String phone,
    required int statusId,
  }) async {
    try {
      await updateUseCase.call(
        id,
        name: name,
        code: code,
        address: address,
        phone: phone,
        statusId: statusId,
      );
      await loadAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteSelectedStore() async {
    final id = _selectedStoreId;
    if (id == null) return false;
    final deleted = await deleteUseCase.call(id);
    if (deleted) {
      await loadAll();
      selectStore(null);
    }
    return deleted;
  }
}
