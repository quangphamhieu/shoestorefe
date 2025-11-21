import '../../domain/entities/store.dart';

class StoreModel extends Store {
  StoreModel({
    required int id,
    String? code,
    required String name,
    String? address,
    String? phone,
    required int statusId,
    required DateTime createdAt,
  }) : super(
         id: id,
         code: code,
         name: name,
         address: address,
         phone: phone,
         statusId: statusId,
         createdAt: createdAt,
       );

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
    id: json['id'] as int,
    code: json['code'] as String?,
    name: json['name'] as String,
    address: json['address'] as String?,
    phone: json['phone'] as String?,
    statusId: json['statusId'] as int? ?? 1,
    createdAt:
        json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
  );

  Map<String, dynamic> toCreateJson() => {
    'code': code,
    'name': name,
    'address': address,
    'phone': phone,
  };

  Map<String, dynamic> toUpdateJson(int statusId) => {
    'code': code,
    'name': name,
    'address': address,
    'phone': phone,
    'statusId': statusId,
  };
}
