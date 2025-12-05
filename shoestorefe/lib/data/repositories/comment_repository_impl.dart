import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_data_source.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;
  CommentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Comment> create({
    required int userId,
    required int productId,
    required String content,
    int? rating,
  }) async {
    final model = await remoteDataSource.create(
      userId: userId,
      productId: productId,
      content: content,
      rating: rating,
    );
    return model.toEntity();
  }

  @override
  Future<bool> delete(int id) {
    return remoteDataSource.delete(id);
  }

  @override
  Future<List<Comment>> getByProductId(int productId) async {
    final models = await remoteDataSource.getByProductId(productId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Comment?> update(
    int id, {
    required String content,
    int? rating,
  }) async {
    final model = await remoteDataSource.update(
      id,
      content: content,
      rating: rating,
    );
    return model?.toEntity();
  }
}


