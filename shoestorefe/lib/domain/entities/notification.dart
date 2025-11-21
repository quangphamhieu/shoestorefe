class Notification {
  final int id;
  final String? code;
  final String title;
  final String message;
  final String? type;
  final DateTime createdAt;

  Notification({
    required this.id,
    this.code,
    required this.title,
    required this.message,
    this.type,
    required this.createdAt,
  });
}
