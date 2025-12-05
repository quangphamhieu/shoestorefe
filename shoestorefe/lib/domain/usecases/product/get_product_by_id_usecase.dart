import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class GetProductByIdUseCase {
  final ProductRepository repository;
  GetProductByIdUseCase(this.repository);

  Future<Product?> call(int id) => repository.getById(id);
}
