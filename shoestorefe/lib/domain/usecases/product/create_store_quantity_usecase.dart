import '../../entities/store_quantity.dart';
import '../../repositories/product_repository.dart';

class CreateStoreQuantityUseCase {
  final ProductRepository repository;
  CreateStoreQuantityUseCase(this.repository);

  Future<StoreQuantity?> call(
    int productId,
    int storeId,
    int quantity, {
    double? salePrice,
    String? storeName,
  }) => repository.createStoreQuantity(
    productId,
    storeId,
    quantity,
    salePrice: salePrice,
    storeName: storeName,
  );
}
