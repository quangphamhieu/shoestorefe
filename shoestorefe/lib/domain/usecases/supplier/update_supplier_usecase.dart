import '../../entities/supplier.dart';
import '../../repositories/supplier_repository.dart';

class UpdateSupplierUseCase {
  final SupplierRepository repository;
  UpdateSupplierUseCase(this.repository);

  Future<Supplier?> call(
    int id, {
    required String name,
    String? code,
    String? contactInfo,
    required int statusId,
  }) => repository.update(
    id,
    name: name,
    code: code,
    contactInfo: contactInfo,
    statusId: statusId,
  );
}
