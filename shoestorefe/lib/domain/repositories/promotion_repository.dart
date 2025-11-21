import '../entities/promotion.dart';

abstract class PromotionRepository {
  Future<List<Promotion>> getAll();
  Future<Promotion?> getById(int id);
  Future<Promotion> create({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int statusId,
    required List<Map<String, dynamic>>
    products, // [{productId, discountPercent}]
    required List<int> storeIds,
  });
  Future<Promotion?> update(
    int id, {
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int statusId,
    required List<Map<String, dynamic>> products,
    required List<int> storeIds,
  });
  Future<bool> delete(int id);
}
