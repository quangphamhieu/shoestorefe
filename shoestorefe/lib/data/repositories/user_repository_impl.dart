import 'package:shoestorefe/data/datasources/user_remote_data_source.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;
  UserRepositoryImpl(this.remote);

  @override
  Future<List<User>> getAll() => remote.getAll();

  @override
  Future<User?> getById(int id) => remote.getById(id);

  @override
  Future<User> create({
    required String fullName,
    required String phone,
    String? email,
    required String password,
    required int gender,
    required int roleId,
    int? storeId,
  }) async {
    return await remote.create({
      "fullName": fullName,
      "phone": phone,
      "email": email,
      "password": password,
      "gender": gender,
      "roleId": roleId,
      "storeId": storeId,
    });
  }

  @override
  Future<User?> update({
    required int id,
    required String fullName,
    required String phone,
    String? email,
    required int gender,
    required int roleId,
    int? storeId,
    required int statusId,
  }) async {
    return await remote.update(id, {
      "id": id,
      "fullName": fullName,
      "phone": phone,
      "email": email,
      "gender": gender,
      "roleId": roleId,
      "storeId": storeId,
      "statusId": statusId,
    });
  }

  @override
  Future<User?> updateMyProfile({
    required int id,
    required String fullName,
    required String phone,
    String? email,
    required int gender,
    required int roleId,
    int? storeId,
    required int statusId,
  }) async {
    return await remote.updateMyProfile({
      "id": id,
      "fullName": fullName,
      "phone": phone,
      "email": email,
      "gender": gender,
      "roleId": roleId,
      "storeId": storeId,
      "statusId": statusId,
    });
  }

  @override
  Future<bool> delete(int id) => remote.delete(id);

  @override
  Future<LoginResponse?> login(String phoneOrEmail, String password) =>
      remote.login(phoneOrEmail, password);

  @override
  Future<User> signup({
    required String fullName,
    required String phone,
    String? email,
    required String password,
    required int gender,
  }) async {
    return await remote.signup({
      "fullName": fullName,
      "phone": phone,
      "email": email,
      "password": password,
      "gender": gender,
    });
  }

  @override
  Future<bool> resetPassword({
    required String phoneOrEmail,
    required String newPassword,
    String? oldPassword,
    String? otpCode,
  }) async {
    return await remote.resetPassword({
      "phoneOrEmail": phoneOrEmail,
      "newPassword": newPassword,
      "oldPassword": oldPassword,
      "otpCode": otpCode,
    });
  }
}
