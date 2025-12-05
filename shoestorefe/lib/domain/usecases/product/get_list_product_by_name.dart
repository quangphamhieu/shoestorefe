import 'package:shoestorefe/domain/entities/product.dart';

import '../../repositories/product_repository.dart';

class GetListProductByNameUseCase{
  final ProductRepository repository;
  GetListProductByNameUseCase(this.repository);
  Future<List<Product>> call(String name) async {
    return await repository.getProductsByName(name);
  }
}