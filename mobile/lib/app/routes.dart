import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/documents/presentation/screens/home_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // TODO: Implement authentication check
    // Example redirect logic for protected routes:
    // if (authState.isLoggedOut && state.location != '/auth') return '/auth';
    // if (authState.isLoggedIn && state.location == '/auth') return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
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
