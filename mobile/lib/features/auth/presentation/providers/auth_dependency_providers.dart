import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_as_guest.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/sign_out.dart';

/// Provider for AuthRemoteDataSource implementation
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

/// Provider for AuthRepository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider for SignInAsGuestUseCase
final signInAsGuestUseCaseProvider = Provider<SignInAsGuestUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInAsGuestUseCase(authRepository: repository);
});

/// Provider for SignUpUseCase
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUseCase(authRepository: repository);
});

/// Provider for SignInUseCase
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(authRepository: repository);
});

/// Provider for ResetPasswordUseCase
final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(authRepository: repository);
});

/// Provider for SignOutUseCase
final logoutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(authRepository: authRepository);
});
