import 'package:shoestorefe/data/models/user_model.dart';
import 'package:shoestorefe/domain/repositories/user_repository.dart';

class LoginUser {
  final UserRepository repo;
  LoginUser(this.repo);

  Future<LoginResponse?> call(String phoneOrEmail, String password) {
    return repo.login(phoneOrEmail, password);
  }
}
