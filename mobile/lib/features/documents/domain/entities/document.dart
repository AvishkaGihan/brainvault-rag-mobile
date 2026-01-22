/// Document entity representing a user's uploaded document
class Document {
  final String id;
  final String title;
  final String fileName;
  final int fileSize; // in bytes
  final DocumentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? errorMessage;

  const Document({
    required this.id,
    required this.title,
    required this.fileName,
    required this.fileSize,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.errorMessage,
  });

  /// Copy with method for immutable updates
  Document copyWith({
    String? id,
    String? title,
    String? fileName,
    int? fileSize,
    DocumentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? errorMessage,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Document &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          fileName == other.fileName &&
          fileSize == other.fileSize &&
          status == other.status &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      fileName.hashCode ^
      fileSize.hashCode ^
      status.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      errorMessage.hashCode;

  @override
  String toString() {
    return 'Document(id: $id, title: $title, fileName: $fileName, fileSize: $fileSize, status: $status, createdAt: $createdAt)';
  }
}

/// Document processing status
enum DocumentStatus {
  /// File selected but not yet uploaded
  pending,

  /// File is being uploaded to server
  uploading,

  /// Upload complete, awaiting processing
  uploaded,

  /// Document is being processed (text extraction, chunking, embedding)
  processing,

  /// Document processing complete and ready for chat
  ready,

  /// Processing failed
  failed,
}
