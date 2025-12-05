import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json_utils.dart';
import '../models/comment_model.dart';

class CommentRemoteDataSource {
  final ApiClient client;
  CommentRemoteDataSource(this.client);

  Future<List<CommentModel>> getByProductId(int productId) async {
    final response =
        await client.get('${ApiEndpoint.comments}/product/$productId');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => CommentModel.fromJson(JsonUtils.normalizeMap(e)))
          .toList();
    }
    return [];
  }

  Future<CommentModel> create({
    required int userId,
    required int productId,
    required String content,
    int? rating,
  }) async {
    final response = await client.post(ApiEndpoint.comments, {
      'userId': userId,
      'productId': productId,
      'content': content,
      if (rating != null) 'rating': rating,
    });
    return CommentModel.fromJson(JsonUtils.normalizeMap(response.data));
  }

  Future<CommentModel?> update(
    int id, {
    required String content,
    int? rating,
  }) async {
    final response = await client.put('${ApiEndpoint.comments}/$id', {
      'content': content,
      if (rating != null) 'rating': rating,
    });
    final data = response.data;
    if (data is Map<String, dynamic> || data is Map) {
      return CommentModel.fromJson(JsonUtils.normalizeMap(data));
    }
    return null;
  }

  Future<bool> delete(int id) async {
    final response = await client.delete('${ApiEndpoint.comments}/$id');
    return response.statusCode == 200 || response.statusCode == 204;
  }
}


