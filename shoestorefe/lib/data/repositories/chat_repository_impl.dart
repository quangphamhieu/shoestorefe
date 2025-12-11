import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;
  ChatRepositoryImpl(this.remote);

  @override
  Future<ChatMessage> sendMessage(String message) async {
    return await remote.sendMessage(message);
  }

  @override
  Future<List<ChatMessage>> getHistory() async {
    return await remote.getHistory();
  }
}
