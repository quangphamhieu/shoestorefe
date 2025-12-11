import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  ChatMessageModel({
    int? id,
    required String message,
    required String response,
    DateTime? createdAt,
  }) : super(
    id: id,
    message: message,
    response: response,
    createdAt: createdAt,
  );

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int?,
      message: json['message'] as String,
      response: json['response'] as String,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'response': response,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
