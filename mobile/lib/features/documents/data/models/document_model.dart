import 'package:file_picker/file_picker.dart';

import '../../domain/entities/document.dart';

/// Data model for Document entity
/// Handles serialization and conversion from PlatformFile
class DocumentModel extends Document {
  const DocumentModel({
    required super.id,
    required super.title,
    required super.fileName,
    required super.fileSize,
    required super.status,
    required super.createdAt,
    super.updatedAt,
    super.errorMessage,
  });

  /// Create DocumentModel from PlatformFile
  factory DocumentModel.fromPlatformFile(PlatformFile file) {
    final now = DateTime.now();
    return DocumentModel(
      id: now.millisecondsSinceEpoch.toString(), // Temporary ID
      title: file.name.replaceAll('.pdf', ''),
      fileName: file.name,
      fileSize: file.size,
      status: DocumentStatus.pending,
      createdAt: now,
    );
  }

  /// Create DocumentModel from JSON (server response)
  /// TODO: Implement in Story 3.3 when backend API is ready
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      fileName: json['fileName'] as String,
      fileSize: json['fileSize'] as int,
      status: _statusFromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  /// Convert DocumentModel to JSON
  /// TODO: Used for API requests in Story 3.3
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fileName': fileName,
      'fileSize': fileSize,
      'status': _statusToString(status),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  /// Helper: Convert status enum to string
  static String _statusToString(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return 'pending';
      case DocumentStatus.uploading:
        return 'uploading';
      case DocumentStatus.uploaded:
        return 'uploaded';
      case DocumentStatus.processing:
        return 'processing';
      case DocumentStatus.ready:
        return 'ready';
      case DocumentStatus.failed:
        return 'failed';
    }
  }

  /// Helper: Convert string to status enum
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
