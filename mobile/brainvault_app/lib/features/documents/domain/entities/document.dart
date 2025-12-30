import 'package:flutter/foundation.dart';

/// Represents the processing status of a document.
enum DocumentStatus {
  uploading,
  processing,
  ready,
  error;

  /// Parses a string value to a [DocumentStatus].
  static DocumentStatus fromString(String value) {
    return DocumentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DocumentStatus.error,
    );
  }

  /// Converts the enum to its string representation.
  String toJson() => name;
}

/// Represents a user-uploaded PDF document and its processing state.
///
/// Mirrors the backend `Document` entity structure defined in `document.types.ts`.
@immutable
class Document {
  /// Unique identifier for the document.
  final String id;

  /// ID of the user who owns this document.
  final String userId;

  /// Current processing status of the document.
  final DocumentStatus status;

  /// The display name of the file.
  final String name;

  /// The storage path or unique reference in the storage system.
  final String storagePath;

  /// File size in bytes.
  final int fileSize;

  /// MIME type of the file (e.g., 'application/pdf').
  final String mimeType;

  /// Number of pages in the PDF (available after processing).
  final int? pageCount;

  /// Pinecone namespace where vectors for this document are stored.
  final String? vectorNamespace;

  /// Number of vector chunks generated from this document.
  final int? chunkCount;

  /// Current progress of processing (normalized to 0.0 - 1.0).
  /// Backend sends 0-100, mobile stores as 0.0-1.0 for LinearProgressIndicator.
  final double processingProgress;

  /// Human-readable description of the current processing stage.
  final String? processingStage;

  /// Error message if status is 'error'.
  final String? errorMessage;

  /// Timestamp of creation.
  final DateTime createdAt;

  /// Timestamp of last update.
  final DateTime updatedAt;

  const Document({
    required this.id,
    required this.userId,
    required this.status,
    required this.name,
    required this.storagePath,
    required this.fileSize,
    required this.mimeType,
    this.pageCount,
    this.vectorNamespace,
    this.chunkCount,
    required this.processingProgress,
    this.processingStage,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [Document] instance from a JSON map.
  factory Document.fromJson(Map<String, dynamic> json) {
    // Backend sends progress as 0-100 integer, we convert to 0.0-1.0 double
    final rawProgress = (json['processingProgress'] as num?)?.toDouble() ?? 0.0;
    final normalizedProgress = (rawProgress / 100.0).clamp(0.0, 1.0);

    return Document(
      id: json['id'] as String,
      userId: json['userId'] as String,
      status: DocumentStatus.fromString(json['status'] as String),
      name: json['name'] as String,
      storagePath: json['storagePath'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      mimeType: json['mimeType'] as String? ?? 'application/pdf',
      pageCount: (json['pageCount'] as num?)?.toInt(),
      vectorNamespace: json['vectorNamespace'] as String?,
      chunkCount: (json['chunkCount'] as num?)?.toInt(),
      processingProgress: normalizedProgress,
      processingStage: json['processingStage'] as String?,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts the [Document] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'status': status.toJson(),
      'name': name,
      'storagePath': storagePath,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'pageCount': pageCount,
      'vectorNamespace': vectorNamespace,
      'chunkCount': chunkCount,
      // Convert 0.0-1.0 back to 0-100 for backend consistency
      'processingProgress': (processingProgress * 100).toInt(),
      'processingStage': processingStage,
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [Document] but with the given fields replaced with the new values.
  Document copyWith({
    String? id,
    String? userId,
    DocumentStatus? status,
    String? name,
    String? storagePath,
    int? fileSize,
    String? mimeType,
    int? pageCount,
    String? vectorNamespace,
    int? chunkCount,
    double? processingProgress,
    String? processingStage,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      name: name ?? this.name,
      storagePath: storagePath ?? this.storagePath,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      pageCount: pageCount ?? this.pageCount,
      vectorNamespace: vectorNamespace ?? this.vectorNamespace,
      chunkCount: chunkCount ?? this.chunkCount,
      processingProgress: processingProgress ?? this.processingProgress,
      processingStage: processingStage ?? this.processingStage,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Document &&
        other.id == id &&
        other.userId == userId &&
        other.status == status &&
        other.name == name &&
        other.storagePath == storagePath &&
        other.fileSize == fileSize &&
        other.mimeType == mimeType &&
        other.pageCount == pageCount &&
        other.vectorNamespace == vectorNamespace &&
        other.chunkCount == chunkCount &&
        other.processingProgress == processingProgress &&
        other.processingStage == processingStage &&
        other.errorMessage == errorMessage &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        status.hashCode ^
        name.hashCode ^
        storagePath.hashCode ^
        fileSize.hashCode ^
        mimeType.hashCode ^
        pageCount.hashCode ^
        vectorNamespace.hashCode ^
        chunkCount.hashCode ^
        processingProgress.hashCode ^
        processingStage.hashCode ^
        errorMessage.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Document(id: $id, name: $name, status: ${status.name}, progress: ${(processingProgress * 100).toInt()}%)';
  }
}
