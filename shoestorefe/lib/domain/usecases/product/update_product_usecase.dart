import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository repository;
  UpdateProductUseCase(this.repository);

  Future<Product?> call(
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
  }) => repository.update(
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
