import '../../entities/supplier.dart';
import '../../repositories/supplier_repository.dart';

class CreateSupplierUseCase {
  final SupplierRepository repository;
  CreateSupplierUseCase(this.repository);

  Future<Supplier> call({
    required String name,
    String? code,
    String? contactInfo,
  }) => repository.create(name: name, code: code, contactInfo: contactInfo);
}
