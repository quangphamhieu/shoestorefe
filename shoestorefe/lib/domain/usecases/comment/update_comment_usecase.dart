import '../../entities/comment.dart';
import '../../repositories/comment_repository.dart';

class UpdateCommentUseCase {
  final CommentRepository repository;
  UpdateCommentUseCase(this.repository);

  Future<Comment?> call(
    int id, {
    required String content,
    int? rating,
  }) {
    return repository.update(
      id,
      content: content,
      rating: rating,
    );
  }
}


