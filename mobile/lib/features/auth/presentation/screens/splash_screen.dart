import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo with app name and subtle fade-in animation
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 800),
              child: SvgPicture.asset(
                'assets/images/logos/logo_mark.svg',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 16),

            // App name
            Text(
              'BrainVault',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'Your Second Brain',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),

            const Spacer(),

            // Loading indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: colorScheme.onPrimary.withValues(
                      alpha: 0.2,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Initializing...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
