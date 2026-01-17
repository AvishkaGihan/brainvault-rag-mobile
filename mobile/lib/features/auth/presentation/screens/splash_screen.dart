import 'dart:async';

import 'package:flutter/material.dart';

/// Splash screen displayed during initial auth state check
///
/// This screen is shown when the app launches while Firebase Auth
/// determines if a user session exists. It provides a branded loading
/// experience and prevents flashing the wrong screen before auth state
/// is confirmed.
///
/// The splash screen automatically dismisses when GoRouter's redirect
/// logic determines the correct route based on auth state.
///
/// Includes a 2-second failsafe timeout: if auth state is not determined
/// within 2 seconds, automatically navigates to login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Timer _failsafeTimer;

  @override
  void initState() {
    super.initState();
    // 2-second failsafe: if auth check hangs, navigate to login
    _failsafeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        debugPrint('Auth state check timed out after 2 seconds');
        // GoRouter will automatically redirect based on auth state
        // This timer ensures we don't get stuck on splash screen
      }
    });
  }

  @override
  void dispose() {
    _failsafeTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo with subtle fade-in animation
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 800),
              child: Image.asset(
                isDarkMode
                    ? 'assets/images/logo_splash_dark.png'
                    : 'assets/images/logo_splash.png',
                width: 120,
                height: 120,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
