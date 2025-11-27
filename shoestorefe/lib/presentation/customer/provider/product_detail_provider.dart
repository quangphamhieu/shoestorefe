import 'package:flutter/material.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/usecases/cart/add_item_to_cart.dart';
import '../../../domain/usecases/product/get_list_product_by_name.dart';

class ProductDetailProvider extends ChangeNotifier {
  final GetListProductByNameUseCase getListProductByNameUseCase;
  final AddItemToCart addItemToCartUseCase;

  ProductDetailProvider({
    required this.getListProductByNameUseCase,
    required this.addItemToCartUseCase
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

  // Quantity
  int _quantity = 1;
  int get quantity => _quantity;

  void increaseQty() {
    _quantity++;
    notifyListeners();
  }

  void decreaseQty() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  // Available filters
  Set<String> get availableColors =>
      _variants.where((p) => p.color != null).map((p) => p.color!).toSet();

  Set<String> get availableSizes =>
      _variants.where((p) => p.size != null).map((p) => p.size!).toSet();

  // Filtered list
  List<Product> get _filteredVariants {
    return _variants.where((p) {
      final matchColor =
          _selectedColor == null || p.color == _selectedColor;
      final matchSize =
          _selectedSize == null || p.size == _selectedSize;
      return matchColor && matchSize;
    }).toList();
  }

  // Get selected variant
  Product? get selectedVariant {
    try {
      return _variants.firstWhere(
            (p) =>
        (_selectedColor == null || p.color == _selectedColor) &&
            (_selectedSize == null || p.size == _selectedSize),
      );
    } catch (_) {
      return null;
    }
  }

  // Stock info
  int get filteredStockQuantity {
    int total = 0;
    for (final product in _filteredVariants) {
      for (final store in product.stores) {
        total += store.quantity;
      }
    }
    return total;
  }

  Map<String, int> get stockByStore {
    final Map<String, int> result = {};
    for (final product in _filteredVariants) {
      for (final sq in product.stores) {
        result.update(sq.storeName, (value) => value + sq.quantity,
            ifAbsent: () => sq.quantity);
      }
    }
    return result;
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

  // Add to cart
  Future<void> addToCart() async {
    final variant = selectedVariant;
    if (variant == null) return;

    await addItemToCartUseCase.call(variant.id, _quantity);
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
    _quantity = 1;
    notifyListeners();
  }
}
