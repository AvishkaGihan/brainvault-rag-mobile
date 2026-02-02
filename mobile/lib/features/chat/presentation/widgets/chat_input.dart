import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final bool isSendEnabled;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.isSendEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('chat_input_field'),
              controller: controller,
              onChanged: onChanged,
              onSubmitted: (_) => onSend(),
              textInputAction: TextInputAction.send,
              decoration: const InputDecoration(hintText: 'Ask a question...'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            key: const Key('chat_send_button'),
            onPressed: isSendEnabled ? onSend : null,
            icon: const Icon(Icons.send),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}
