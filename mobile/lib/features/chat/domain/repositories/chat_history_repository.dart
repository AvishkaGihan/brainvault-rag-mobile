import '../entities/chat_message.dart';

abstract class ChatHistoryRepository {
  Future<List<ChatMessage>> fetchChatHistory(
    String documentId, {
    int limit = 100,
  });

  Future<List<ChatMessage>> fetchOlderChatHistory(
    String documentId,
    DateTime before, {
    int limit = 100,
  });
}
