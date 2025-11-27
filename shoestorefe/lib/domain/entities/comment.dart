class Comment {
  final int id;
  final int userId;
  final String userName;
  final int productId;
  final String productName;
  final String content;
  final int? rating;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.productId,
    required this.productName,
    required this.content,
    this.rating,
    required this.createdAt,
  });
}


