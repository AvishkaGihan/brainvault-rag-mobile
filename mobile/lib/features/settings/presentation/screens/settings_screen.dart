import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/account_section.dart';

/// Settings screen for the BrainVault app
///
/// Displays account information and logout functionality.
/// Additional settings sections can be added as needed.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          AccountSection(),
          // Add more settings sections as needed
        ],
      ),
    );
  }
}
