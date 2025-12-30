import 'package:flutter/foundation.dart';
import 'citation.dart';

/// The role of the message sender.
enum MessageRole {
  user,
  assistant;

  /// Parses a string value to a [MessageRole].
  static MessageRole fromString(String value) {
    return MessageRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageRole.user,
    );
  }

  /// Converts the enum to its string representation.
  String toJson() => name;
}

/// Represents a single message in a chat conversation.
///
/// Mirrors the backend `Message` entity structure defined in `chat.types.ts`.
@immutable
class Message {
  /// Unique identifier for the message.
  final String id;

  /// ID of the chat session this message belongs to.
  final String chatId;

  /// The role of the message sender.
  final MessageRole role;

  /// The text content of the message.
  final String content;

  /// Source citations supporting the assistant's response.
  /// Empty for user messages or if no sources were found.
  final List<Citation> citations;

  /// Timestamp of creation.
  final DateTime createdAt;

  /// Indicates if this message represents an error state.
  final bool isError;

  /// Human-readable error message if isError is true.
  final String? errorMessage;

  const Message({
    required this.id,
    required this.chatId,
    required this.role,
    required this.content,
    this.citations = const [],
    required this.createdAt,
    this.isError = false,
    this.errorMessage,
  });

  /// Creates a [Message] instance from a JSON map.
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      role: MessageRole.fromString(json['role'] as String),
      content: json['content'] as String,
      citations:
          (json['citations'] as List<dynamic>?)
              ?.map((e) => Citation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      isError: json['isError'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  /// Converts the [Message] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'role': role.toJson(),
      'content': content,
      'citations': citations.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isError': isError,
      'errorMessage': errorMessage,
    };
  }

  /// Creates a copy of this [Message] but with the given fields replaced with the new values.
  Message copyWith({
    String? id,
    String? chatId,
    MessageRole? role,
    String? content,
    List<Citation>? citations,
    DateTime? createdAt,
    bool? isError,
    String? errorMessage,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      role: role ?? this.role,
      content: content ?? this.content,
      citations: citations ?? this.citations,
      createdAt: createdAt ?? this.createdAt,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message &&
        other.id == id &&
        other.chatId == chatId &&
        other.role == role &&
        other.content == content &&
        listEquals(other.citations, citations) &&
        other.createdAt == createdAt &&
        other.isError == isError &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        chatId.hashCode ^
        role.hashCode ^
        content.hashCode ^
        citations.hashCode ^
        createdAt.hashCode ^
        isError.hashCode ^
        errorMessage.hashCode;
  }

  @override
  String toString() {
    return 'Message(id: $id, role: ${role.name}, content: ${content.length > 20 ? "${content.substring(0, 20)}..." : content}, citations: ${citations.length})';
  }
}
