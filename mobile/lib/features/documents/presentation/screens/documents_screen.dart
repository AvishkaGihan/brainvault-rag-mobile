import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BrainVault')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Home Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text('Documents and chat features will be integrated here'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showPlaceholder(context),
              child: const Text('View Documents'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document management coming soon')),
    );
  }
}
