import '../../repositories/store_repository.dart';

class DeleteStoreUseCase {
  final StoreRepository repository;
  DeleteStoreUseCase(this.repository);

  Future<bool> call(int id) => repository.delete(id);
}
