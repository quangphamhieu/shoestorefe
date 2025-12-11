class ChatMessage {
  final int? id;
  final String message;
  final String response;
  final DateTime? createdAt;

  ChatMessage({
    this.id,
    required this.message,
    required this.response,
    this.createdAt,
  });
}
