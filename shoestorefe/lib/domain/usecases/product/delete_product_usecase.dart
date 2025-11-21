import '../../repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repository;
  DeleteProductUseCase(this.repository);

  Future<bool> call(int id) => repository.delete(id);
}
