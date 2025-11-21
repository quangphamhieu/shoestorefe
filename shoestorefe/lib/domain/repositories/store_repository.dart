import '../entities/store.dart';

abstract class StoreRepository {
  Future<List<Store>> getAll();
  Future<Store?> getById(int id);
  Future<Store> create({
    required String name,
    required String code,
    required String address,
    required String phone,
  });
  Future<Store?> update(
    int id, {
    required String name,
    required String code,
    required String address,
    required String phone,
    required int statusId,
  });
  Future<bool> delete(int id);
}
