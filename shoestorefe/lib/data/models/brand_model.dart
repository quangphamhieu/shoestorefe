import '../../domain/entities/brand.dart';

class BrandModel extends Brand {
  BrandModel({
    required int id,
    String? code,
    required String name,
    String? description,
    required int statusId,
  }) : super(
         id: id,
         code: code,
         name: name,
         description: description,
         statusId: statusId,
       );

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
    id: json['id'] as int,
    code: json['code'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
    statusId: json['statusId'] as int? ?? 1,
  );

  Map<String, dynamic> toCreateJson() => {
    'code': code,
    'name': name,
    'description': description,
  };

  Map<String, dynamic> toUpdateJson(int statusId) => {
    'code': code,
    'name': name,
    'description': description,
    'statusId': statusId,
  };
}
