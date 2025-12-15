import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class BatchCreateProductUseCase {
  final ProductRepository repository;
  BatchCreateProductUseCase(this.repository);

  Future<List<Product>> call({
    required String name,
    int? brandId,
    int? supplierId,
    required double costPrice,
    required double originalPrice,
    String? color,
    required int sizeStart,
    required int sizeEnd,
    String? description,
    String? imageUrl,
    String? imageFilePath,
    List<int>? imageBytes,
    String? imageFileName,
  }) => repository.batchCreate(
    name: name,
    brandId: brandId,
    supplierId: supplierId,
    costPrice: costPrice,
    originalPrice: originalPrice,
    color: color,
    sizeStart: sizeStart,
    sizeEnd: sizeEnd,
    description: description,
    imageUrl: imageUrl,
    imageFilePath: imageFilePath,
    imageBytes: imageBytes,
    imageFileName: imageFileName,
  );
}
