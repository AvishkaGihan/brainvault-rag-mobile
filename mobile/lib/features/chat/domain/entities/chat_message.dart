import 'package:flutter/foundation.dart';

enum ChatMessageRole { user, assistant }

@immutable
class ChatSource {
  final String label;

  const ChatSource({required this.label});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatSource &&
          runtimeType == other.runtimeType &&
          label == other.label;

  @override
  int get hashCode => label.hashCode;
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
