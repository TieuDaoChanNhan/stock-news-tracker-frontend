import 'package:intl/intl.dart';

class DateFormatter {
  /// Parses a date string safely, returning null if the format is invalid.
  static DateTime? safeParse(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing date: $dateString, Error: $e');
      return null;
    }
  }

  /// Formats a DateTime object into a display-friendly string.
  /// Returns 'N/A' if the date is null.
  static String formatDateTime(DateTime? date) {
    if (date == null) {
      return 'Không xác định';
    }
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }

  /// Calculates the time elapsed since the given date.
  /// Returns a relative time string like "5 phút trước".
  static String timeAgo(DateTime? date) {
    if (date == null) {
      return 'Không xác định';
    }
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDateTime(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
