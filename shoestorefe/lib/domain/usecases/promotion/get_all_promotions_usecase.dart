import '../../entities/promotion.dart';
import '../../repositories/promotion_repository.dart';

class GetAllPromotionsUseCase {
  final PromotionRepository repository;
  GetAllPromotionsUseCase(this.repository);

  Future<List<Promotion>> call() => repository.getAll();
}
