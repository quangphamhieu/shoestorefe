import 'package:flutter/material.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/entities/store_quantity.dart';
import '../../../domain/usecases/product/get_list_product_by_name.dart';

class ProductDetailProvider extends ChangeNotifier {
  final GetListProductByNameUseCase getListProductByNameUseCase;

  ProductDetailProvider({
    required this.getListProductByNameUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _productName = '';
  String get productName => _productName;

  List<Product> _variants = [];
  List<Product> get variants => _variants;

  String? _selectedColor;
  String? get selectedColor => _selectedColor;

  String? _selectedSize;
  String? get selectedSize => _selectedSize;

  Set<String> get availableColors =>
      _variants.where((p) => p.color != null).map((p) => p.color!).toSet();

  Set<String> get availableSizes =>
      _variants.where((p) => p.size != null).map((p) => p.size!).toSet();

  /// Tổng số lượng tồn kho theo filter màu/size hiện tại (cộng dồn tất cả store)
  int get filteredStockQuantity {
    final filtered = _filteredVariants;
    int total = 0;
    for (final product in filtered) {
      for (final StoreQuantity sq in product.stores) {
        total += sq.quantity;
      }
    }
    return total;
  }

  /// Danh sách store + tồn kho theo filter hiện tại
  Map<String, int> get stockByStore {
    final Map<String, int> result = {};
    for (final product in _filteredVariants) {
      for (final StoreQuantity sq in product.stores) {
        result.update(sq.storeName, (value) => value + sq.quantity,
            ifAbsent: () => sq.quantity);
      }
    }
    return result;
  }

  List<Product> get _filteredVariants {
    return _variants.where((p) {
      final matchColor =
          _selectedColor == null || p.color == null || p.color == _selectedColor;
      final matchSize =
          _selectedSize == null || p.size == null || p.size == _selectedSize;
      return matchColor && matchSize;
    }).toList();
  }

  Future<void> loadByName(String name) async {
    _productName = name;
    _isLoading = true;
    notifyListeners();
    try {
      _variants = await getListProductByNameUseCase(name);
    } catch (_) {
      _variants = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectColor(String? color) {
    _selectedColor = color;
    notifyListeners();
  }

  void selectSize(String? size) {
    _selectedSize = size;
    notifyListeners();
  }

  void clearSelection() {
    _selectedColor = null;
    _selectedSize = null;
    notifyListeners();
  }
}


