import 'package:flutter/material.dart';
import '../../domain/entities/document.dart';
import 'document_card.dart';

/// Document list widget
class DocumentList extends StatelessWidget {
  final List<Document> documents;
  final ValueChanged<Document>? onDocumentTap;
  final ValueChanged<Document>? onDocumentDelete;
  final ValueChanged<Document>? onDocumentInfo;

  const DocumentList({
    super.key,
    required this.documents,
    this.onDocumentTap,
    this.onDocumentDelete,
    this.onDocumentInfo,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DocumentCard(
            document: document,
            onTap: onDocumentTap == null
                ? null
                : () => onDocumentTap!(document),
            onDelete: onDocumentDelete == null
                ? null
                : () => onDocumentDelete!(document),
            onInfo: onDocumentInfo == null
                ? null
                : () => onDocumentInfo!(document),
          ),
        );
      },
    );
  }
}
