import 'package:flutter/material.dart';

/// Custom Outlined Button themes for the EdoxLibrary application.
class XOutlinedButtonTheme {
  XOutlinedButtonTheme._();

  /// Light mode outlined button theme
  static final OutlinedButtonThemeData lightOutlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4318FF),
          backgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.grey,
          side: const BorderSide(color: Color(0xFF4318FF), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          minimumSize: const Size(double.infinity, 48),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  /// Dark mode outlined button theme
  static final OutlinedButtonThemeData darkOutlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.grey,
          side: const BorderSide(color: Color(0xFF677DCD), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          minimumSize: const Size(double.infinity, 48),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}
