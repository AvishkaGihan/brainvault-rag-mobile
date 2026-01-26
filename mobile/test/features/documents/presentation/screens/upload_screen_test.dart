import 'package:brainvault/features/documents/domain/entities/document_status.dart';
import 'package:brainvault/features/documents/domain/entities/document.dart';
import 'package:brainvault/features/documents/domain/repositories/document_repository.dart';
import 'package:brainvault/features/documents/domain/usecases/cancel_document_processing.dart';
import 'package:brainvault/features/documents/presentation/providers/upload_provider.dart';
import 'package:brainvault/features/documents/presentation/screens/upload_screen.dart';
import 'package:brainvault/features/documents/presentation/widgets/processing_status_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDocumentRepository implements DocumentRepository {
  @override
  Future<PlatformFile> pickAndValidateFile() {
    throw UnimplementedError();
  }

  @override
  Future<Document> uploadDocument(
    PlatformFile file, {
    CancelToken? cancelToken,
  }) {
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

class FakeCancelDocumentProcessing extends CancelDocumentProcessing {
  FakeCancelDocumentProcessing() : super(_FakeDocumentRepository());

  String? calledWith;

  @override
  Future<void> call(String documentId) async {
    calledWith = documentId;
  }
}

class FakeFileSelectionNotifier extends FileSelectionNotifier {
  FakeFileSelectionNotifier(this.file);

  final PlatformFile file;

  @override
  Future<PlatformFile?> build() async => file;
}

class FakeDocumentStatusNotifier extends DocumentStatusNotifier {
  FakeDocumentStatusNotifier(this.initialStatus);

  final DocumentStatusInfo initialStatus;
  bool stopCalled = false;

  @override
  Future<DocumentStatusInfo?> build() async {
    state = AsyncData(initialStatus);
    return initialStatus;
  }

  @override
  void stopPolling() {
    stopCalled = true;
    super.stopPolling();
  }
}

void main() {
  testWidgets('should cancel processing and stop polling', (tester) async {
    final file = PlatformFile(
      name: 'test.pdf',
      size: 1024,
      path: '/tmp/test.pdf',
    );

    final status = DocumentStatusInfo(
      documentId: 'doc-123',
      status: DocumentStatus.processing,
      updatedAt: DateTime.now(),
    );

    final fakeCancelUseCase = FakeCancelDocumentProcessing();
    final fakeStatusNotifier = FakeDocumentStatusNotifier(status);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fileSelectionProvider.overrideWith(
            () => FakeFileSelectionNotifier(file),
          ),
          documentStatusProvider.overrideWith(() => fakeStatusNotifier),
          cancelDocumentProcessingUseCaseProvider.overrideWithValue(
            fakeCancelUseCase,
          ),
        ],
        child: const MaterialApp(home: UploadScreen()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    final cancelButton = find.descendant(
      of: find.byType(ProcessingStatusCard),
      matching: find.text('Cancel'),
    );

    expect(cancelButton, findsOneWidget);

    await tester.tap(cancelButton);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Cancel upload'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(fakeCancelUseCase.calledWith, 'doc-123');
    expect(fakeStatusNotifier.stopCalled, true);
  });
}
