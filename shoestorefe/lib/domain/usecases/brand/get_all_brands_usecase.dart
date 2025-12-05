import '../../entities/brand.dart';
import '../../repositories/brand_repository.dart';

class GetAllBrandsUseCase {
  final BrandRepository repository;
  GetAllBrandsUseCase(this.repository);

  Future<List<Brand>> call() => repository.getAll();
}
