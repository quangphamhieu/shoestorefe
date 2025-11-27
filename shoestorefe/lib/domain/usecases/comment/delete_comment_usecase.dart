import '../../repositories/comment_repository.dart';

class DeleteCommentUseCase {
  final CommentRepository repository;
  DeleteCommentUseCase(this.repository);

  Future<bool> call(int id) {
    return repository.delete(id);
  }
}


