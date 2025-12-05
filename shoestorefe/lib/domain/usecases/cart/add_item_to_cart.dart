import '../../repositories/cart_repository.dart';

class AddItemToCart {
  final CartRepository repository;
  AddItemToCart(this.repository);

  Future<void> call(int productId,int quantity) {
    return repository.addItemToCart(productId, quantity);
  }
}