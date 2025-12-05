import 'package:shoestorefe/domain/entities/user.dart';
import 'package:shoestorefe/domain/repositories/user_repository.dart';

class SignupUser {
  final UserRepository repo;
  SignupUser(this.repo);

  Future<User> call({
    required String fullName,
    required String phone,
    String? email,
    required String password,
    required int gender,
  }) {
    return repo.signup(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
      gender: gender,
    );
  }
}
