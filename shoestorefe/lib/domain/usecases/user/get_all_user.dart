import 'package:shoestorefe/domain/entities/user.dart';
import 'package:shoestorefe/domain/repositories/user_repository.dart';

class GetAllUsers {
  final UserRepository repo;
  GetAllUsers(this.repo);

  Future<List<User>> call() => repo.getAll();
}
