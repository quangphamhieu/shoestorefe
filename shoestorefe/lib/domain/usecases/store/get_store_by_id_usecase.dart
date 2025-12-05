import '../../entities/store.dart';
import '../../repositories/store_repository.dart';

class GetStoreByIdUseCase {
  final StoreRepository repository;
  GetStoreByIdUseCase(this.repository);

  Future<Store?> call(int id) => repository.getById(id);
}
