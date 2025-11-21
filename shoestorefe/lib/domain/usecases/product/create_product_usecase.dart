import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository;
  CreateProductUseCase(this.repository);

  Future<Product> call({
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
  }) => repository.create(
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
