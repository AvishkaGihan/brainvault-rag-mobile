import 'package:flutter/material.dart';
import 'routes.dart';
import '../core/theme/app_theme.dart';

class BrainVaultApp extends StatelessWidget {
  const BrainVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
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
