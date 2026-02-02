import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../../features/documents/data/models/document_model.dart';
import '../../features/documents/domain/entities/document.dart';

/// Cache service for document metadata list
class DocumentCache {
  /// Read cached documents list
  Future<List<DocumentModel>?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.cachedDocumentsKey);
      if (raw == null) {
        return null;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return null;
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => DocumentModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Write documents list to cache
  Future<void> write(List<Document> documents) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = documents.map((doc) => _toModel(doc).toJson()).toList();
      await prefs.setString(
        AppConstants.cachedDocumentsKey,
        jsonEncode(jsonList),
      );
    } catch (_) {
      // Cache write failures should not break the app flow
    }
  }

  /// Clear cached documents
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.cachedDocumentsKey);
    } catch (_) {
      // Ignore cache clear failures
    }
  }

  DocumentModel _toModel(Document document) {
    if (document is DocumentModel) {
      return document;
    }

    return DocumentModel(
      id: document.id,
      title: document.title,
      fileName: document.fileName,
      fileSize: document.fileSize,
      pageCount: document.pageCount,
      vectorCount: document.vectorCount,
      indexedAt: document.indexedAt,
      extractionDurationMs: document.extractionDurationMs,
      status: document.status,
      createdAt: document.createdAt,
      updatedAt: document.updatedAt,
      errorMessage: document.errorMessage,
    );
  }
}
