import 'package:flutter/material.dart';
import '../../../domain/usecases/chat/send_message_usecase.dart';

class ChatProvider extends ChangeNotifier {
  final SendMessageUseCase sendMessageUseCase;

  ChatProvider({required this.sendMessageUseCase});

  final List<Map<String, String>> _messages = [];
  List<Map<String, String>> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    // Thêm câu hỏi của user vào danh sách
    _messages.add({
      "role": "user",
      "text": userMessage,
    });

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Gửi message đến API chatbot
      final chatMessage = await sendMessageUseCase.call(userMessage);

      // Thêm câu trả lời của chatbot vào danh sách
      _messages.add({
        "role": "bot",
        "text": chatMessage.response,
      });
    } catch (e) {
      _error = "Lỗi: ${e.toString()}";
      _messages.add({
        "role": "bot",
        "text": "Xin lỗi, tôi không thể trả lời lúc này. Vui lòng thử lại.",
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void init() {
    if (_messages.isEmpty) {
      _messages.add({
        "role": "bot",
        "text": "Chào bạn tôi là Trợ lý ảo Hello, tôi sẽ giúp bạn giải đáp mọi thắc mắc về cửa hàng."
      });
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    _error = null;
    init(); // Re-add welcome message after clear
    notifyListeners();
  }
}
