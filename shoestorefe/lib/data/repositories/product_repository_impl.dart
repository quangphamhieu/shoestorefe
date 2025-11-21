import '../../domain/entities/product.dart';
import '../../domain/entities/store_quantity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;
  ProductRepositoryImpl(this.remote);

  @override
  Future<Product?> getById(int id) async {
    return await remote.getById(id);
  }

  @override
  Future<List<Product>> getAll() async {
    return await remote.getAll();
  }

  @override
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
  }) async {
    return await remote.create(
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
  }

  @override
  Future<bool> delete(int id) async {
    return await remote.delete(id);
  }

  @override
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
  }) async {
    return await remote.update(
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
  }

  @override
  Future<List<Product>> search({
    String? name,
    String? color,
    String? size,
    double? minPrice,
    double? maxPrice,
  }) async {
    return await remote.search(
      name: name,
      color: color,
      size: size,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  @override
  Future<List<String>> suggest(String keyword) async {
    return await remote.suggest(keyword);
  }

  @override
  Future<StoreQuantity?> createStoreQuantity(
    int productId,
    int storeId,
    int quantity, {
    double? salePrice,
    String? storeName,
  }) async {
    return await remote.createStoreQuantity(
      productId,
      storeId,
      quantity,
      salePrice: salePrice,
      storeName: storeName,
    );
  }

  @override
  Future<StoreQuantity?> updateStoreQuantity(
    int productId,
    int storeId,
    int quantity, {
    double? salePrice,
    String? storeName,
  }) async {
    return await remote.updateStoreQuantity(
      productId,
      storeId,
      quantity,
      salePrice: salePrice,
      storeName: storeName,
    );
  }
}
