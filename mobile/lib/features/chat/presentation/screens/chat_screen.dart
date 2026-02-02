import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String? documentId;
  final String? documentTitle;

  const ChatScreen({super.key, this.documentId, this.documentTitle});

  @override
  Widget build(BuildContext context) {
    final resolvedTitle =
        (documentTitle != null && documentTitle!.trim().isNotEmpty)
        ? documentTitle!
        : 'Chat';

    return Scaffold(
      appBar: AppBar(title: Text(resolvedTitle)),
      body: const Center(child: Text('Chat functionality coming soon')),
    );
  }
}
