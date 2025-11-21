import 'package:shoestorefe/domain/entities/user.dart';
import 'package:shoestorefe/domain/repositories/user_repository.dart';

class CreateUser {
  final UserRepository repo;
  CreateUser(this.repo);

  Future<User> call({
    required String fullName,
    required String phone,
    String? email,
    required String password,
    required int gender,
    required int roleId,
    int? storeId,
  }) {
    return repo.create(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
      gender: gender,
      roleId: roleId,
      storeId: storeId,
    );
  }
}
