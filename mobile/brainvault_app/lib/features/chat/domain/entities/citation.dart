import 'package:flutter/foundation.dart';

/// A reference to a specific part of a source document used to generate an answer.
///
/// Mirrors the backend `Citation` entity structure defined in `chat.types.ts`.
@immutable
class Citation {
  /// ID of the source document.
  final String documentId;

  /// Name of the document (for display).
  final String documentName;

  /// Page number where the information was found (1-based).
  final int pageNumber;

  /// The actual text snippet from the document chunk.
  /// Optional/Growth feature for showing exact context.
  final String? chunkText;

  /// Similarity score from the vector search (0.0 - 1.0).
  /// Higher is more relevant.
  final double? relevanceScore;

  const Citation({
    required this.documentId,
    required this.documentName,
    required this.pageNumber,
    this.chunkText,
    this.relevanceScore,
  });

  /// Creates a [Citation] instance from a JSON map.
  factory Citation.fromJson(Map<String, dynamic> json) {
    return Citation(
      documentId: json['documentId'] as String,
      documentName: json['documentName'] as String,
      pageNumber: (json['pageNumber'] as num).toInt(),
      chunkText: json['chunkText'] as String?,
      relevanceScore: (json['relevanceScore'] as num?)?.toDouble(),
    );
  }

  /// Converts the [Citation] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'documentName': documentName,
      'pageNumber': pageNumber,
      'chunkText': chunkText,
      'relevanceScore': relevanceScore,
    };
  }

  /// Creates a copy of this [Citation] but with the given fields replaced with the new values.
  Citation copyWith({
    String? documentId,
    String? documentName,
    int? pageNumber,
    String? chunkText,
    double? relevanceScore,
  }) {
    return Citation(
      documentId: documentId ?? this.documentId,
      documentName: documentName ?? this.documentName,
      pageNumber: pageNumber ?? this.pageNumber,
      chunkText: chunkText ?? this.chunkText,
      relevanceScore: relevanceScore ?? this.relevanceScore,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Citation &&
        other.documentId == documentId &&
        other.documentName == documentName &&
        other.pageNumber == pageNumber &&
        other.chunkText == chunkText &&
        other.relevanceScore == relevanceScore;
  }

  @override
  int get hashCode {
    return documentId.hashCode ^
        documentName.hashCode ^
        pageNumber.hashCode ^
        chunkText.hashCode ^
        relevanceScore.hashCode;
  }

  @override
  String toString() {
    return 'Citation(doc: $documentName, page: $pageNumber)';
  }
}
