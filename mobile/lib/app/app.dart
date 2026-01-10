import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';
import '../core/theme/app_theme.dart';

class BrainVaultApp extends ConsumerWidget {
  const BrainVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = createGoRouter(ref);

    return MaterialApp.router(
      title: 'BrainVault',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
