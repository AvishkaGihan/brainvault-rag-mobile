import 'package:flutter/foundation.dart';

/// Represents a single message in a chat conversation
@immutable
class ChatMessage {
  final String text;
  final DateTime? createdAt;

  const ChatMessage({required this.text, this.createdAt});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          createdAt == other.createdAt;

  @override
  int get hashCode => text.hashCode ^ createdAt.hashCode;
}
