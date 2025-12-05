import 'package:shoestorefe/domain/repositories/user_repository.dart';

class ResetPassword {
  final UserRepository repo;
  ResetPassword(this.repo);

  Future<bool> call({
    required String phoneOrEmail,
    required String newPassword,
    String? oldPassword,
    String? otpCode,
  }) {
    return repo.resetPassword(
      phoneOrEmail: phoneOrEmail,
      newPassword: newPassword,
      oldPassword: oldPassword,
      otpCode: otpCode,
    );
  }
}
