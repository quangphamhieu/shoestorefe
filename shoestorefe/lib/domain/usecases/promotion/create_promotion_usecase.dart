import '../../entities/promotion.dart';
import '../../repositories/promotion_repository.dart';

class CreatePromotionUseCase {
  final PromotionRepository repository;
  CreatePromotionUseCase(this.repository);

  Future<Promotion> call({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int statusId,
    required List<Map<String, dynamic>> products,
    required List<int> storeIds,
  }) => repository.create(
    name: name,
    startDate: startDate,
    endDate: endDate,
    statusId: statusId,
    products: products,
    storeIds: storeIds,
  );
}
