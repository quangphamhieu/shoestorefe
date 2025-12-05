import '../../entities/promotion.dart';
import '../../repositories/promotion_repository.dart';

class UpdatePromotionUseCase {
  final PromotionRepository repository;
  UpdatePromotionUseCase(this.repository);

  Future<Promotion?> call(
    int id, {
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int statusId,
    required List<Map<String, dynamic>> products,
    required List<int> storeIds,
  }) => repository.update(
    id,
    name: name,
    startDate: startDate,
    endDate: endDate,
    statusId: statusId,
    products: products,
    storeIds: storeIds,
  );
}
