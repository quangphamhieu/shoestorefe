import '../../entities/store.dart';
import '../../repositories/store_repository.dart';

class GetAllStoresUseCase {
  final StoreRepository repository;
  GetAllStoresUseCase(this.repository);

  Future<List<Store>> call() => repository.getAll();
}
