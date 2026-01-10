import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in as a guest (anonymous authentication)
class SignInAsGuestUseCase {
  final AuthRepository authRepository;

  SignInAsGuestUseCase({required this.authRepository});

  /// Execute the guest sign-in operation
  /// Returns the authenticated guest User
  /// Throws Exception if authentication fails
  Future<User> call() {
    return authRepository.signInAsGuest();
  }
}
