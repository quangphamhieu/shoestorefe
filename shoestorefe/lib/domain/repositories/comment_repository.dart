import '../entities/comment.dart';

abstract class CommentRepository {
  Future<List<Comment>> getByProductId(int productId);
  Future<Comment> create({
    required int userId,
    required int productId,
    required String content,
    int? rating,
  });
  Future<Comment?> update(
    int id, {
    required String content,
    int? rating,
  });
  Future<bool> delete(int id);
}


