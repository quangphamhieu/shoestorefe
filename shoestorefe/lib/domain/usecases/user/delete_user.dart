import 'package:shoestorefe/domain/repositories/user_repository.dart';

class DeleteUser {
  final UserRepository repo;
  DeleteUser(this.repo);

  Future<bool> call(int id) => repo.delete(id);
}
