String mapAuthErrorToUserMessage(Object error) {
  if (error is Exception) {
    final message = error.toString();
    if (message.contains('Network error')) {
      return 'Network error. Please check your connection and try again.';
    } else if (message.contains('too-many-requests')) {
      return 'Too many sign-in attempts. Please try again in a few minutes.';
    } else if (message.contains('operation-not-allowed')) {
      return 'Guest authentication is not available. Please contact support.';
    }
  }
  return 'Sign-in failed. Please try again.';
}

/// Maps password reset errors to user-friendly messages
/// Context-specific error handling for password reset flow per AC7
String mapPasswordResetErrorToUserMessage(Object error) {
  if (error is Exception) {
    final message = error.toString();
    if (message.contains('network-request-failed') ||
        message.contains('Network error')) {
      return 'Couldn\'t send reset link. Please check your internet connection.';
    } else if (message.contains('too-many-requests')) {
      return 'Too many requests. Please try again in a few minutes.';
    } else if (message.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
  }
  return 'Something went wrong. Please try again.';
}
