import '../../domain/entities/comment.dart';
import '../../core/utils/json_utils.dart';

class CommentModel {
  final int id;
  final int userId;
  final String userName;
  final int productId;
  final String productName;
  final String content;
  final int? rating;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.productId,
    required this.productName,
    required this.content,
    this.rating,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final normalized = JsonUtils.normalizeMap(json);
    return CommentModel(
      id: normalized['id'] is int
          ? normalized['id'] as int
          : int.tryParse(normalized['id']?.toString() ?? '') ?? 0,
      userId: normalized['userId'] is int
          ? normalized['userId'] as int
          : int.tryParse(normalized['userId']?.toString() ?? '') ?? 0,
      userName: normalized['userName']?.toString() ?? '',
      productId: normalized['productId'] is int
          ? normalized['productId'] as int
          : int.tryParse(normalized['productId']?.toString() ?? '') ?? 0,
      productName: normalized['productName']?.toString() ?? '',
      content: normalized['content']?.toString() ?? '',
      rating: normalized['rating'] == null
          ? null
          : (normalized['rating'] is int
              ? normalized['rating'] as int
              : int.tryParse(normalized['rating']?.toString() ?? '')),
      createdAt: DateTime.tryParse(normalized['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Comment toEntity() {
    return Comment(
      id: id,
      userId: userId,
      userName: userName,
      productId: productId,
      productName: productName,
      content: content,
      rating: rating,
      createdAt: createdAt,
    );
  }
}


