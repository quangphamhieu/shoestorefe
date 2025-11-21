import '../../entities/store.dart';
import '../../repositories/store_repository.dart';

class CreateStoreUseCase {
  final StoreRepository repository;
  CreateStoreUseCase(this.repository);

  Future<Store> call({
    required String name,
    required String code,
    required String address,
    required String phone,
  }) =>
      repository.create(name: name, code: code, address: address, phone: phone);
}
