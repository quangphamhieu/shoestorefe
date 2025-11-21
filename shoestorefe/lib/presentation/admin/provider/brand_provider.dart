import 'package:flutter/material.dart';
import '../../../domain/entities/brand.dart';
import '../../../domain/usecases/brand/get_all_brands_usecase.dart';
import '../../../domain/usecases/brand/get_brand_by_id_usecase.dart';
import '../../../domain/usecases/brand/create_brand_usecase.dart';
import '../../../domain/usecases/brand/update_brand_usecase.dart';
import '../../../domain/usecases/brand/delete_brand_usecase.dart';

class BrandProvider extends ChangeNotifier {
  final GetAllBrandsUseCase getAllUseCase;
  final GetBrandByIdUseCase getByIdUseCase;
  final CreateBrandUseCase createUseCase;
  final UpdateBrandUseCase updateUseCase;
  final DeleteBrandUseCase deleteUseCase;

  BrandProvider({
    required this.getAllUseCase,
    required this.getByIdUseCase,
    required this.createUseCase,
    required this.updateUseCase,
    required this.deleteUseCase,
  });

  List<Brand> _brands = [];
  List<Brand> get brands => _brands;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _selectedBrandId;
  int? get selectedBrandId => _selectedBrandId;

  String _search = '';
  String get search => _search;

  List<Brand> get filteredBrands {
    if (_search.isEmpty) return _brands;
    final q = _search.toLowerCase();
    return _brands
        .where(
          (b) =>
              (b.name.toLowerCase().contains(q) ||
                  (b.code ?? '').toLowerCase().contains(q)),
        )
        .toList();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      _brands = await getAllUseCase.call();
    } catch (_) {
      _brands = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String s) {
    _search = s;
    notifyListeners();
  }

  void selectBrand(int? id) {
    _selectedBrandId = id;
    notifyListeners();
  }

  Future<Brand?> getSelectedBrandDetail() async {
    if (_selectedBrandId == null) return null;
    return await getByIdUseCase.call(_selectedBrandId!);
  }

  Future<bool> createBrand({
    required String name,
    String? code,
    String? description,
  }) async {
    try {
      final created = await createUseCase.call(
        name: name,
        code: code,
        description: description,
      );
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBrand(
    int id, {
    required String name,
    String? code,
    String? description,
    required int statusId,
  }) async {
    try {
      final updated = await updateUseCase.call(
        id,
        name: name,
        code: code,
        description: description,
        statusId: statusId,
      );
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSelectedBrand() async {
    if (_selectedBrandId == null) return false;
    final result = await deleteUseCase.call(_selectedBrandId!);
    if (result) {
      await loadAll();
      selectBrand(null);
    }
    return result;
  }
}
