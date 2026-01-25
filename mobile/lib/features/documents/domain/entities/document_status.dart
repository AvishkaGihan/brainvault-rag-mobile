import 'document.dart';

/// Document status information for polling updates
class DocumentStatusInfo {
  final String documentId;
  final DocumentStatus status;
  final DateTime updatedAt;
  final String? errorMessage;
  final int? progress;
  final String? processingStage;

  const DocumentStatusInfo({
    required this.documentId,
    required this.status,
    required this.updatedAt,
    this.errorMessage,
    this.progress,
    this.processingStage,
  });

  DocumentStatusInfo copyWith({
    String? documentId,
    DocumentStatus? status,
    DateTime? updatedAt,
    String? errorMessage,
    int? progress,
    String? processingStage,
  }) {
    return DocumentStatusInfo(
      documentId: documentId ?? this.documentId,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
      processingStage: processingStage ?? this.processingStage,
    );
  }
}
