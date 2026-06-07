import 'package:flutter/material.dart';

/// Custom Elevated Button themes for the EdoxLibrary application.
class XElevatedButtonTheme {
  XElevatedButtonTheme._();

  /// Light mode elevated button theme
  static final ElevatedButtonThemeData lightElevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF4318FF),
          disabledForegroundColor: Colors.grey,
          disabledBackgroundColor: Colors.grey.shade300,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          minimumSize: const Size(double.infinity, 48),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  /// Dark mode elevated button theme
  static final ElevatedButtonThemeData darkElevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF4318FF),
          disabledForegroundColor: Colors.grey,
          disabledBackgroundColor: Colors.grey.shade800,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          minimumSize: const Size(double.infinity, 48),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}
