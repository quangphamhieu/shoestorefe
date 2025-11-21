import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required int id,
    required String fullName,
    required String phone,
    String? email,
    required int gender,
    required String roleName,
    required String statusName,
    int? storeId,
    required DateTime createdAt,
  }) : super(
         id: id,
         fullName: fullName,
         phone: phone,
         email: email,
         gender: gender,
         roleName: roleName,
         statusName: statusName,
         storeId: storeId,
         createdAt: createdAt,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      DateTime parseCreatedAt() {
        if (json["createdAt"] == null) {
          return DateTime.now();
        }
        if (json["createdAt"] is String) {
          try {
            return DateTime.parse(json["createdAt"] as String);
          } catch (e) {
            return DateTime.now();
          }
        }
        return DateTime.now();
      }

      return UserModel(
        id:
            json["id"] is int
                ? json["id"] as int
                : (json["id"] is num ? (json["id"] as num).toInt() : 0),
        fullName: json["fullName"]?.toString() ?? '',
        phone: json["phone"]?.toString() ?? '',
        email: json["email"]?.toString(),
        gender:
            json["gender"] is int
                ? json["gender"] as int
                : (json["gender"] is num ? (json["gender"] as num).toInt() : 0),
        roleName: json["roleName"]?.toString() ?? '',
        statusName: json["statusName"]?.toString() ?? '',
        storeId:
            json["storeId"] is int
                ? json["storeId"] as int
                : (json["storeId"] is num
                    ? (json["storeId"] as num).toInt()
                    : null),
        createdAt: parseCreatedAt(),
      );
    } catch (e) {
      // Fallback nếu có lỗi khi parse
      return UserModel(
        id: 0,
        fullName: json["fullName"]?.toString() ?? '',
        phone: json["phone"]?.toString() ?? '',
        email: json["email"]?.toString(),
        gender: 0,
        roleName: json["roleName"]?.toString() ?? 'Customer',
        statusName: json["statusName"]?.toString() ?? 'Active',
        storeId: null,
        createdAt: DateTime.now(),
      );
    }
  }
}

/// ---------- LOGIN RESPONSE ----------
class LoginResponse {
  final int userId;
  final String fullName;
  final String roleName;
  final String token;

  LoginResponse({
    required this.userId,
    required this.fullName,
    required this.roleName,
    required this.token,
  });
}

class LoginResponseModel extends LoginResponse {
  LoginResponseModel({
    required int userId,
    required String fullName,
    required String roleName,
    required String token,
  }) : super(
         userId: userId,
         fullName: fullName,
         roleName: roleName,
         token: token,
       );

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        userId: json["userId"],
        fullName: json["fullName"],
        roleName: json["roleName"],
        token: json["token"],
      );
}
