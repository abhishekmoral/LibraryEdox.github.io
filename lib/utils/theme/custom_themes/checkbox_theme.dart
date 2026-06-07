import 'package:flutter/material.dart';

/// Custom Checkbox themes for the EdoxLibrary application.
class XCheckBoxTheme {
  XCheckBoxTheme._();

  /// Light mode checkbox theme
  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.black;
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF4318FF);
      }
      return Colors.transparent;
    }),
    side: const BorderSide(color: Color(0xFFA3AED0), width: 1.5),
  );

  /// Dark mode checkbox theme
  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.white;
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF4318FF);
      }
      return Colors.transparent;
    }),
    side: const BorderSide(color: Color(0xFF677DCD), width: 1.5),
  );
}
