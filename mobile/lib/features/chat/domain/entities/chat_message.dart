import 'package:flutter/foundation.dart';

enum ChatMessageRole { user, assistant }

@immutable
class ChatSource {
  final int pageNumber;
  final String? snippet;

  const ChatSource({required this.pageNumber, this.snippet});

  String get label => 'Source: Page $pageNumber';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatSource &&
          runtimeType == other.runtimeType &&
          pageNumber == other.pageNumber &&
          snippet == other.snippet;

  @override
  int get hashCode => pageNumber.hashCode ^ snippet.hashCode;
}

/// Represents a single message in a chat conversation
@immutable
class ChatMessage {
  final String text;
  final DateTime? createdAt;
  final ChatMessageRole role;
  final List<ChatSource> sources;

  const ChatMessage({
    required this.text,
    this.createdAt,
    this.role = ChatMessageRole.user,
    this.sources = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          createdAt == other.createdAt &&
          role == other.role &&
          listEquals(sources, other.sources);

  @override
  int get hashCode =>
      text.hashCode ^ createdAt.hashCode ^ role.hashCode ^ sources.hashCode;
}
