import '../../repositories/user_repository.dart';

class ForgotPassword {
  final UserRepository repository;

  ForgotPassword(this.repository);

  Future<bool> call({
    required String phoneOrEmail,
  }) async {
    return await repository.forgotPassword(
      phoneOrEmail: phoneOrEmail,
    );
  }
}
