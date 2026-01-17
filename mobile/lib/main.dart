import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before running the app
  // Story 1.3: Configure Firebase Project & Services
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase initialization critical for authentication and data access
    // Allow app to continue but auth will fail gracefully
    debugPrint(
      'CRITICAL: Firebase initialization failed: $e\n'
      'App will not be functional without Firebase.',
    );
  }

  runApp(const ProviderScope(child: BrainVaultApp()));
}
