import '../../domain/entities/promotion.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../datasources/promotion_remote_data_source.dart';
import '../models/promotion_model.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionRemoteDataSource remote;

  PromotionRepositoryImpl(this.remote);

  @override
  Future<List<Promotion>> getAll() async {
    return await remote.getAll();
  }

  @override
  Future<Promotion?> getById(int id) async {
    return await remote.getById(id);
  }

  @override
  Future<Promotion> create({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int statusId,
    required List<Map<String, dynamic>> products,
    required List<int> storeIds,
  }) async {
    final promotion = PromotionModel(
      id: 0,
      name: name,
      startDate: startDate,
      endDate: endDate,
      statusId: statusId,
      products:
          products
              .map(
                (p) => PromotionProductModel(
                  productId: p['productId'] as int,
                  productName: '',
                  discountPercent: (p['discountPercent'] as num).toDouble(),
                ),
              )
              .toList(),
      stores: storeIds.map((id) => PromotionStoreModel(storeId: id)).toList(),
    );
    return await remote.create(promotion);
  }

  @override
  Future<Promotion?> update(
    int id, {
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int statusId,
    required List<Map<String, dynamic>> products,
    required List<int> storeIds,
  }) async {
    final promotion = PromotionModel(
      id: id,
      name: name,
      startDate: startDate,
      endDate: endDate,
      statusId: statusId,
      products:
          products
              .map(
                (p) => PromotionProductModel(
                  productId: p['productId'] as int,
                  productName: '',
                  discountPercent: (p['discountPercent'] as num).toDouble(),
                ),
              )
              .toList(),
      stores: storeIds.map((id) => PromotionStoreModel(storeId: id)).toList(),
    );
    return await remote.update(id, promotion);
  }

  @override
  Future<bool> delete(int id) async {
    return await remote.delete(id);
  }
}
