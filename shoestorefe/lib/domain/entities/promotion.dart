import 'promotion_product.dart';
import 'promotion_store.dart';

class Promotion {
  final int id;
  final String? code;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int statusId;
  final String? statusName;
  final List<PromotionProduct> products;
  final List<PromotionStore> stores;

  Promotion({
    required this.id,
    this.code,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.statusId,
    this.statusName,
    required this.products,
    required this.stores,
  });
}
