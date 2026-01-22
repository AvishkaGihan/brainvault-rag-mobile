import 'package:brainvault/core/error/failures.dart';
import 'package:brainvault/features/documents/data/datasources/document_remote_datasource.dart';
import 'package:brainvault/features/documents/data/repositories/document_repository_impl.dart';
import 'package:brainvault/features/documents/domain/usecases/upload_document.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mock for DocumentRemoteDataSource
class MockDocumentRemoteDataSource extends Mock
    implements DocumentRemoteDataSource {}

void main() {
  late UploadDocument useCase;
  late DocumentRepositoryImpl mockRepository;
  late MockDocumentRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDocumentRemoteDataSource();
    mockRepository = DocumentRepositoryImpl(mockDataSource);
    useCase = UploadDocument(mockRepository);
  });

  group('UploadDocument', () {
    test('should return file when valid PDF file is selected', () async {
      // Arrange
      final mockFile = PlatformFile(
        name: 'test.pdf',
        size: 2 * 1024 * 1024, // 2MB
        path: '/path/to/test.pdf',
      );

      when(() => mockDataSource.pickFile()).thenAnswer((_) async => mockFile);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(mockFile));
      expect(result.name, 'test.pdf');
      expect(result.size, 2 * 1024 * 1024);
      verify(() => mockDataSource.pickFile()).called(1);
    });

    test('should throw FileTooLargeFailure when file exceeds 5MB', () async {
      // Arrange
      final mockFile = PlatformFile(
        name: 'large.pdf',
        size: 6 * 1024 * 1024, // 6MB - exceeds limit
        path: '/path/to/large.pdf',
      );

      when(() => mockDataSource.pickFile()).thenAnswer((_) async => mockFile);

      // Act & Assert
      expect(() => useCase(), throwsA(isA<FileTooLargeFailure>()));
    });

    test('should throw InvalidFileTypeFailure when file is not PDF', () async {
      // Arrange
      final mockFile = PlatformFile(
        name: 'document.docx',
        size: 2 * 1024 * 1024, // 2MB
        path: '/path/to/document.docx',
      );

      when(() => mockDataSource.pickFile()).thenAnswer((_) async => mockFile);

      // Act & Assert
      expect(() => useCase(), throwsA(isA<InvalidFileTypeFailure>()));
    });

    test('should throw FilePickerCancelledFailure when user cancels', () async {
      // Arrange
      when(() => mockDataSource.pickFile()).thenAnswer((_) async => null);

      // Act & Assert
      expect(() => useCase(), throwsA(isA<FilePickerCancelledFailure>()));
    });

    test('should accept file at exactly 5MB boundary', () async {
      // Arrange
      final mockFile = PlatformFile(
        name: 'boundary.pdf',
        size: 5 * 1024 * 1024, // Exactly 5MB
        path: '/path/to/boundary.pdf',
      );

      when(() => mockDataSource.pickFile()).thenAnswer((_) async => mockFile);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(mockFile));
      expect(result.size, 5 * 1024 * 1024);
    });
  });
}
