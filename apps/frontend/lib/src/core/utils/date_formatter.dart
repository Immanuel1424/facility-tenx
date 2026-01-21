import 'package:intl/intl.dart';

/// Centralized date and time formatting utility
/// Ensures consistent date/time display across the entire application
class DateFormatter {
  // Private constructor to prevent instantiation
  DateFormatter._();

  /// Formats a date-time for display in detail pages
  /// Format: "MMM dd, yyyy • hh:mm a" (e.g., "Jan 15, 2024 • 02:30 PM")
  static String formatDateTime(DateTime dateTime) {
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return DateFormat('MMM dd, yyyy • hh:mm a').format(localDateTime);
  }

  /// Formats a date for display in list pages (with time)
  /// Format: "MMM dd, yyyy • hh:mm a" (e.g., "Jan 15, 2024 • 02:30 PM")
  static String formatDate(DateTime dateTime) {
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return DateFormat('MMM dd, yyyy • hh:mm a').format(localDateTime);
  }

  /// Formats a date for compact display (mobile) with time
  /// Format: "MMM dd • hh:mm a" (e.g., "Jan 15 • 02:30 PM")
  static String formatDateCompact(DateTime dateTime) {
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return DateFormat('MMM dd • hh:mm a').format(localDateTime);
  }

  /// Formats time only with AM/PM
  /// Format: "hh:mm a" (e.g., "02:30 PM")
  static String formatTime(DateTime dateTime) {
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return DateFormat('hh:mm a').format(localDateTime);
  }

  /// Formats date and time for forms/input with AM/PM
  /// Format: "dd/MM/yyyy hh:mm a" (e.g., "15/01/2024 02:30 PM")
  static String formatDateTimeForInput(DateTime dateTime) {
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return DateFormat('dd/MM/yyyy hh:mm a').format(localDateTime);
  }

  /// Formats date for forms/input (date only)
  /// Format: "dd MMM yyyy" (e.g., "15 Jan 2024")
  static String formatDateForInput(DateTime dateTime) {
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return DateFormat('dd MMM yyyy').format(localDateTime);
  }

  /// Formats date for API/database (ISO 8601)
  /// Format: "yyyy-MM-dd HH:mm" (e.g., "2024-01-15 14:30")
  static String formatDateTimeForApi(DateTime dateTime) {
    final utcDateTime = dateTime.isUtc ? dateTime : dateTime.toUtc();
    return DateFormat('yyyy-MM-dd HH:mm').format(utcDateTime);
  }

  /// Formats date with relative time for list items
  /// Returns: "Created today • 02:30 PM" or "Created yesterday • 02:30 PM" or "Created Jan 15 • 02:30 PM"
  static String formatDateTimeRelative(DateTime dateTime) {
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final ticketDate = DateTime(
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
    );

    final timeStr = formatTime(localDateTime);

    if (ticketDate == today) {
      return 'Created today • $timeStr';
    } else if (ticketDate == today.subtract(const Duration(days: 1))) {
      return 'Created yesterday • $timeStr';
    } else {
      final dateStr = DateFormat('MMM d').format(localDateTime);
      return 'Created $dateStr • $timeStr';
    }
  }

  /// Formats date with relative time (e.g., "2 days ago", "3 hours ago")
  /// Used for notifications and activity feeds
  static String formatDateTimeRelativeShort(DateTime dateTime) {
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    final now = DateTime.now();
    final difference = now.difference(localDateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Formats date for chart labels (date only, no time)
  /// Format: "MMM d" (e.g., "Jan 15")
  static String formatDateForChart(DateTime dateTime) {
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return DateFormat('MMM d').format(localDateTime);
  }

  /// Formats date and time for table display
  /// Format: "MMM dd, yyyy hh:mm a" (e.g., "Jan 15, 2024 02:30 PM")
  static String formatDateTimeForTable(DateTime dateTime) {
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return DateFormat('MMM dd, yyyy hh:mm a').format(localDateTime);
  }

  /// Formats nullable date-time
  static String? formatDateTimeNullable(DateTime? dateTime) {
    if (dateTime == null) return null;
    return formatDateTime(dateTime);
  }

  /// Formats nullable date
  static String? formatDateNullable(DateTime? dateTime) {
    if (dateTime == null) return null;
    return formatDate(dateTime);
  }
}

