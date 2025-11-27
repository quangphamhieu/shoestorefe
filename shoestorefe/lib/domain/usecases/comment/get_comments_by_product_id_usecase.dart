import '../../entities/comment.dart';
import '../../repositories/comment_repository.dart';

class GetCommentsByProductIdUseCase {
  final CommentRepository repository;
  GetCommentsByProductIdUseCase(this.repository);

  Future<List<Comment>> call(int productId) {
    return repository.getByProductId(productId);
  }
}


