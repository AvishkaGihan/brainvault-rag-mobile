import '../domain/entities/chat_message.dart';

sealed class ChatStreamEvent {
  const ChatStreamEvent();
}

final class ChatStreamDelta extends ChatStreamEvent {
  final String text;

  const ChatStreamDelta({required this.text});
}

final class ChatStreamDone extends ChatStreamEvent {
  final String answer;
  final List<ChatSource> sources;
  final double confidence;

  const ChatStreamDone({
    required this.answer,
    required this.sources,
    required this.confidence,
  });
}

final class ChatStreamError extends ChatStreamEvent {
  final String code;
  final String message;

  const ChatStreamError({required this.code, required this.message});
}
