import 'package:shoestorefe/domain/entities/user.dart';
import 'package:shoestorefe/domain/repositories/user_repository.dart';

class UpdateUser {
  final UserRepository repo;
  UpdateUser(this.repo);

  Future<User?> call({
    required int id,
    required String fullName,
    required String phone,
    String? email,
    required int gender,
    required int roleId,
    int? storeId,
    required int statusId,
  }) {
    return repo.update(
      id: id,
      fullName: fullName,
      phone: phone,
      email: email,
      gender: gender,
      roleId: roleId,
      storeId: storeId,
      statusId: statusId,
    );
  }
}
