import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  final ApiClient client;
  ChatRemoteDataSource(this.client);

  Future<ChatMessageModel> sendMessage(String message) async {
    final body = {'message': message};
    final response = await client.post(ApiEndpoint.chat, body);
    return ChatMessageModel.fromJson({
      'message': message,
      'response': response.data['response'] as String,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<ChatMessageModel>> getHistory() async {
    final response = await client.get('${ApiEndpoint.chat}/history');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
