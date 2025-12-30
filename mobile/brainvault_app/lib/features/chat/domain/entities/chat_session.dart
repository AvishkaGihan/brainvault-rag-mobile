import 'package:flutter/foundation.dart';

/// Represents a persistent chat session associated with a document.
///
/// Mirrors the backend `ChatSession` entity structure defined in `chat.types.ts`.
@immutable
class ChatSession {
  /// Unique identifier for the session.
  final String id;

  /// ID of the document context for this chat.
  final String documentId;

  /// Total number of messages in the thread (denormalized count).
  final int messageCount;

  /// Timestamp of creation.
  final DateTime createdAt;

  /// Timestamp of last update.
  final DateTime updatedAt;

  const ChatSession({
    required this.id,
    required this.documentId,
    required this.messageCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [ChatSession] instance from a JSON map.
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts the [ChatSession] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'messageCount': messageCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [ChatSession] but with the given fields replaced with the new values.
  ChatSession copyWith({
    String? id,
    String? documentId,
    int? messageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      messageCount: messageCount ?? this.messageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatSession &&
        other.id == id &&
        other.documentId == documentId &&
        other.messageCount == messageCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        documentId.hashCode ^
        messageCount.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'ChatSession(id: $id, doc: $documentId, msgs: $messageCount)';
  }
}
