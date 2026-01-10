/// Validation utilities for the BrainVault mobile app
/// Provides reusable validation functions for forms and user input
library;

/// Validates email format using regex
/// Returns true if email matches standard email pattern
bool isValidEmail(String email) {
  if (email.isEmpty) return false;
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegex.hasMatch(email.trim());
}

/// Validates password strength (minimum 6 characters)
/// Returns true if password meets minimum requirements
bool isValidPassword(String password) {
  return password.length >= 6;
}

/// Validates password confirmation match
/// Returns true if passwords match exactly
bool isPasswordMatch(String password, String confirmPassword) {
  return password == confirmPassword;
}

/// Gets email validation error message
/// Returns null if valid, error message if invalid
String? getEmailError(String email) {
  if (email.isEmpty) return 'Email is required';
  if (!isValidEmail(email)) return 'Please enter a valid email address';
  return null;
}

/// Gets password validation error message
/// Returns null if valid, error message if invalid
String? getPasswordError(String password) {
  if (password.isEmpty) return 'Password is required';
  if (!isValidPassword(password)) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

/// Gets password confirmation validation error message
/// Returns null if valid, error message if invalid
String? getPasswordMatchError(String password, String confirmPassword) {
  if (confirmPassword.isEmpty) return 'Please confirm your password';
  if (!isPasswordMatch(password, confirmPassword)) {
    return 'Passwords do not match';
  }
  return null;
}
