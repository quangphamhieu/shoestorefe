import '../entities/brand.dart';

abstract class BrandRepository {
  Future<List<Brand>> getAll();
  Future<Brand?> getById(int id);
  Future<Brand> create({
    required String name,
    String? code,
    String? description,
  });
  Future<Brand?> update(
    int id, {
    required String name,
    String? code,
    String? description,
    required int statusId,
  });
  Future<bool> delete(int id);
}
