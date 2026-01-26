import 'package:brainvault/core/error/failures.dart';
import 'package:brainvault/features/documents/domain/entities/document.dart';
import 'package:brainvault/features/documents/domain/entities/document_status.dart';
import 'package:brainvault/features/documents/domain/repositories/document_repository.dart';
import 'package:brainvault/features/documents/domain/usecases/upload_pdf_document.dart';
import 'package:brainvault/features/documents/presentation/providers/upload_provider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDocumentRepository implements DocumentRepository {
  @override
  Future<Document> uploadDocument(
    PlatformFile file, {
    CancelToken? cancelToken,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PlatformFile> pickAndValidateFile() {
    throw UnimplementedError();
  }

  @override
  Future<Document> uploadTextDocument({
    required String title,
    required String content,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Document>> getDocuments() {
    throw UnimplementedError();
  }

  @override
  Future<DocumentStatusInfo> getDocumentStatus(String documentId) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDocument(String documentId) {
    throw UnimplementedError();
  }

  @override
  Future<void> cancelDocumentProcessing(String documentId) {
    throw UnimplementedError();
  }
}

class FakeUploadPdfDocument extends UploadPdfDocument {
  FakeUploadPdfDocument() : super(_FakeDocumentRepository());

  CancelToken? lastToken;

  @override
  Future<Document> call(PlatformFile file, {CancelToken? cancelToken}) async {
    lastToken = cancelToken;
    if (cancelToken != null) {
      await cancelToken.whenCancel;
      throw const UploadCancelledFailure();
    }

    throw const UploadCancelledFailure();
  }
}

void main() {
  test('should cancel upload and clear state', () async {
    final fakeUseCase = FakeUploadPdfDocument();
    final container = ProviderContainer(
      overrides: [
        uploadPdfDocumentUseCaseProvider.overrideWithValue(fakeUseCase),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(uploadPdfProvider.notifier);
    final file = PlatformFile(
      name: 'test.pdf',
      size: 1024,
      path: '/tmp/test.pdf',
    );

    final uploadFuture = notifier.upload(file);
    notifier.cancelUpload();

    await uploadFuture;

    final state = container.read(uploadPdfProvider);
    expect(state.hasValue, true);
    expect(state.value, isNull);
    expect(fakeUseCase.lastToken?.isCancelled, true);
  });
}
