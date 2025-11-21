import '../../entities/brand.dart';
import '../../repositories/brand_repository.dart';

class CreateBrandUseCase {
  final BrandRepository repository;
  CreateBrandUseCase(this.repository);

  Future<Brand> call({
    required String name,
    String? code,
    String? description,
  }) => repository.create(name: name, code: code, description: description);
}
