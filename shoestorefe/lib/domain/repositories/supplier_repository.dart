import '../entities/supplier.dart';

abstract class SupplierRepository {
  Future<List<Supplier>> getAll();
  Future<Supplier?> getById(int id);
  Future<Supplier> create({
    required String name,
    String? code,
    String? contactInfo,
  });
  Future<Supplier?> update(
    int id, {
    required String name,
    String? code,
    String? contactInfo,
    required int statusId,
  });
  Future<bool> delete(int id);
}
