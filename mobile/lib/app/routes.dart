import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/documents/presentation/screens/documents_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

/// Helper class to connect Firebase auth stream to GoRouter's refreshListenable
///
/// This enables GoRouter to rebuild and re-evaluate redirect logic
/// whenever the Firebase auth state changes (login, logout, token refresh).
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  /// Creates a listener for any Stream and notifies GoRouter when values change
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Router provider with auth-aware navigation
///
/// This provider creates a GoRouter instance that:
/// - Listens to Firebase auth state changes via refreshListenable
/// - Redirects unauthenticated users to login
/// - Redirects authenticated users away from auth screens to home
/// - Shows splash screen during initial auth state determination
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authRepositoryProvider).authStateChanges(),
    ),
    redirect: (context, state) {
      // Show splash screen while auth state is loading
      if (authState is AsyncLoading) {
        return '/';
      }

      final user = authState.value;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';
      final isSplash = state.matchedLocation == '/';

      // User is authenticated
      if (user != null) {
        if (isSplash) return '/home';
        if (isLoggingIn) {
          final isRegister = state.matchedLocation == '/register';
          if (user.isAnonymous && isRegister) return null;
          return '/home';
        }
        return null; // Allow navigation to protected routes
      } else {
        // User is not authenticated
        if (isSplash) return '/login'; // Redirect from splash to login
        if (isLoggingIn) return null; // Allow access to auth screens
        return '/login'; // Redirect from protected routes to login
      }
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final documentId = state.uri.queryParameters['documentId'];
          return ChatScreen(documentId: documentId);
        },
      ),
      GoRoute(
        path: '/chat/:documentId',
        builder: (context, state) {
          final documentId = state.pathParameters['documentId'];
          return ChatScreen(documentId: documentId);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${state.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    },
  );
});
