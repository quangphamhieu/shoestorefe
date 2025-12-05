import '../../entities/supplier.dart';
import '../../repositories/supplier_repository.dart';

class GetAllSuppliersUseCase {
  final SupplierRepository repository;
  GetAllSuppliersUseCase(this.repository);

  Future<List<Supplier>> call() => repository.getAll();
}
