import '../../repositories/user_repository.dart';

class ChangePassword {
  final UserRepository repository;

  ChangePassword(this.repository);

  Future<bool> call({
    required String phoneOrEmail,
    required String oldPassword,
    required String newPassword,
  }) async {
    return await repository.changePassword(
      phoneOrEmail: phoneOrEmail,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
