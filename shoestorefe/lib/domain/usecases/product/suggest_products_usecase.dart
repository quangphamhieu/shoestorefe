import '../../repositories/product_repository.dart';

class SuggestProductsUseCase {
  final ProductRepository repository;
  SuggestProductsUseCase(this.repository);

  Future<List<String>> call(String keyword) => repository.suggest(keyword);
}
