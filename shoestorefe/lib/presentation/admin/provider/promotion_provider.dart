import 'package:flutter/material.dart';
import '../../../domain/entities/promotion.dart';
import '../../../domain/usecases/promotion/get_all_promotions_usecase.dart';
import '../../../domain/usecases/promotion/get_promotion_by_id_usecase.dart';
import '../../../domain/usecases/promotion/create_promotion_usecase.dart';
import '../../../domain/usecases/promotion/update_promotion_usecase.dart';
import '../../../domain/usecases/promotion/delete_promotion_usecase.dart';

class PromotionProvider extends ChangeNotifier {
  final GetAllPromotionsUseCase getAllUseCase;
  final GetPromotionByIdUseCase getByIdUseCase;
  final CreatePromotionUseCase createUseCase;
  final UpdatePromotionUseCase updateUseCase;
  final DeletePromotionUseCase deleteUseCase;

  PromotionProvider({
    required this.getAllUseCase,
    required this.getByIdUseCase,
    required this.createUseCase,
    required this.updateUseCase,
    required this.deleteUseCase,
  });

  List<Promotion> _promotions = [];
  List<Promotion> get promotions => _promotions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _selectedPromotionId;
  int? get selectedPromotionId => _selectedPromotionId;

  String _search = '';
  String get search => _search;

  List<Promotion> get filteredPromotions {
    if (_search.isEmpty) return _promotions;
    final q = _search.toLowerCase();
    return _promotions
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              (p.code ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      _promotions = await getAllUseCase.call();
    } catch (_) {
      _promotions = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String s) {
    _search = s;
    notifyListeners();
  }

  void selectPromotion(int? id) {
    _selectedPromotionId = id;
    notifyListeners();
  }

  Future<Promotion?> getSelectedPromotionDetail() async {
    if (_selectedPromotionId == null) return null;
    return await getByIdUseCase.call(_selectedPromotionId!);
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> createPromotion({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int statusId,
    required List<Map<String, dynamic>> products,
    required List<int> storeIds,
  }) async {
    _errorMessage = null;
    notifyListeners();
    
    try {
      await createUseCase.call(
        name: name,
        startDate: startDate,
        endDate: endDate,
        statusId: statusId,
        products: products,
        storeIds: storeIds,
      );
      await loadAll();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('Error creating promotion: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePromotion(
    int id, {
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int statusId,
    required List<Map<String, dynamic>> products,
    required List<int> storeIds,
  }) async {
    _errorMessage = null;
    notifyListeners();
    
    try {
      await updateUseCase.call(
        id,
        name: name,
        startDate: startDate,
        endDate: endDate,
        statusId: statusId,
        products: products,
        storeIds: storeIds,
      );
      await loadAll();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('Error updating promotion: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSelectedPromotion() async {
    if (_selectedPromotionId == null) return false;
    final result = await deleteUseCase.call(_selectedPromotionId!);
    if (result) {
      await loadAll();
      selectPromotion(null);
    }
    return result;
  }
}
