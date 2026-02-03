import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_history_repository.dart';
import '../chat_api.dart';

class ChatHistoryRepositoryImpl implements ChatHistoryRepository {
  final ChatApi chatApi;

  ChatHistoryRepositoryImpl({required this.chatApi});

  @override
  Future<List<ChatMessage>> fetchChatHistory(
    String documentId, {
    int limit = 100,
  }) {
    return chatApi.fetchChatHistory(documentId: documentId, limit: limit);
  }

  @override
  Future<List<ChatMessage>> fetchOlderChatHistory(
    String documentId,
    DateTime before, {
    int limit = 100,
  }) {
    return chatApi.fetchOlderChatHistory(
      documentId: documentId,
      before: before,
      limit: limit,
    );
  }
}
