import 'package:flutter/material.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/product/get_all_products_usecase.dart';
import '../../../domain/usecases/product/search_products_usecase.dart';

class ProductGroup {
  final Product representative; // Product đại diện
  final List<Product> allVariants; // Tất cả variants
  final Set<String> availableSizes;
  final Set<String> availableColors;
  final int totalVariants;

  ProductGroup({
    required this.representative,
    required this.allVariants,
    required this.availableSizes,
    required this.availableColors,
    required this.totalVariants,
  });
}

class CustomerProvider extends ChangeNotifier {
  static const int warehouseStoreId = 1;

  final GetAllProductsUseCase getAllProductsUseCase;
  final SearchProductsUseCase searchProductsUseCase;

  CustomerProvider({
    required this.getAllProductsUseCase,
    required this.searchProductsUseCase,
  });

  // Raw products từ API (tất cả variants)
  List<Product> _products = [];
  List<Product> get products => _products;

  // Customer: Products đã được group (merge các variants cùng tên)
  List<ProductGroup> _productGroups = [];
  List<ProductGroup> get productGroups => _productGroups;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _selectedSize;
  String? get selectedSize => _selectedSize;

  String? _selectedColor;
  String? get selectedColor => _selectedColor;

  double? _minPrice;
  double? get minPrice => _minPrice;

  double? _maxPrice;
  double? get maxPrice => _maxPrice;

  String _sortBy = 'newest'; // newest, price-asc, price-desc, name
  String get sortBy => _sortBy;

  // Customer: Nhóm products theo base name (bỏ size và color ở cuối)
  // Ví dụ: "Air Jordan 1 - Red - 42" và "Air Jordan 1 - Black - 43" -> "Air Jordan 1"
  String _getBaseName(String productName) {
    // Loại bỏ các pattern size và color ở cuối tên
    // Ví dụ: "Air Force 1 - White - 42" -> "Air Force 1"
    final patterns = [
      RegExp(r'\s*-\s*\d{2}$'), // Loại bỏ " - 42"
      RegExp(r'\s*-\s*\w+\s*-\s*\d{2}$'), // Loại bỏ " - White - 42"
      RegExp(r'\s*\(\w+\)$'), // Loại bỏ " (White)"
      RegExp(r'\s*\d{2}$'), // Loại bỏ " 42"
    ];

    String baseName = productName.trim();
    for (var pattern in patterns) {
      baseName = baseName.replaceAll(pattern, '');
    }
    return baseName.trim();
  }

  // Customer: Group products - merge các variants (cùng tên, khác size/color) thành 1 product
  List<ProductGroup> _groupProducts(List<Product> products) {
    final Map<String, List<Product>> grouped = {};

    for (var product in products) {
      final baseName = _getBaseName(product.name);
      grouped.putIfAbsent(baseName, () => []).add(product);
    }

    return grouped.entries.map((entry) {
      final variants = entry.value;
      final sizes =
          variants.where((p) => p.size != null).map((p) => p.size!).toSet();
      final colors =
          variants.where((p) => p.color != null).map((p) => p.color!).toSet();

      // Chọn product đại diện (product đầu tiên hoặc có ảnh)
      final representative = variants.firstWhere(
        (p) => p.imageUrl != null && p.imageUrl!.isNotEmpty,
        orElse: () => variants.first,
      );

      return ProductGroup(
        representative: representative,
        allVariants: variants,
        availableSizes: sizes,
        availableColors: colors,
        totalVariants: variants.length,
      );
    }).toList();
  }

  List<ProductGroup> get filteredProductGroups {
    var result = List<ProductGroup>.from(_productGroups);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result =
          result.where((group) {
            final rep = group.representative;
            return rep.name.toLowerCase().contains(q) ||
                (rep.sku ?? '').toLowerCase().contains(q) ||
                group.availableColors.any((c) => c.toLowerCase().contains(q)) ||
                group.availableSizes.any((s) => s.toLowerCase().contains(q));
          }).toList();
    }

    // Size filter
    if (_selectedSize != null) {
      result =
          result
              .where((group) => group.availableSizes.contains(_selectedSize))
              .toList();
    }

    // Color filter
    if (_selectedColor != null) {
      result =
          result
              .where((group) => group.availableColors.contains(_selectedColor))
              .toList();
    }

    // Price filter (dựa vào representative)
    if (_minPrice != null) {
      result =
          result
              .where(
                (group) => group.representative.originalPrice >= _minPrice!,
              )
              .toList();
    }
    if (_maxPrice != null) {
      result =
          result
              .where(
                (group) => group.representative.originalPrice <= _maxPrice!,
              )
              .toList();
    }

    // Sorting
    switch (_sortBy) {
      case 'price-asc':
        result.sort(
          (a, b) => a.representative.originalPrice.compareTo(
            b.representative.originalPrice,
          ),
        );
        break;
      case 'price-desc':
        result.sort(
          (a, b) => b.representative.originalPrice.compareTo(
            a.representative.originalPrice,
          ),
        );
        break;
      case 'name':
        result.sort(
          (a, b) => a.representative.name.compareTo(b.representative.name),
        );
        break;
      case 'newest':
      default:
        result.sort(
          (a, b) =>
              b.representative.createdAt.compareTo(a.representative.createdAt),
        );
        break;
    }

    return result;
  }

  // Customer: Load products và tự động group chúng
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Load tất cả products từ API (raw data)
      final allProducts = await getAllProductsUseCase.call();
      _products =
          allProducts
              .where(
                (product) => product.stores.any(
                  (store) => store.storeId == warehouseStoreId,
                ),
              )
              .toList();
      // Group products lại (merge variants)
      _productGroups = _groupProducts(_products);
    } catch (e) {
      _products = [];
      _productGroups = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSize(String? size) {
    _selectedSize = size;
    notifyListeners();
  }

  void setColor(String? color) {
    _selectedColor = color;
    notifyListeners();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedSize = null;
    _selectedColor = null;
    _minPrice = null;
    _maxPrice = null;
    _sortBy = 'newest';
    notifyListeners();
  }
}
