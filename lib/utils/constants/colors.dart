import 'package:flutter/material.dart';

/// EdoxLibrary color constants used throughout the application.
/// Supports both light and dark themes.
class XColors {
  XColors._();

  // ──────────────────────────────────────────────
  // Brand Colors
  // ──────────────────────────────────────────────
  static const Color primary = Color(0xFF4318FF);
  static const Color secondary = Color(0xFF39B8FF);
  static const Color accent = Color(0xFF05CD99);

  // ──────────────────────────────────────────────
  // Text Colors
  // ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1B2559);
  static const Color textSecondary = Color(0xFFA3AED0);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2B3674);
  static const Color textDisabled = Color(0xFFBCC5D3);

  // ──────────────────────────────────────────────
  // Background Colors
  // ──────────────────────────────────────────────
  static const Color light = Color(0xFFF4F7FE);
  static const Color dark = Color(0xFF0B1437);
  static const Color primaryBackground = Color(0xFFF4F7FE);
  static const Color secondaryBackground = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF111C44);
  static const Color darkCardBackground = Color(0xFF1B254B);
  static const Color lightBackground = Color(0xFFF4F7FE);

  // ──────────────────────────────────────────────
  // Seat Status Colors
  // ──────────────────────────────────────────────
  static const Color seatAvailable = Color(0xFF05CD99);
  static const Color seatOccupied = Color(0xFFFF4C61);
  static const Color seatExpiringSoon = Color(0xFFFFC837);
  static const Color seatMaintenance = Color(0xFFFF8A00);
  static const Color seatReserved = Color(0xFF868CFF);

  // ──────────────────────────────────────────────
  // Status Colors
  // ──────────────────────────────────────────────
  static const Color success = Color(0xFF05CD99);
  static const Color warning = Color(0xFFFFC837);
  static const Color error = Color(0xFFFF4C61);
  static const Color info = Color(0xFF39B8FF);

  // ──────────────────────────────────────────────
  // Border Colors
  // ──────────────────────────────────────────────
  static const Color borderPrimary = Color(0xFFE0E5F2);
  static const Color borderSecondary = Color(0xFFF4F7FE);
  static const Color borderDark = Color(0xFF2B3674);

  // ──────────────────────────────────────────────
  // Neutral Shades
  // ──────────────────────────────────────────────
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF4F4F4F);
  static const Color softGrey = Color(0xFFBDBDBD);
  static const Color lightGrey = Color(0xFFF5F5F5);

  // ──────────────────────────────────────────────
  // Dashboard Card Gradient Colors
  // ──────────────────────────────────────────────
  static const Color gradientPrimaryStart = Color(0xFF4318FF);
  static const Color gradientPrimaryEnd = Color(0xFF868CFF);

  static const Color gradientSecondaryStart = Color(0xFF39B8FF);
  static const Color gradientSecondaryEnd = Color(0xFF7BCFFF);

  static const Color gradientAccentStart = Color(0xFF05CD99);
  static const Color gradientAccentEnd = Color(0xFF61EFCD);

  static const Color gradientWarningStart = Color(0xFFFFC837);
  static const Color gradientWarningEnd = Color(0xFFFFE08A);

  static const Color gradientErrorStart = Color(0xFFFF4C61);
  static const Color gradientErrorEnd = Color(0xFFFF8F9E);

  static const Color gradientRevenueStart = Color(0xFF7551FF);
  static const Color gradientRevenueEnd = Color(0xFF39B8FF);

  // ──────────────────────────────────────────────
  // Payment Status Colors
  // ──────────────────────────────────────────────
  static const Color paymentPaid = Color(0xFF05CD99);
  static const Color paymentPending = Color(0xFFFFC837);
  static const Color paymentOverdue = Color(0xFFFF4C61);

  // ──────────────────────────────────────────────
  // Chart Colors
  // ──────────────────────────────────────────────
  static const Color chartPrimary = Color(0xFF4318FF);
  static const Color chartSecondary = Color(0xFF39B8FF);
  static const Color chartTertiary = Color(0xFF05CD99);
  static const Color chartQuaternary = Color(0xFFFFC837);
  static const Color chartQuinary = Color(0xFFFF4C61);
}
