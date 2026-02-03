import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/chat_message.dart';
import 'source_preview_bottom_sheet.dart';
import 'source_citation_chip.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  void _showSourcePreviewSheet(BuildContext context, ChatSource source) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SourcePreviewBottomSheet(source: source);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatMessageRole.user;
    final colorScheme = Theme.of(context).colorScheme;
    final bubbleColor = isUser
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final textColor = isUser
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;
    final timeColor = textColor.withValues(alpha: 0.7);
    final dateTime = message.createdAt ?? DateTime.now();
    final timeString = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));

    return Align(
      key: const Key('chat_message_bubble_align'),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              key: const Key('chat_message_bubble_container'),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(color: textColor),
                      softWrap: true,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeString,
                      key: const Key('chat_message_bubble_timestamp'),
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: timeColor),
                    ),
                  ],
                ),
              ),
            ),
            if (!isUser && message.sources.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < message.sources.length; i++)
                    SourceCitationChip(
                      key: ValueKey('source_chip_$i'),
                      source: message.sources[i],
                      onPressed: () =>
                          _showSourcePreviewSheet(context, message.sources[i]),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
