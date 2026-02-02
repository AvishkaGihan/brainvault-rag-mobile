import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';

class SourceCitationChip extends StatelessWidget {
  final ChatSource source;

  const SourceCitationChip({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      label: Text(source.label),
      backgroundColor: colorScheme.tertiaryContainer,
      labelStyle: TextStyle(color: colorScheme.onTertiaryContainer),
    );
  }
}
