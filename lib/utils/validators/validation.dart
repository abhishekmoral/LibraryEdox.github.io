/// A collection of static form-field validators used across the EdoxLibrary app.
///
/// Each method returns `null` when the value is valid, or an error message [String]
/// when validation fails. This makes them directly usable with `TextFormField.validator`.
class XValidator {
  XValidator._();

  // ──────────────────────────── Generic ──────────────────────────

  /// Validates that the field named [fieldName] is not empty.
  static String? validateEmptyText(String fieldName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  // ──────────────────────────── Email ────────────────────────────

  /// Validates a well-formed email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  // ──────────────────────────── Password ─────────────────────────

  /// Validates a password with the following rules:
  /// - Minimum 6 characters
  /// - At least 1 uppercase letter
  /// - At least 1 digit
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number.';
    }
    return null;
  }

  // ──────────────────────────── Phone ────────────────────────────

  /// Validates a 10-digit Indian phone number.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }

    // Strip spaces, dashes, and optional +91 prefix
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '').replaceFirst(RegExp(r'^\+?91'), '');

    if (cleaned.length != 10) {
      return 'Phone number must be 10 digits.';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return 'Please enter a valid Indian phone number.';
    }
    return null;
  }

  // ──────────────────────────── Name ─────────────────────────────

  /// Validates a person's name (2–50 characters, alphabets & spaces only).
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long.';
    }
    if (value.trim().length > 50) {
      return 'Name must not exceed 50 characters.';
    }
    if (!RegExp(r"^[a-zA-Z\s.']+$").hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces, dots, and apostrophes.';
    }
    return null;
  }

  // ──────────────────────────── Amount ───────────────────────────

  /// Validates a monetary amount (positive number).
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required.';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Please enter a valid amount.';
    }
    if (amount <= 0) {
      return 'Amount must be greater than zero.';
    }
    return null;
  }

  // ──────────────────────────── Seat Number ──────────────────────

  /// Validates a seat number (alphanumeric, 1–10 characters).
  static String? validateSeatNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Seat number is required.';
    }
    if (!RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(value.trim())) {
      return 'Seat number can only contain letters, numbers, and dashes.';
    }
    if (value.trim().length > 10) {
      return 'Seat number must not exceed 10 characters.';
    }
    return null;
  }

  // ──────────────────────────── Plan Name ────────────────────────

  /// Validates a plan / subscription name.
  static String? validatePlanName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Plan name is required.';
    }
    if (value.trim().length < 2) {
      return 'Plan name must be at least 2 characters.';
    }
    if (value.trim().length > 50) {
      return 'Plan name must not exceed 50 characters.';
    }
    return null;
  }

  // ──────────────────────────── Duration ─────────────────────────

  /// Validates a duration value (positive integer, typically in months or days).
  static String? validateDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Duration is required.';
    }
    final duration = int.tryParse(value.trim());
    if (duration == null) {
      return 'Please enter a valid number.';
    }
    if (duration <= 0) {
      return 'Duration must be greater than zero.';
    }
    if (duration > 365) {
      return 'Duration cannot exceed 365 days.';
    }
    return null;
  }

  // ──────────────────────────── Address ──────────────────────────

  /// Validates an address (10–200 characters).
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required.';
    }
    if (value.trim().length < 10) {
      return 'Address must be at least 10 characters long.';
    }
    if (value.trim().length > 200) {
      return 'Address must not exceed 200 characters.';
    }
    return null;
  }
}
