import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/network/dio_client.dart';
import '../models/document_status_model.dart';

/// Remote data source for document operations
/// Handles file picking and server communication
class DocumentRemoteDataSource {
  final DioClient _dioClient;

  DocumentRemoteDataSource({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Pick a PDF file from device storage
  /// Returns null if user cancels
  /// Throws PlatformException on permission errors
  Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null) {
      return null; // User cancelled
    }

    return result.files.single;
  }

  /// Upload document to server
  /// AC: Multipart form-data upload
  Future<Map<String, dynamic>> uploadToServer(
    PlatformFile file, {
    CancelToken? cancelToken,
  }) async {
    if (file.bytes == null && file.path == null) {
      throw Exception('File data not available for upload');
    }

    final multipartFile = file.bytes != null
        ? MultipartFile.fromBytes(file.bytes!, filename: file.name)
        : await MultipartFile.fromFile(file.path!, filename: file.name);

    final formData = FormData.fromMap({'file': multipartFile});

    final response = await _dioClient.post<Map<String, dynamic>>(
      '/v1/documents/upload',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      cancelToken: cancelToken,
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception('Document upload failed');
    }

    return body['data'] as Map<String, dynamic>;
  }

  /// Upload text document to server
  Future<Map<String, dynamic>> uploadTextDocument({
    required String title,
    required String content,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      '/v1/documents/text',
      data: {'title': title, 'content': content},
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception('Text document upload failed');
    }

    return body['data'] as Map<String, dynamic>;
  }

  /// Fetch document processing status from server
  Future<DocumentStatusModel> fetchDocumentStatus(String documentId) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/v1/documents/$documentId/status',
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception('Invalid document status response');
    }

    final data = body['data'] as Map<String, dynamic>;
    return DocumentStatusModel.fromJson(data);
  }

  /// Cancel document processing on server
  Future<void> cancelDocumentProcessing(String documentId) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      '/v1/documents/$documentId/cancel',
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception('Document cancellation failed');
    }
  }

  /// Fetch documents from server
  /// TODO: Implement in Story 4.1 - Implement Document List Screen
  Future<List<Map<String, dynamic>>> fetchDocuments() async {
    throw UnimplementedError('Fetch will be implemented in Story 4.1');
  }

  /// Delete document from server
  /// TODO: Implement in Story 4.5 - Implement Document Deletion
  Future<void> deleteFromServer(String documentId) async {
    throw UnimplementedError('Delete will be implemented in Story 4.5');
  }
}
