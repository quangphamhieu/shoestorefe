import '../../domain/entities/supplier.dart';

class SupplierModel extends Supplier {
  SupplierModel({
    required int id,
    String? code,
    required String name,
    String? contactInfo,
    required int statusId,
  }) : super(
         id: id,
         code: code,
         name: name,
         contactInfo: contactInfo,
         statusId: statusId,
       );

  factory SupplierModel.fromJson(Map<String, dynamic> json) => SupplierModel(
    id: json['id'] as int,
    code: json['code'] as String?,
    name: json['name'] as String,
    contactInfo: json['contactInfo'] as String?,
    statusId: json['statusId'] as int? ?? 1,
  );

  Map<String, dynamic> toCreateJson() => {
    'code': code,
    'name': name,
    'contactInfo': contactInfo,
  };

  Map<String, dynamic> toUpdateJson(int statusId) => {
    'code': code,
    'name': name,
    'contactInfo': contactInfo,
    'statusId': statusId,
  };
}
