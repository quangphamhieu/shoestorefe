import '../../entities/supplier.dart';
import '../../repositories/supplier_repository.dart';

class GetSupplierByIdUseCase {
  final SupplierRepository repository;
  GetSupplierByIdUseCase(this.repository);

  Future<Supplier?> call(int id) => repository.getById(id);
}
