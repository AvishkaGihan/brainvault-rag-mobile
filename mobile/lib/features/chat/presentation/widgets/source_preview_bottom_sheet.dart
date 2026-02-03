import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';

/// A bottom sheet that displays a preview of a source citation snippet.
///
/// Shows the source page number and the text snippet extracted from
/// that page. If the snippet is unavailable, displays a fallback message.
/// The content is scrollable for long snippets.
class SourcePreviewBottomSheet extends StatelessWidget {
  final ChatSource source;

  const SourcePreviewBottomSheet({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final snippet = source.snippet?.trim();
    final displayText = (snippet == null || snippet.isEmpty)
        ? 'Preview unavailable.'
        : snippet;
    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          key: const Key('source_preview_bottom_sheet'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      source.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Semantics(
                    label: 'Close source preview',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    displayText,
                    style: TextStyle(color: colorScheme.onTertiaryContainer),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
