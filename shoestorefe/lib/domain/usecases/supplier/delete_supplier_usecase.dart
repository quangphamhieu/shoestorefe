import '../../repositories/supplier_repository.dart';

class DeleteSupplierUseCase {
  final SupplierRepository repository;
  DeleteSupplierUseCase(this.repository);

  Future<bool> call(int id) => repository.delete(id);
}
