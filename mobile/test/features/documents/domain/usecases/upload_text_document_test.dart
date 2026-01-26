import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainvault/core/error/failures.dart';
import 'package:brainvault/features/documents/domain/entities/document.dart';
import 'package:brainvault/features/documents/domain/entities/document_status.dart';
import 'package:brainvault/features/documents/domain/repositories/document_repository.dart';
import 'package:brainvault/features/documents/domain/usecases/upload_text_document.dart';

/// Mock repository for testing
class MockDocumentRepository implements DocumentRepository {
  String? titleReceived;
  String? contentReceived;
  Document? documentToReturn;
  Object? exceptionToThrow;

  @override
  Future<Document> uploadTextDocument({
    required String title,
    required String content,
  }) async {
    titleReceived = title;
    contentReceived = content;

    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }

    return documentToReturn ??
        Document(
          id: 'test_123',
          title: title,
          fileName: '$title.txt',
          fileSize: content.length,
          status: DocumentStatus.processing,
          createdAt: DateTime.now(),
        );
  }

  @override
  Future<PlatformFile> pickAndValidateFile() async {
    throw UnimplementedError();
  }

  @override
  Future<Document> uploadDocument(PlatformFile file) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Document>> getDocuments() async {
    throw UnimplementedError();
  }

  @override
  Future<DocumentStatusInfo> getDocumentStatus(String documentId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    throw UnimplementedError();
  }
}

void main() {
  group('UploadTextDocument', () {
    late MockDocumentRepository mockRepository;
    late UploadTextDocument useCase;

    setUp(() {
      mockRepository = MockDocumentRepository();
      useCase = UploadTextDocument(mockRepository);
    });

    test('should upload text document with valid title and content', () async {
      // Arrange
      const title = 'Test Document';
      const content = 'This is valid content with more than 10 characters.';

      // Act
      final result = await useCase(title: title, content: content);

      // Assert
      expect(result, isA<Document>());
      expect(result.title, title);
      expect(result.fileName, '$title.txt');
      expect(result.status, DocumentStatus.processing);
      expect(mockRepository.titleReceived, title);
      expect(mockRepository.contentReceived, content);
    });

    test(
      'should pass through TitleRequiredFailure when title is empty',
      () async {
        // Arrange
        mockRepository.exceptionToThrow = const TitleRequiredFailure();

        // Act & Assert
        expect(
          () => useCase(title: '', content: 'Valid content here.'),
          throwsA(isA<TitleRequiredFailure>()),
        );
      },
    );

    test(
      'should pass through TitleTooLongFailure when title exceeds 100 chars',
      () async {
        // Arrange
        mockRepository.exceptionToThrow = const TitleTooLongFailure();
        final longTitle = 'a' * 101;

        // Act & Assert
        expect(
          () => useCase(title: longTitle, content: 'Valid content here.'),
          throwsA(isA<TitleTooLongFailure>()),
        );
      },
    );

    test(
      'should pass through TextTooShortFailure when content is less than 10 chars',
      () async {
        // Arrange
        mockRepository.exceptionToThrow = const TextTooShortFailure();

        // Act & Assert
        expect(
          () => useCase(title: 'Valid Title', content: 'Short'),
          throwsA(isA<TextTooShortFailure>()),
        );
      },
    );

    test(
      'should pass through TextTooLongFailure when content exceeds 50k chars',
      () async {
        // Arrange
        mockRepository.exceptionToThrow = const TextTooLongFailure();
        final longContent = 'a' * 50001;

        // Act & Assert
        expect(
          () => useCase(title: 'Valid Title', content: longContent),
          throwsA(isA<TextTooLongFailure>()),
        );
      },
    );

    test('should return document with correct metadata', () async {
      // Arrange
      const title = 'My Notes';
      const content = 'Content with at least 10 characters here.';
      final expectedDoc = Document(
        id: 'custom_id',
        title: title,
        fileName: '$title.txt',
        fileSize: content.length,
        status: DocumentStatus.processing,
        createdAt: DateTime(2026, 1, 22),
      );
      mockRepository.documentToReturn = expectedDoc;

      // Act
      final result = await useCase(title: title, content: content);

      // Assert
      expect(result.id, 'custom_id');
      expect(result.fileName, '$title.txt');
      expect(result.fileSize, content.length);
    });
  });
}
