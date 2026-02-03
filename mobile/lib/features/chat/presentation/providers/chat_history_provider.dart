import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chat_api.dart';
import '../../data/repositories/chat_history_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_history_repository.dart';

final chatHistoryRepositoryProvider = Provider<ChatHistoryRepository>((ref) {
  final chatApi = ref.watch(chatApiProvider);
  return ChatHistoryRepositoryImpl(chatApi: chatApi);
});

class ChatHistoryDocumentIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) {
    state = value;
  }
}

final chatHistoryDocumentIdProvider =
    NotifierProvider<ChatHistoryDocumentIdNotifier, String?>(
      () => ChatHistoryDocumentIdNotifier(),
    );

class ChatHistoryNotifier extends AsyncNotifier<List<ChatMessage>> {
  @override
  Future<List<ChatMessage>> build() async {
    final documentId = ref.watch(chatHistoryDocumentIdProvider);
    if (documentId == null || documentId.trim().isEmpty) {
      return [];
    }
    final repository = ref.read(chatHistoryRepositoryProvider);
    return repository.fetchChatHistory(documentId);
  }

  Future<void> refresh() async {
    final documentId = ref.read(chatHistoryDocumentIdProvider);
    if (documentId == null || documentId.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    final repository = ref.read(chatHistoryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repository.fetchChatHistory(documentId),
    );
  }
}

final chatHistoryProvider =
    AsyncNotifierProvider.autoDispose<ChatHistoryNotifier, List<ChatMessage>>(
      () => ChatHistoryNotifier(),
    );
