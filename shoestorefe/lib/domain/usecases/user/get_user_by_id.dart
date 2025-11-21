import 'package:shoestorefe/domain/entities/user.dart';
import 'package:shoestorefe/domain/repositories/user_repository.dart';

class GetUserById {
  final UserRepository repo;
  GetUserById(this.repo);

  Future<User?> call(int id) => repo.getById(id);
}
