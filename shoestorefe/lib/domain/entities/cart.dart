import 'cart_item.dart';

class Cart {
  final int id;
  final int userId;
  final int statusId;
  final DateTime createAt;
  final List<CartItem> items;
  Cart({
    required this.id,
    required this.userId,
    required this.statusId,
    required this.createAt,
    required this.items
  });
}