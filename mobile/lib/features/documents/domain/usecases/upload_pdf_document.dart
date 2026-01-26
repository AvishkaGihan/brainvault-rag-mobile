import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../entities/document.dart';
import '../repositories/document_repository.dart';

/// Use case for uploading a PDF document
class UploadPdfDocument {
  final DocumentRepository _repository;

  const UploadPdfDocument(this._repository);

  Future<Document> call(PlatformFile file, {CancelToken? cancelToken}) async {
    return await _repository.uploadDocument(file, cancelToken: cancelToken);
  }
}
