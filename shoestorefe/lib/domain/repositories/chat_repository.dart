import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<ChatMessage> sendMessage(String message);
  Future<List<ChatMessage>> getHistory();
}
