import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brainvault/core/cache/document_cache.dart';
import 'package:brainvault/features/documents/data/models/document_model.dart';
import 'package:brainvault/features/documents/domain/entities/document.dart';

void main() {
  late DocumentCache cache;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cache = DocumentCache();
  });

  test('writes and reads documents from cache', () async {
    final documents = [
      DocumentModel(
        id: 'doc-1',
        title: 'Cached Doc',
        fileName: 'cached.pdf',
        fileSize: 1234,
        status: DocumentStatus.ready,
        createdAt: DateTime(2026, 1, 15),
      ),
    ];

    await cache.write(documents);

    final cached = await cache.read();

    expect(cached, isNotNull);
    expect(cached, documents);
  });

  test('clears cached documents', () async {
    final documents = [
      DocumentModel(
        id: 'doc-2',
        title: 'Temp Doc',
        fileName: 'temp.pdf',
        fileSize: 4567,
        status: DocumentStatus.processing,
        createdAt: DateTime(2026, 1, 16),
      ),
    ];

    await cache.write(documents);
    await cache.clear();

    final cached = await cache.read();

    expect(cached, isNull);
  });

  test('returns null on malformed JSON in cache', () async {
    SharedPreferences.setMockInitialValues({
      'cached_documents': 'invalid-json-{][}'
    });
    cache = DocumentCache();

    final result = await cache.read();

    expect(result, isNull);
  });

  test('returns null on invalid data type in cache', () async {
    SharedPreferences.setMockInitialValues({
      'cached_documents': '"not-a-list"'  // String instead of list
    });
    cache = DocumentCache();

    final result = await cache.read();

    expect(result, isNull);
  });

  test('handles empty list serialization', () async {
    final documents = <DocumentModel>[];

    await cache.write(documents);
    final cached = await cache.read();

    expect(cached, isNotNull);
    expect(cached, isEmpty);
  });
}
