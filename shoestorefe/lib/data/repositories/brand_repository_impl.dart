import '../../domain/entities/brand.dart';
import '../../domain/repositories/brand_repository.dart';
import '../datasources/brand_remote_data_source.dart';

class BrandRepositoryImpl implements BrandRepository {
  final BrandRemoteDataSource remote;
  BrandRepositoryImpl(this.remote);

  @override
  Future<Brand?> getById(int id) async {
    return await remote.getById(id);
  }

  @override
  Future<List<Brand>> getAll() async {
    return await remote.getAll();
  }

  @override
  Future<Brand> create({
    required String name,
    String? code,
    String? description,
  }) async {
    return await remote.create(name, code: code, description: description);
  }

  @override
  Future<bool> delete(int id) async {
    return await remote.delete(id);
  }

  @override
  Future<Brand?> update(
    int id, {
    required String name,
    String? code,
    String? description,
    required int statusId,
  }) async {
    return await remote.update(
      id,
      name: name,
      code: code,
      description: description,
      statusId: statusId,
    );
  }
}
