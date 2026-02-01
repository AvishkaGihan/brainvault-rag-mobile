import 'dart:async';

import 'package:brainvault/features/documents/domain/entities/document.dart';
import 'package:brainvault/features/documents/presentation/providers/documents_provider.dart';
import 'package:brainvault/features/documents/presentation/providers/upload_provider.dart';
import 'package:brainvault/features/documents/presentation/screens/documents_screen.dart';
import 'package:brainvault/features/documents/presentation/widgets/document_card.dart';
import 'package:brainvault/features/documents/presentation/widgets/empty_documents.dart';
import 'package:brainvault/shared/widgets/skeleton_loader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class TestDocumentsNotifier extends DocumentsNotifier {
  final Future<List<Document>> Function() buildFn;

  TestDocumentsNotifier(this.buildFn);

  @override
  Future<List<Document>> build() => buildFn();
}

class FakeFileSelectionNotifier extends FileSelectionNotifier {
  @override
  Future<PlatformFile?> build() async => null;
}

class TestOfflineBannerNotifier extends DocumentsOfflineBannerNotifier {
  final bool initialValue;

  TestOfflineBannerNotifier(this.initialValue);

  @override
  bool build() => initialValue;
}

void main() {
  testWidgets('shows skeleton loader while loading', (tester) async {
    final completer = Completer<List<Document>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentsProvider.overrideWith(
            () => TestDocumentsNotifier(() => completer.future),
          ),
          fileSelectionProvider.overrideWith(() => FakeFileSelectionNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ListSkeletonLoader), findsOneWidget);
  });

  testWidgets('shows empty state when documents list is empty', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentsProvider.overrideWith(
            () => TestDocumentsNotifier(() async => []),
          ),
          fileSelectionProvider.overrideWith(() => FakeFileSelectionNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(EmptyDocuments), findsOneWidget);
  });

  testWidgets('renders document card when documents exist', (tester) async {
    final documents = [
      Document(
        id: 'doc-1',
        title: 'Quarterly Report',
        fileName: 'q1.pdf',
        fileSize: 24576,
        status: DocumentStatus.ready,
        createdAt: DateTime(2026, 1, 5),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentsProvider.overrideWith(
            () => TestDocumentsNotifier(() async => documents),
          ),
          fileSelectionProvider.overrideWith(() => FakeFileSelectionNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(DocumentCard), findsOneWidget);
    expect(find.text('Quarterly Report'), findsOneWidget);
  });

  testWidgets('cached documents render without skeleton loader', (
    tester,
  ) async {
    final documents = [
      Document(
        id: 'doc-2',
        title: 'Cached Doc',
        fileName: 'cached.pdf',
        fileSize: 1024,
        status: DocumentStatus.ready,
        createdAt: DateTime(2026, 1, 10),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentsProvider.overrideWith(
            () => TestDocumentsNotifier(() async => documents),
          ),
          fileSelectionProvider.overrideWith(() => FakeFileSelectionNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ListSkeletonLoader), findsNothing);
    expect(find.text('Cached Doc'), findsOneWidget);
  });

  testWidgets('shows offline banner when cached list is offline', (
    tester,
  ) async {
    final documents = [
      Document(
        id: 'doc-3',
        title: 'Offline Doc',
        fileName: 'offline.pdf',
        fileSize: 2048,
        status: DocumentStatus.ready,
        createdAt: DateTime(2026, 1, 12),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentsProvider.overrideWith(
            () => TestDocumentsNotifier(() async => documents),
          ),
          documentsOfflineBannerProvider.overrideWith(
            () => TestOfflineBannerNotifier(true),
          ),
          fileSelectionProvider.overrideWith(() => FakeFileSelectionNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Offline - showing cached data'), findsOneWidget);
  });

  testWidgets('shows offline SnackBar when upload tapped offline', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentsProvider.overrideWith(
            () => TestDocumentsNotifier(() async => []),
          ),
          documentsOfflineBannerProvider.overrideWith(
            () => TestOfflineBannerNotifier(true),
          ),
          fileSelectionProvider.overrideWith(() => FakeFileSelectionNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Upload Document'));
    await tester.pump();

    expect(find.text('Requires internet connection'), findsOneWidget);
  });
}
