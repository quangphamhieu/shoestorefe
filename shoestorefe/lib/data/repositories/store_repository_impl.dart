import '../../domain/entities/store.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/store_remote_data_source.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remote;
  StoreRepositoryImpl(this.remote);

  @override
  Future<Store> create({
    required String name,
    required String code,
    required String address,
    required String phone,
  }) {
    return remote.create(
      name: name,
      code: code,
      address: address,
      phone: phone,
    );
  }

  @override
  Future<bool> delete(int id) {
    return remote.delete(id);
  }

  @override
  Future<List<Store>> getAll() {
    return remote.getAll();
  }

  @override
  Future<Store?> getById(int id) {
    return remote.getById(id);
  }

  @override
  Future<Store?> update(
    int id, {
    required String name,
    required String code,
    required String address,
    required String phone,
    required int statusId,
  }) {
    return remote.update(
      id,
      name: name,
      code: code,
      address: address,
      phone: phone,
      statusId: statusId,
    );
  }
}
