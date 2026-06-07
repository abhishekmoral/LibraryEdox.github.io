import 'package:intl/intl.dart';

/// Provides static formatting utilities for dates, currency, phone numbers,
/// durations, and relative time strings used across the EdoxLibrary app.
class XFormatter {
  XFormatter._();

  // ──────────────────────────── Date ─────────────────────────────

  /// Formats a [DateTime] as `dd MMM yyyy` (e.g. `01 Jun 2026`).
  /// Returns an empty string when [date] is `null`.
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Formats a [DateTime] as `dd MMM yyyy, hh:mm a` (e.g. `01 Jun 2026, 07:30 AM`).
  /// Returns an empty string when [date] is `null`.
  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  // ──────────────────────────── Phone ────────────────────────────

  /// Formats a 10-digit phone number as `XXXXX XXXXX`.
  /// If the number has a `+91` prefix it is preserved.
  static String formatPhoneNumber(String number) {
    final cleaned = number.replaceAll(RegExp(r'[\s\-()]'), '');

    // Handle +91 prefix
    if (cleaned.startsWith('+91') && cleaned.length == 13) {
      final local = cleaned.substring(3);
      return '+91 ${local.substring(0, 5)} ${local.substring(5)}';
    }

    // Handle plain 10-digit number
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 5)} ${cleaned.substring(5)}';
    }

    // Return as-is if format is unknown
    return number;
  }

  // ──────────────────────────── Currency ─────────────────────────

  /// Formats [amount] as Indian Rupee currency.
  /// Example: `1000.50` → `₹1,000.50`
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Formats [amount] as a compact Indian Rupee string.
  /// Examples: `1500` → `₹1.5K`, `150000` → `₹1.5L`, `10000000` → `₹1Cr`
  static String formatCompactCurrency(double amount) {
    if (amount.abs() >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(amount % 10000000 == 0 ? 0 : 1)}Cr';
    } else if (amount.abs() >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(amount % 100000 == 0 ? 0 : 1)}L';
    } else if (amount.abs() >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  // ──────────────────────────── Duration ─────────────────────────

  /// Formats [months] into a human-readable string.
  /// Examples: `1` → `1 Month`, `3` → `3 Months`, `12` → `12 Months`
  static String formatDuration(int months) {
    if (months <= 0) return '0 Months';
    if (months == 1) return '1 Month';
    return '$months Months';
  }

  // ──────────────────────────── Relative Time ────────────────────

  /// Returns a human-readable relative time string.
  /// Examples: `just now`, `2 minutes ago`, `3 hours ago`, `yesterday`, `5 days ago`
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.isNegative) {
      // Future dates
      final absDiff = date.difference(now);
      if (absDiff.inMinutes < 1) return 'just now';
      if (absDiff.inMinutes < 60) return 'in ${absDiff.inMinutes} ${absDiff.inMinutes == 1 ? 'minute' : 'minutes'}';
      if (absDiff.inHours < 24) return 'in ${absDiff.inHours} ${absDiff.inHours == 1 ? 'hour' : 'hours'}';
      if (absDiff.inDays == 1) return 'tomorrow';
      if (absDiff.inDays < 7) return 'in ${absDiff.inDays} days';
      return formatDate(date);
    }

    // Past dates
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    if (diff.inHours < 24) return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? 'week' : 'weeks'} ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    return '${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
  }

  // ──────────────────────────── Seat Number ──────────────────────

  /// Formats a seat number with prefix and zero-padded number.
  /// Example: `formatSeatNumber('A', 1)` → `A-01`
  static String formatSeatNumber(String prefix, int number) {
    return '$prefix-${number.toString().padLeft(2, '0')}';
  }
}
