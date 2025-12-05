import '../../repositories/promotion_repository.dart';

class DeletePromotionUseCase {
  final PromotionRepository repository;
  DeletePromotionUseCase(this.repository);

  Future<bool> call(int id) => repository.delete(id);
}
