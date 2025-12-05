import '../../entities/comment.dart';
import '../../repositories/comment_repository.dart';

class CreateCommentUseCase {
  final CommentRepository repository;
  CreateCommentUseCase(this.repository);

  Future<Comment> call({
    required int userId,
    required int productId,
    required String content,
    int? rating,
  }) {
    return repository.create(
      userId: userId,
      productId: productId,
      content: content,
      rating: rating,
    );
  }
}


