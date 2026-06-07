import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// A collection of helper functions used throughout the EdoxLibrary application.
/// Provides utility methods for UI, navigation, formatting, and status checks.
class XHelperFunctions {
  XHelperFunctions._();

  // ──────────────────────────── Theme ────────────────────────────

  /// Returns `true` if the current theme mode is dark.
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // ──────────────────────────── Screen ───────────────────────────

  /// Returns the full [Size] of the current screen.
  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Returns the screen width in logical pixels.
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Returns the screen height in logical pixels.
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // ──────────────────────────── Snackbars ────────────────────────

  /// Shows a generic snackbar. Set [isError] to `true` for error styling.
  static void showSnackBar(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.shade600 : Colors.blueGrey.shade800,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.info_outline,
        color: Colors.white,
      ),
    );
  }

  /// Shows a success snackbar with a green background.
  static void showSuccessSnackBar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  /// Shows an error snackbar with a red background.
  static void showErrorSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  /// Shows a warning snackbar with an amber background.
  static void showWarningSnackBar(String message) {
    Get.snackbar(
      'Warning',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.amber.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.warning_amber_outlined, color: Colors.white),
    );
  }

  // ──────────────────────────── Dialogs ──────────────────────────

  /// Shows a simple informational alert dialog.
  static void showAlert(String title, String message) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
      barrierDismissible: true,
      radius: 12,
    );
  }

  /// Shows a confirmation dialog with Cancel and Confirm actions.
  static void showConfirmDialog(
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      textConfirm: 'Confirm',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.grey,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
      barrierDismissible: false,
      radius: 12,
    );
  }

  // ──────────────────────────── Navigation ───────────────────────

  /// Navigates to the given [screen] using GetX.
  static void navigateToScreen(Widget screen) {
    Get.to(() => screen);
  }

  // ──────────────────────────── Text ─────────────────────────────

  /// Truncates [text] to [maxLength] and appends `...` if it exceeds the limit.
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // ──────────────────────────── Status Colors ────────────────────

  /// Returns a colour based on a generic status string.
  static Color getColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'available':
      case 'paid':
      case 'success':
        return Colors.green;
      case 'inactive':
      case 'occupied':
      case 'pending':
      case 'warning':
        return Colors.orange;
      case 'expired':
      case 'blocked':
      case 'failed':
      case 'overdue':
        return Colors.red;
      case 'reserved':
      case 'processing':
        return Colors.blue;
      case 'maintenance':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Returns a colour for seat-specific statuses.
  static Color getSeatStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'occupied':
        return Colors.red;
      case 'reserved':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'blocked':
        return Colors.grey.shade700;
      default:
        return Colors.grey;
    }
  }

  /// Returns a colour for member-specific statuses.
  static Color getMemberStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'expired':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'suspended':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  /// Returns a colour for payment-specific statuses.
  static Color getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      case 'overdue':
        return Colors.red.shade800;
      case 'partial':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  // ──────────────────────────── Formatting ───────────────────────

  /// Formats a [DateTime] as `dd MMM yyyy` (e.g. `01 Jun 2026`).
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Formats a currency [amount] in Indian Rupee format with commas.
  /// Example: `1500.50` → `₹1,500.50`
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // ──────────────────────────── Date Helpers ─────────────────────

  /// Returns the number of days remaining until [expiryDate].
  /// Returns a negative number if [expiryDate] is in the past.
  static int getDaysRemaining(DateTime expiryDate) {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  /// Returns a human-readable member status based on [expiryDate].
  static String getMemberStatus(DateTime expiryDate) {
    final days = getDaysRemaining(expiryDate);
    if (days < 0) return 'Expired';
    if (days == 0) return 'Expires Today';
    if (days <= 3) return 'Expiring Soon';
    if (days <= 7) return 'Expiring This Week';
    return 'Active';
  }

  // ──────────────────────────── Greeting ─────────────────────────

  /// Returns a time-appropriate greeting string.
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
