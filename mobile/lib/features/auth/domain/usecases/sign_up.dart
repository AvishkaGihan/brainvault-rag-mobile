import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing up with email and password
class SignUpUseCase {
  final AuthRepository authRepository;

  SignUpUseCase({required this.authRepository});

  /// Execute the email/password registration operation
  /// Returns the authenticated User on success
  /// Throws Exception if registration fails
  Future<User> call(String email, String password) {
    return authRepository.registerWithEmail(email, password);
  }
}
