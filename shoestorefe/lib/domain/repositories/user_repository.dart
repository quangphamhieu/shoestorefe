import 'package:shoestorefe/data/models/user_model.dart';

import '../entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getAll();
  Future<User?> getById(int id);

  Future<User> create({
    required String fullName,
    required String phone,
    String? email,
    required String password,
    required int gender,
    required int roleId,
    int? storeId,
  });

  Future<User?> update({
    required int id,
    required String fullName,
    required String phone,
    String? email,
    required int gender,
    required int roleId,
    int? storeId,
    required int statusId,
  });

  Future<bool> delete(int id);

  Future<LoginResponse?> login(String phoneOrEmail, String password);

  Future<User> signup({
    required String fullName,
    required String phone,
    String? email,
    required String password,
    required int gender,
  });

  Future<bool> resetPassword({
    required String phoneOrEmail,
    required String newPassword,
    String? oldPassword,
    String? otpCode,
  });
}
