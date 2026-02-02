import 'dart:async';

import 'package:brainvault/features/documents/domain/entities/document.dart';
import 'package:brainvault/features/documents/presentation/providers/documents_provider.dart';
import 'package:brainvault/features/documents/presentation/providers/upload_provider.dart';
import 'package:brainvault/features/documents/presentation/screens/documents_screen.dart';
import 'package:brainvault/features/documents/presentation/widgets/document_card.dart';
import 'package:brainvault/features/documents/presentation/widgets/empty_documents.dart';
import 'package:brainvault/features/chat/presentation/screens/chat_screen.dart';
import 'package:brainvault/core/error/failures.dart';
import 'package:brainvault/shared/widgets/skeleton_loader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class TestDocumentsNotifier extends DocumentsNotifier {
  final Future<List<Document>> Function() buildFn;
  final Future<Failure?> Function()? refreshForPullToRefreshFn;

  TestDocumentsNotifier(this.buildFn, {this.refreshForPullToRefreshFn});

  @override
  Future<List<Document>> build() => buildFn();

  @override
  Future<Failure?> refreshForPullToRefresh() async {
    if (refreshForPullToRefreshFn != null) {
      return refreshForPullToRefreshFn!();
    }

    return super.refreshForPullToRefresh();
  }
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

GoRouter _createTestRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/chat/:documentId',
        builder: (context, state) {
          final documentId = state.pathParameters['documentId'];
          final extra = state.extra;
          String? documentTitle;
          if (extra is Map) {
            final value = extra['title'];
            if (value is String && value.trim().isNotEmpty) {
              documentTitle = value;
            }
          }
          return ChatScreen(
            documentId: documentId,
            documentTitle: documentTitle,
          );
        },
      ),
    ],
  );
}

Future<void> _pumpHomeScreen(
  WidgetTester tester, {
  required GoRouter router,
  required List<Document> documents,
  bool offline = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        documentsProvider.overrideWith(
          () => TestDocumentsNotifier(() async => documents),
        ),
        fileSelectionProvider.overrideWith(() => FakeFileSelectionNotifier()),
        if (offline)
          documentsOfflineBannerProvider.overrideWith(
            () => TestOfflineBannerNotifier(true),
          ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );

  await tester.pumpAndSettle();
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

  testWidgets('pull-to-refresh triggers refresh call', (tester) async {
    var refreshCalled = false;
    final documents = [
      Document(
        id: 'doc-4',
        title: 'Refresh Doc',
        fileName: 'refresh.pdf',
        fileSize: 4096,
        status: DocumentStatus.ready,
        createdAt: DateTime(2026, 1, 20),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentsProvider.overrideWith(
            () => TestDocumentsNotifier(
              () async => documents,
              refreshForPullToRefreshFn: () async {
                refreshCalled = true;
                return null;
              },
            ),
          ),
          fileSelectionProvider.overrideWith(() => FakeFileSelectionNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Find the ScrollView inside RefreshIndicator and pull down
    await tester.drag(
      find.byType(RefreshIndicator).first,
      const Offset(0, 200),
    );
    await tester.pumpAndSettle();

    expect(refreshCalled, isTrue);
  });

  testWidgets(
    'network failure on pull-to-refresh shows SnackBar and keeps list',
    (tester) async {
      final documents = [
        Document(
          id: 'doc-5',
          title: 'Network Doc',
          fileName: 'network.pdf',
          fileSize: 8192,
          status: DocumentStatus.ready,
          createdAt: DateTime(2026, 1, 22),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentsProvider.overrideWith(
              () => TestDocumentsNotifier(
                () async => documents,
                refreshForPullToRefreshFn: () async =>
                    const ConnectionFailure(),
              ),
            ),
            fileSelectionProvider.overrideWith(
              () => FakeFileSelectionNotifier(),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(RefreshIndicator).first,
        const Offset(0, 200),
      );
      await tester.pumpAndSettle();

      expect(find.text("Couldn't refresh. Please try again."), findsOneWidget);
      expect(find.text('Network Doc'), findsOneWidget);
      expect(find.byType(ListSkeletonLoader), findsNothing);
    },
  );

  testWidgets('successful pull-to-refresh keeps list without skeleton', (
    tester,
  ) async {
    final documents = [
      Document(
        id: 'doc-6',
        title: 'Success Doc',
        fileName: 'success.pdf',
        fileSize: 5120,
        status: DocumentStatus.ready,
        createdAt: DateTime(2026, 1, 25),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentsProvider.overrideWith(
            () => TestDocumentsNotifier(
              () async => documents,
              refreshForPullToRefreshFn: () async => null,
            ),
          ),
          fileSelectionProvider.overrideWith(() => FakeFileSelectionNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(RefreshIndicator).first,
      const Offset(0, 200),
    );
    await tester.pumpAndSettle();

    expect(find.text('Success Doc'), findsOneWidget);
    expect(find.byType(ListSkeletonLoader), findsNothing);
  });

  testWidgets('pull-to-refresh works on empty document list', (tester) async {
    var refreshCalled = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentsProvider.overrideWith(
            () => TestDocumentsNotifier(
              () async => [],
              refreshForPullToRefreshFn: () async {
                refreshCalled = true;
                return null;
              },
            ),
          ),
          fileSelectionProvider.overrideWith(() => FakeFileSelectionNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify empty state is visible
    expect(find.byType(EmptyDocuments), findsOneWidget);

    // Perform pull-to-refresh on empty list
    await tester.drag(
      find.byType(RefreshIndicator).first,
      const Offset(0, 200),
    );
    await tester.pumpAndSettle();

    expect(refreshCalled, isTrue);
    expect(find.byType(EmptyDocuments), findsOneWidget);
  });

  testWidgets('pull-to-refresh with offline banner preserves banner and list', (
    tester,
  ) async {
    var refreshCalled = false;
    final documents = [
      Document(
        id: 'doc-7',
        title: 'Offline Refresh Doc',
        fileName: 'offline_refresh.pdf',
        fileSize: 3072,
        status: DocumentStatus.ready,
        createdAt: DateTime(2026, 1, 23),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentsProvider.overrideWith(
            () => TestDocumentsNotifier(
              () async => documents,
              refreshForPullToRefreshFn: () async {
                refreshCalled = true;
                // Simulate offline failure
                return const ConnectionFailure();
              },
            ),
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

    // Verify offline banner is visible before pull-to-refresh
    expect(find.text('Offline - showing cached data'), findsOneWidget);
    expect(find.text('Offline Refresh Doc'), findsOneWidget);

    // Perform pull-to-refresh
    await tester.drag(
      find.byType(RefreshIndicator).first,
      const Offset(0, 200),
    );
    await tester.pumpAndSettle();

    expect(refreshCalled, isTrue);
    // Verify offline banner and list remain visible after failed refresh
    expect(find.text('Offline - showing cached data'), findsOneWidget);
    expect(find.text('Offline Refresh Doc'), findsOneWidget);
    expect(find.text("Couldn't refresh. Please try again."), findsOneWidget);
  });

  testWidgets('should navigate to chat when ready document tapped', (
    tester,
  ) async {
    final documents = [
      Document(
        id: 'doc-ready',
        title: 'Ready Doc',
        fileName: 'ready.pdf',
        fileSize: 1024,
        status: DocumentStatus.ready,
        createdAt: DateTime(2026, 2, 1),
      ),
    ];

    final router = _createTestRouter();

    await _pumpHomeScreen(tester, router: router, documents: documents);

    await tester.tap(find.text('Ready Doc'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Ready Doc'), findsOneWidget);
  });

  testWidgets(
    'should show processing SnackBar when processing document tapped',
    (tester) async {
      final documents = [
        Document(
          id: 'doc-processing',
          title: 'Processing Doc',
          fileName: 'processing.pdf',
          fileSize: 2048,
          status: DocumentStatus.processing,
          createdAt: DateTime(2026, 2, 1),
        ),
      ];

      final router = _createTestRouter();

      await _pumpHomeScreen(tester, router: router, documents: documents);

      await tester.tap(find.text('Processing Doc'));
      await tester.pump();

      expect(
        find.text('This document is still processing. Please wait.'),
        findsOneWidget,
      );
      expect(find.byType(ChatScreen), findsNothing);
    },
  );

  testWidgets('should show error dialog when failed document tapped', (
    tester,
  ) async {
    final documents = [
      Document(
        id: 'doc-error',
        title: 'Error Doc',
        fileName: 'error.pdf',
        fileSize: 4096,
        status: DocumentStatus.failed,
        createdAt: DateTime(2026, 2, 1),
        errorMessage: 'Processing failed on server.',
      ),
    ];

    final router = _createTestRouter();

    await _pumpHomeScreen(tester, router: router, documents: documents);

    await tester.tap(find.text('Error Doc'));
    await tester.pumpAndSettle();

    expect(find.text('Document processing failed'), findsOneWidget);
    expect(find.text('Processing failed on server.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('should block navigation when offline banner is shown', (
    tester,
  ) async {
    final documents = [
      Document(
        id: 'doc-offline',
        title: 'Offline Doc',
        fileName: 'offline.pdf',
        fileSize: 1024,
        status: DocumentStatus.ready,
        createdAt: DateTime(2026, 2, 1),
      ),
    ];

    final router = _createTestRouter();

    await _pumpHomeScreen(
      tester,
      router: router,
      documents: documents,
      offline: true,
    );

    await tester.tap(find.text('Offline Doc'));
    await tester.pump();

    expect(find.text('Requires internet connection'), findsOneWidget);
    expect(find.byType(ChatScreen), findsNothing);
  });
}
