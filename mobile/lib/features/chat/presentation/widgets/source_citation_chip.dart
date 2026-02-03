import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';

/// A chip that displays a citation source reference.
///
/// Shows the page number of a source document and can be tapped
/// to view a preview of the snippet in a bottom sheet.
class SourceCitationChip extends StatelessWidget {
  final ChatSource source;
  final VoidCallback? onPressed;

  const SourceCitationChip({super.key, required this.source, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'View source from page ${source.pageNumber}',
      button: true,
      child: ActionChip(
        label: Text(source.label),
        backgroundColor: colorScheme.tertiaryContainer,
        labelStyle: TextStyle(color: colorScheme.onTertiaryContainer),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        onPressed: onPressed,
      ),
    );
  }
}
