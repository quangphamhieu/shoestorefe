import '../../entities/store.dart';
import '../../repositories/store_repository.dart';

class UpdateStoreUseCase {
  final StoreRepository repository;
  UpdateStoreUseCase(this.repository);

  Future<Store?> call(
    int id, {
    required String name,
    required String code,
    required String address,
    required String phone,
    required int statusId,
  }) => repository.update(
    id,
    name: name,
    code: code,
    address: address,
    phone: phone,
    statusId: statusId,
  );
}
