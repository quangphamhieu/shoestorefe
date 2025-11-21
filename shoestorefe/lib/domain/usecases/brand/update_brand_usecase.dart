import '../../entities/brand.dart';
import '../../repositories/brand_repository.dart';

class UpdateBrandUseCase {
  final BrandRepository repository;
  UpdateBrandUseCase(this.repository);

  Future<Brand?> call(
    int id, {
    required String name,
    String? code,
    String? description,
    required int statusId,
  }) => repository.update(
    id,
    name: name,
    code: code,
    description: description,
    statusId: statusId,
  );
}
