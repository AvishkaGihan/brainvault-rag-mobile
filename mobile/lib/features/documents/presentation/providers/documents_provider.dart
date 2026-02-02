import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/cache/document_cache.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/document.dart';
import '../../domain/usecases/get_documents.dart';
import 'upload_provider.dart';

/// Provider for get documents use case
final getDocumentsUseCaseProvider = Provider<GetDocuments>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return GetDocuments(repository);
});

/// Provider for document cache
final documentCacheProvider = Provider<DocumentCache>((ref) {
  return DocumentCache();
});

/// Offline banner state when cached data is shown due to offline refresh
class DocumentsOfflineBannerNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void set(bool value) {
    state = value;
  }
}

final documentsOfflineBannerProvider =
    NotifierProvider<DocumentsOfflineBannerNotifier, bool>(() {
      return DocumentsOfflineBannerNotifier();
    });

/// Notifier for managing documents list state
/// STUB: Returns empty list until Story 4.1
class DocumentsNotifier extends AsyncNotifier<List<Document>> {
  bool _isRefreshing = false;

  @override
  Future<List<Document>> build() async {
    final cache = await ref.read(documentCacheProvider).read();
    if (cache != null) {
      _setOfflineBanner(false);
      Future.microtask(_refreshInBackground);
      return cache;
    }

    return await _fetchAndCache();
  }

  /// Refresh documents list
  Future<void> refresh() async {
    final current = state.value;
    if (current != null) {
      await _refreshInBackground();
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => _fetchAndCache());
  }

  /// Refresh documents for pull-to-refresh gesture.
  ///
  /// Returns the failure if refresh fails, null on success.
  /// This separate method allows the UI to surface failures via SnackBar
  /// while preserving cached data on screen, as required by AC #4.
  ///
  /// Prevents concurrent refreshes via [_isRefreshing] guard.
  Future<Failure?> refreshForPullToRefresh() async {
    if (_isRefreshing) return null; // Prevent concurrent refreshes
    _isRefreshing = true;

    try {
      final useCase = ref.read(getDocumentsUseCaseProvider);
      final documents = await useCase();
      if (!ref.mounted) {
        return null;
      }
      state = AsyncData(documents);
      _setOfflineBanner(false);
      await ref.read(documentCacheProvider).write(documents);
      return null;
    } on Failure catch (failure) {
      if (failure is ConnectionFailure || failure is TimeoutFailure) {
        _setOfflineBanner(true);
      } else {
        _setOfflineBanner(false);
      }
      return failure;
    } catch (_) {
      _setOfflineBanner(false);
      return const UnknownFailure();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<List<Document>> _fetchAndCache() async {
    final useCase = ref.read(getDocumentsUseCaseProvider);
    final documents = await useCase();
    _setOfflineBanner(false);
    await ref.read(documentCacheProvider).write(documents);
    return documents;
  }

  Future<void> _refreshInBackground() async {
    if (_isRefreshing) return; // Prevent concurrent refreshes
    _isRefreshing = true;
    try {
      final useCase = ref.read(getDocumentsUseCaseProvider);
      final documents = await useCase();
      if (!ref.mounted) {
        return;
      }
      state = AsyncData(documents);
      _setOfflineBanner(false);
      await ref.read(documentCacheProvider).write(documents);
    } on Failure catch (failure) {
      if (failure is ConnectionFailure || failure is TimeoutFailure) {
        _setOfflineBanner(true);
      } else {
        // For non-connection errors, clear offline banner
        _setOfflineBanner(false);
      }
    } catch (_) {
      // Ignore other background refresh errors
      _setOfflineBanner(false);
    } finally {
      _isRefreshing = false;
    }
  }

  void _setOfflineBanner(bool value) {
    final notifier = ref.read(documentsOfflineBannerProvider.notifier);
    if (notifier.state != value) {
      notifier.set(value);
    }
  }
}

/// Provider for DocumentsNotifier
/// Exposes the documents list state and actions to the UI
final documentsProvider =
    AsyncNotifierProvider<DocumentsNotifier, List<Document>>(() {
      return DocumentsNotifier();
    });
