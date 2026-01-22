import 'package:file_picker/file_picker.dart';

import '../../../../core/error/failures.dart';
import '../repositories/document_repository.dart';

/// Use case for picking and validating a PDF file
/// Implements file selection with size and type validation
class UploadDocument {
  final DocumentRepository _repository;

  const UploadDocument(this._repository);

  /// Pick a PDF file and validate it
  /// Throws [FileTooLargeFailure] if file exceeds 5MB
  /// Throws [InvalidFileTypeFailure] if file is not a PDF
  /// Throws [FilePickerCancelledFailure] if user cancels
  Future<PlatformFile> call() async {
    return await _repository.pickAndValidateFile();
  }
}
