import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Extensions for String manipulation and validation
extension StringExtensions on String {
  /// Validates if the string is a valid email format
  bool get isValidEmail {
    return AppConstants.emailRegex.hasMatch(this);
  }

  /// Capitalizes the first letter of the string
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Truncates the string to a maximum length with ellipsis
  String truncate(int length) {
    if (this.length <= length) return this;
    return '${substring(0, length)}...';
  }
}

/// Extensions for DateTime formatting
extension DateTimeExtensions on DateTime {
  /// Returns a formatted date string like "Dec 20, 2024"
  /// Note: Ideally uses intl package, but simple mapping works for MVP dependencies
  String toFormattedDate() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[month - 1]} $day, $year';
  }

  /// Returns a relative time string like "2 hours ago"
  String toRelativeString() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 7) {
      return toFormattedDate();
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} ${difference.inDays == 1 ? "day" : "days"} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? "hour" : "hours"} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? "minute" : "minutes"} ago';
    } else {
      return 'Just now';
    }
  }
}

/// Extensions for consistent error handling and user-friendly messages
extension ErrorMessageExtension on Object {
  /// Extracts a user-friendly message from any error object,
  /// specifically handling DioExceptions and backend API error formats.
  String get userMessage {
    if (this is DioException) {
      final error = this as DioException;

      // 1. Try to parse backend API error response
      // Format: { "success": false, "error": { "code": "...", "message": "..." } }
      try {
        if (error.response?.data != null && error.response?.data is Map) {
          final data = error.response!.data as Map<String, dynamic>;
          if (data.containsKey('error')) {
            final errorObj = data['error'];
            if (errorObj is Map && errorObj.containsKey('message')) {
              return errorObj['message'].toString();
            } else if (errorObj is String) {
              return errorObj;
            }
          }
        }
      } catch (_) {
        // Fallback to standard Dio error mapping if parsing fails
      }

      // 2. Map standard Dio error types
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet.';

        case DioExceptionType.connectionError:
          return 'No internet connection.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401 || statusCode == 403) {
            return 'Session expired. Please log in again.';
          } else if (statusCode == 413) {
            return 'File too large. Maximum size is 5MB.';
          } else if (statusCode == 429) {
            return 'Too many requests. Please try again later.';
          } else if (statusCode != null && statusCode >= 500) {
            return 'Server error. Please try again later.';
          }
          return 'Something went wrong. Please try again.';

        case DioExceptionType.cancel:
          return 'Request cancelled.';

        default:
          return 'An unexpected network error occurred.';
      }
    }

    // 3. Fallback for generic exceptions
    return toString().replaceFirst('Exception: ', '');
  }
}
