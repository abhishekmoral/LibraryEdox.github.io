import 'package:flutter/material.dart';

/// Custom TextFormField themes for the EdoxLibrary application.
class XTextFormFieldTheme {
  XTextFormFieldTheme._();

  /// Light mode input decoration theme
  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: const Color(0xFFA3AED0),
    suffixIconColor: const Color(0xFFA3AED0),
    filled: true,
    fillColor: const Color(0xFFF4F7FE),
    hintStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFFA3AED0),
    ),
    errorStyle: const TextStyle(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle(
      color: Color(0xFF4318FF),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 1, color: Color(0xFFE0E5F2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 1, color: Color(0xFFE0E5F2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 2, color: Color(0xFF4318FF)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 1, color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 2, color: Colors.orange),
    ),
  );

  /// Dark mode input decoration theme
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: const Color(0xFF677DCD),
    suffixIconColor: const Color(0xFF677DCD),
    filled: true,
    fillColor: const Color(0xFF111C44),
    hintStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFF677DCD),
    ),
    errorStyle: const TextStyle(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle(
      color: Color(0xFF7551FF),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 1, color: Color(0xFF1B254B)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 1, color: Color(0xFF1B254B)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 2, color: Color(0xFF4318FF)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 1, color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 2, color: Colors.orange),
    ),
  );
}
