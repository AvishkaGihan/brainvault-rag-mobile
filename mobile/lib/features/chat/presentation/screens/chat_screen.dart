import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String? documentId;

  const ChatScreen({super.key, this.documentId});

  @override
  Widget build(BuildContext context) {
    // Validate document ID if provided
    if (documentId != null && documentId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Invalid document ID')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(documentId != null ? 'Chat - $documentId' : 'Chat Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chat Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            if (documentId != null)
              Text('Chatting about: $documentId')
            else
              const Text('No document selected'),
          ],
        ),
      ),
    );
  }
}
