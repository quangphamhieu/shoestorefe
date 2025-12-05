import '../../repositories/brand_repository.dart';

class DeleteBrandUseCase {
  final BrandRepository repository;
  DeleteBrandUseCase(this.repository);

  Future<bool> call(int id) => repository.delete(id);
}
