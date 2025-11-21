import 'package:flutter/material.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/product/get_all_products_usecase.dart';
import '../../../domain/usecases/product/get_product_by_id_usecase.dart';
import '../../../domain/usecases/product/create_product_usecase.dart';
import '../../../domain/usecases/product/update_product_usecase.dart';
import '../../../domain/usecases/product/delete_product_usecase.dart';
import '../../../domain/usecases/product/search_products_usecase.dart';
import '../../../domain/usecases/product/create_store_quantity_usecase.dart';
import '../../../domain/usecases/product/update_store_quantity_usecase.dart';

class ProductProvider extends ChangeNotifier {
  final GetAllProductsUseCase getAllUseCase;
  final GetProductByIdUseCase getByIdUseCase;
  final CreateProductUseCase createUseCase;
  final UpdateProductUseCase updateUseCase;
  final DeleteProductUseCase deleteUseCase;
  final SearchProductsUseCase searchUseCase;
  final CreateStoreQuantityUseCase createStoreQuantityUseCase;
  final UpdateStoreQuantityUseCase updateStoreQuantityUseCase;

  ProductProvider({
    required this.getAllUseCase,
    required this.getByIdUseCase,
    required this.createUseCase,
    required this.updateUseCase,
    required this.deleteUseCase,
    required this.searchUseCase,
    required this.createStoreQuantityUseCase,
    required this.updateStoreQuantityUseCase,
  });

  List<Product> _products = [];
  List<Product> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _selectedProductId;
  int? get selectedProductId => _selectedProductId;

  String _search = '';
  String get search => _search;

  // Admin: Hiển thị TẤT CẢ products (không group, mỗi size/màu là 1 product riêng)
  List<Product> get filteredProducts {
    if (_search.isEmpty) return _products;
    final q = _search.toLowerCase();
    return _products
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              (p.sku ?? '').toLowerCase().contains(q) ||
              (p.color ?? '').toLowerCase().contains(q) ||
              (p.size ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await getAllUseCase.call();
    } catch (_) {
      _products = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String s) {
    _search = s;
    notifyListeners();
  }

  void selectProduct(int? id) {
    _selectedProductId = id;
    notifyListeners();
  }

  Future<Product?> getSelectedProductDetail() async {
    if (_selectedProductId == null) return null;
    return await getByIdUseCase.call(_selectedProductId!);
  }

  Future<bool> createProduct({
    required String name,
    int? brandId,
    int? supplierId,
    required double costPrice,
    required double originalPrice,
    String? color,
    String? size,
    String? description,
    String? imageUrl,
    String? imageFilePath,
    List<int>? imageBytes,
    String? imageFileName,
  }) async {
    try {
      await createUseCase.call(
        name: name,
        brandId: brandId,
        supplierId: supplierId,
        costPrice: costPrice,
        originalPrice: originalPrice,
        color: color,
        size: size,
        description: description,
        imageUrl: imageUrl,
        imageFilePath: imageFilePath,
        imageBytes: imageBytes,
        imageFileName: imageFileName,
      );
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduct(
    int id, {
    required String name,
    int? brandId,
    int? supplierId,
    required double costPrice,
    required double originalPrice,
    String? color,
    String? size,
    String? description,
    String? imageUrl,
    String? imageFilePath,
    List<int>? imageBytes,
    String? imageFileName,
    required int statusId,
  }) async {
    try {
      await updateUseCase.call(
        id,
        name: name,
        brandId: brandId,
        supplierId: supplierId,
        costPrice: costPrice,
        originalPrice: originalPrice,
        color: color,
        size: size,
        description: description,
        imageUrl: imageUrl,
        imageFilePath: imageFilePath,
        imageBytes: imageBytes,
        imageFileName: imageFileName,
        statusId: statusId,
      );
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSelectedProduct() async {
    if (_selectedProductId == null) return false;
    final result = await deleteUseCase.call(_selectedProductId!);
    if (result) {
      await loadAll();
      selectProduct(null);
    }
    return result;
  }

  Future<bool> createStoreQuantity(
    int productId,
    int storeId,
    int quantity, {
    double? salePrice,
    String? storeName,
  }) async {
    try {
      final result = await createStoreQuantityUseCase.call(
        productId,
        storeId,
        quantity,
        salePrice: salePrice,
        storeName: storeName,
      );
      if (result != null) {
        await loadAll();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateStoreQuantity(
    int productId,
    int storeId,
    int quantity, {
    double? salePrice,
    String? storeName,
  }) async {
    try {
      final result = await updateStoreQuantityUseCase.call(
        productId,
        storeId,
        quantity,
        salePrice: salePrice,
        storeName: storeName,
      );
      if (result != null) {
        await loadAll();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}
