import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/documents/presentation/screens/home_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';

GoRouter createGoRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Get auth state
      final authState = ref.watch(authStateProvider);
      final isLoggedIn = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, _) => false,
      );

      // Redirect logic:
      // - If not authenticated and going to protected routes → redirect to auth
      // - If authenticated and going to auth → redirect to home
      final isGoingToAuth =
          state.uri.toString() == '/auth' ||
          state.uri.toString() == '/register';

      if (!isLoggedIn && !isGoingToAuth) {
        return '/auth';
      }

      if (isLoggedIn && isGoingToAuth) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) {
          final documentId = state.uri.queryParameters['documentId'];
          return ChatScreen(documentId: documentId);
        },
      ),
      GoRoute(
        path: '/chat/:documentId',
        name: 'chat-document',
        builder: (context, state) {
          final documentId = state.pathParameters['documentId'];
          return ChatScreen(documentId: documentId);
        },
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
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
