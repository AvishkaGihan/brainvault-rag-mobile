import 'dart:io';
import '../constants/app_constants.dart';

/// Validates an email address.
/// Returns an error message if invalid, or null if valid.
String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  if (!AppConstants.emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
}

/// Validates a password.
/// Returns an error message if invalid, or null if valid.
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < AppConstants.minPasswordLength) {
    return 'Password must be at least ${AppConstants.minPasswordLength} characters';
  }
  return null;
}

/// Validates a confirmation password against the original password.
/// Returns an error message if they don't match, or null if valid.
String? confirmPasswordValidator(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }
  if (value != password) {
    return 'Passwords do not match';
  }
  return null;
}

/// Validates a chat message.
/// Returns an error message if invalid, or null if valid.
String? messageValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Message cannot be empty';
  }
  if (value.length > AppConstants.maxMessageLength) {
    return 'Message is too long (max ${AppConstants.maxMessageLength} characters)';
  }
  return null;
}

/// Validates a selected file for upload.
/// Checks strictly for PDF type and size limit (5MB).
/// Returns an error message if invalid, or null if valid.
String? fileValidator(File file) {
  final fileSize = file.lengthSync();
  final path = file.path.toLowerCase();

  // 1. Check file extension
  if (!path.endsWith('.pdf')) {
    return 'Only PDF files are allowed';
  }

  // 2. Check file size
  if (fileSize > AppConstants.maxFileSizeBytes) {
    return 'File is too large. Maximum size is ${AppConstants.maxFileSizeMB} MB';
  }

  return null;
}
