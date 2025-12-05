import '../../entities/brand.dart';
import '../../repositories/brand_repository.dart';

class GetBrandByIdUseCase {
  final BrandRepository repository;
  GetBrandByIdUseCase(this.repository);

  Future<Brand?> call(int id) => repository.getById(id);
}
