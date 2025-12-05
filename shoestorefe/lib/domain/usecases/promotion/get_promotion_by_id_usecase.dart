import '../../entities/promotion.dart';
import '../../repositories/promotion_repository.dart';

class GetPromotionByIdUseCase {
  final PromotionRepository repository;
  GetPromotionByIdUseCase(this.repository);

  Future<Promotion?> call(int id) => repository.getById(id);
}
