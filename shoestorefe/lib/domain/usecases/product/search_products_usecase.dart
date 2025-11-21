import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class SearchProductsUseCase {
  final ProductRepository repository;
  SearchProductsUseCase(this.repository);

  Future<List<Product>> call({
    String? name,
    String? color,
    String? size,
    double? minPrice,
    double? maxPrice,
  }) => repository.search(
    name: name,
    color: color,
    size: size,
    minPrice: minPrice,
    maxPrice: maxPrice,
  );
}
