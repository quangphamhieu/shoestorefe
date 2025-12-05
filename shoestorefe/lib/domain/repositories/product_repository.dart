import '../entities/product.dart';
import '../entities/store_quantity.dart';

abstract class ProductRepository {
  Future<List<Product>> getAll();
  Future<Product?> getById(int id);
  Future<Product> create({
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
  });
  Future<Product?> update(
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
  });
  Future<bool> delete(int id);
  Future<List<Product>> search({
    String? name,
    String? color,
    String? size,
    double? minPrice,
    double? maxPrice,
  });
  Future<List<String>> suggest(String keyword);
  Future<StoreQuantity?> createStoreQuantity(
    int productId,
    int storeId,
    int quantity, {
    double? salePrice,
    String? storeName,
  });
  Future<StoreQuantity?> updateStoreQuantity(
    int productId,
    int storeId,
    int quantity, {
    double? salePrice,
    String? storeName,
  });
  Future<List<Product>> getProductsByName(String name);
}
