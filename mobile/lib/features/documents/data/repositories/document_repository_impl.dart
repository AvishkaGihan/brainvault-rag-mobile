import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/document_status.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_datasource.dart';
import '../models/document_model.dart';

/// Implementation of DocumentRepository
/// Handles file picking, validation, and server communication
class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource _remoteDataSource;

  const DocumentRepositoryImpl(this._remoteDataSource);

  /// Maximum file size in bytes (5MB)
  static const int maxFileSize = 5 * 1024 * 1024;

  @override
  Future<PlatformFile> pickAndValidateFile() async {
    try {
      // Pick file using data source
      final file = await _remoteDataSource.pickFile();

      // Handle user cancellation
      if (file == null) {
        throw const FilePickerCancelledFailure();
      }

      // Validate file type
      if (file.extension?.toLowerCase() != 'pdf') {
        throw const InvalidFileTypeFailure();
      }

      // Validate file size
      if (file.size > maxFileSize) {
        throw const FileTooLargeFailure();
      }

      return file;
    } on DocumentFailure {
      rethrow; // Re-throw domain failures as-is
    } catch (e) {
      // Wrap unexpected errors in UnknownFailure
      throw UnknownFailure('Failed to pick file: ${e.toString()}');
    }
  }

  @override
  Future<Document> uploadDocument(
    PlatformFile file, {
    CancelToken? cancelToken,
  }) async {
    try {
      final data = await _remoteDataSource.uploadToServer(
        file,
        cancelToken: cancelToken,
      );
      final documentJson = {
        'id': data['documentId'] ?? data['id'],
        'title': data['title'] ?? file.name.replaceAll('.pdf', ''),
        'fileName': file.name,
        'fileSize': file.size,
        'status': data['status'],
        'createdAt': data['createdAt'],
        'updatedAt': data['createdAt'],
      };

      return DocumentModel.fromJson(documentJson);
    } on DioException catch (e) {
      throw _mapUploadError(e);
    } catch (e) {
      throw UnknownFailure('Failed to upload document: ${e.toString()}');
    }
  }

  @override
  Future<Document> uploadTextDocument({
    required String title,
    required String content,
  }) async {
    try {
      // Validate title
      if (title.trim().isEmpty) {
        throw const TitleRequiredFailure();
      }

      if (title.length > 100) {
        throw const TitleTooLongFailure();
      }

      // Validate content
      if (content.trim().length < 10) {
        throw const TextTooShortFailure();
      }

      if (content.length > 50000) {
        throw const TextTooLongFailure();
      }

      // Call data source to upload
      final data = await _remoteDataSource.uploadTextDocument(
        title: title,
        content: content,
      );

      final documentJson = {
        'id': data['documentId'] ?? data['id'],
        'title': data['title'] ?? title,
        'fileName': '$title.txt',
        'fileSize': content.length,
        'status': data['status'],
        'createdAt': data['createdAt'],
        'updatedAt': data['createdAt'],
        'errorMessage': data['errorMessage'],
      };

      return DocumentModel.fromJson(documentJson);
    } on DocumentFailure {
      rethrow; // Re-throw domain failures as-is
    } on DioException catch (e) {
      throw _mapTextUploadError(e);
    } catch (e) {
      // Wrap unexpected errors in UnknownFailure
      throw UnknownFailure('Failed to upload text: ${e.toString()}');
    }
  }

  @override
  Future<List<Document>> getDocuments() async {
    // TODO: Implement in Story 4.1
    // Stub: return empty list
    return [];
  }

  @override
  Future<DocumentStatusInfo> getDocumentStatus(String documentId) async {
    try {
      final status = await _remoteDataSource.fetchDocumentStatus(documentId);
      return status;
    } on DocumentFailure {
      rethrow;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final error = responseData['error'];
        if (error is Map<String, dynamic>) {
          final code = error['code'] as String?;
          if (code == 'DOCUMENT_NOT_FOUND') {
            throw const DocumentNotFoundFailure();
          }
        }
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw const TimeoutFailure('Request timed out');
        case DioExceptionType.connectionError:
          throw const ConnectionFailure();
        default:
          throw const ServerFailure();
      }
    } catch (e) {
      throw UnknownFailure('Failed to fetch status: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelDocumentProcessing(String documentId) async {
    try {
      await _remoteDataSource.cancelDocumentProcessing(documentId);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final error = responseData['error'];
        if (error is Map<String, dynamic>) {
          final code = error['code'] as String?;
          if (code == 'DOCUMENT_NOT_FOUND') {
            throw const DocumentNotFoundFailure();
          }
          if (code == 'CANCEL_NOT_ALLOWED') {
            throw const CancelNotAllowedFailure();
          }
        }
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw const TimeoutFailure('Request timed out');
        case DioExceptionType.connectionError:
          throw const ConnectionFailure();
        default:
          throw const ServerFailure();
      }
    } catch (e) {
      throw UnknownFailure('Failed to cancel document: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    // TODO: Implement in Story 4.5
    // Stub: do nothing
    return;
  }

  Failure _mapUploadError(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final errorBody = responseData['error'];
      if (errorBody is Map<String, dynamic>) {
        final code = errorBody['code'] as String?;
        switch (code) {
          case 'FILE_TOO_LARGE':
            return const FileTooLargeFailure();
          case 'INVALID_FILE_TYPE':
            return const InvalidFileTypeFailure();
          case 'NO_FILE_PROVIDED':
          case 'INVALID_PDF_FILE':
            return const DocumentUploadFailure();
        }
      }
    }

    switch (error.type) {
      case DioExceptionType.cancel:
        return const UploadCancelledFailure();
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutFailure('Request timed out');
      case DioExceptionType.connectionError:
        return const ConnectionFailure();
      default:
        return const ServerFailure();
    }
  }

  Failure _mapTextUploadError(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final errorBody = responseData['error'];
      if (errorBody is Map<String, dynamic>) {
        final code = errorBody['code'] as String?;
        switch (code) {
          case 'INVALID_TITLE':
            return const TitleRequiredFailure();
          case 'TEXT_TOO_SHORT':
            return const TextTooShortFailure();
          case 'TEXT_TOO_LONG':
            return const TextTooLongFailure();
          case 'MISSING_FIELDS':
            return const TitleRequiredFailure();
        }
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutFailure('Request timed out');
      case DioExceptionType.connectionError:
        return const ConnectionFailure();
      default:
        return const ServerFailure();
    }
  }
}
