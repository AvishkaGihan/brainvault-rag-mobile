import 'dart:math';

/// Formats a file size in bytes to a human-readable string.
/// Examples: "500 B", "1.5 KB", "4.2 MB"
String formatFileSize(int bytes) {
  if (bytes <= 0) return '0 B';

  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  var i = (log(bytes) / log(1024)).floor();

  // Prevent index out of bounds if huge number
  if (i >= suffixes.length) i = suffixes.length - 1;

  final size = bytes / pow(1024, i);

  // If it's bytes, don't show decimal
  if (i == 0) return '${size.toInt()} ${suffixes[i]}';

  return '${size.toStringAsFixed(1)} ${suffixes[i]}';
}

/// Formats a DateTime to a standard date string.
/// Format: "Dec 20, 2024"
/// Note: Ideally uses intl package, but manual mapping avoids extra dependencies for MVP.
String formatDate(DateTime date) {
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
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// Formats a DateTime to a relative time string.
/// Examples: "Just now", "5 minutes ago", "2 hours ago", "Dec 20, 2024"
String formatRelativeTime(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes ${minutes == 1 ? "minute" : "minutes"} ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? "hour" : "hours"} ago';
  } else if (difference.inDays < 7) {
    final days = difference.inDays;
    return '$days ${days == 1 ? "day" : "days"} ago';
  } else {
    return formatDate(date);
  }
}

/// Formats a decimal value (0.0 to 1.0) as a percentage string.
/// Example: 0.654 -> "65%"
String formatPercentage(double value) {
  final percentage = (value * 100).round();
  return '$percentage%';
}

/// Formats a page count with correct pluralization.
/// Example: "1 page", "15 pages"
String formatPageCount(int pages) {
  return '$pages ${pages == 1 ? "page" : "pages"}';
}
