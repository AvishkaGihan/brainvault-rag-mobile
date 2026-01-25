import '../../domain/entities/document.dart';
import '../../domain/entities/document_status.dart';

/// Data model for document status responses
class DocumentStatusModel extends DocumentStatusInfo {
  const DocumentStatusModel({
    required super.documentId,
    required super.status,
    required super.updatedAt,
    super.errorMessage,
    super.progress,
    super.processingStage,
  });

  factory DocumentStatusModel.fromJson(Map<String, dynamic> json) {
    return DocumentStatusModel(
      documentId: (json['documentId'] ?? json['id']) as String,
      status: _statusFromString(json['status'] as String),
      // AC#2: Optional progress and processingStage fields from backend
      // These may be null if backend hasn't implemented progress tracking yet
      progress: json['progress'] != null ? json['progress'] as int : null,
      processingStage: json['processingStage'] != null
          ? json['processingStage'] as String
          : null,
      errorMessage: json['errorMessage'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static DocumentStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return DocumentStatus.pending;
      case 'uploading':
        return DocumentStatus.uploading;
      case 'uploaded':
        return DocumentStatus.uploaded;
      case 'processing':
        return DocumentStatus.processing;
      case 'ready':
        return DocumentStatus.ready;
      case 'error':
      case 'failed':
        return DocumentStatus.failed;
      default:
        return DocumentStatus.pending;
    }
  }
}
