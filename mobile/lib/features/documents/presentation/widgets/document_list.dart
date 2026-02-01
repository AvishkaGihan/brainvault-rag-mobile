import 'package:flutter/material.dart';
import '../../domain/entities/document.dart';
import 'document_card.dart';

/// Document list widget
class DocumentList extends StatelessWidget {
  final List<Document> documents;

  const DocumentList({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DocumentCard(document: document),
        );
      },
    );
  }
}
