import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_remote_data_source.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDataSource remote;
  SupplierRepositoryImpl(this.remote);

  @override
  Future<Supplier?> getById(int id) async {
    return await remote.getById(id);
  }

  @override
  Future<List<Supplier>> getAll() async {
    return await remote.getAll();
  }

  @override
  Future<Supplier> create({
    required String name,
    String? code,
    String? contactInfo,
  }) async {
    return await remote.create(name, code: code, contactInfo: contactInfo);
  }

  @override
  Future<bool> delete(int id) async {
    return await remote.delete(id);
  }

  @override
  Future<Supplier?> update(
    int id, {
    required String name,
    String? code,
    String? contactInfo,
    required int statusId,
  }) async {
    return await remote.update(
      id,
      name: name,
      code: code,
      contactInfo: contactInfo,
      statusId: statusId,
    );
  }
}
