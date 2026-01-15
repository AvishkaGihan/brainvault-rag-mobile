import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';
import '../core/theme/app_theme.dart';

/// Main application widget with Material Design 3 theming
///
/// This widget sets up the app-wide theme and routing configuration.
/// The router is provided via Riverpod and automatically responds to
/// auth state changes for navigation logic.
class BrainVaultApp extends ConsumerWidget {
  const BrainVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider to get GoRouter instance
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BrainVault',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
