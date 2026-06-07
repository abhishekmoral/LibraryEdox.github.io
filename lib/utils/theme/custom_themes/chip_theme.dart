import 'package:flutter/material.dart';

/// Custom Chip themes for the EdoxLibrary application.
class XChipTheme {
  XChipTheme._();

  /// Light mode chip theme
  static const ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: Color(0xFFE0E5F2),
    labelStyle: TextStyle(color: Color(0xFF2B3674), fontSize: 14),
    selectedColor: Color(0xFF4318FF),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: Colors.white,
    backgroundColor: Color(0xFFF4F7FE),
    secondarySelectedColor: Color(0xFF4318FF),
    secondaryLabelStyle: TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      side: BorderSide(color: Color(0xFFE0E5F2)),
    ),
  );

  /// Dark mode chip theme
  static const ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: Color(0xFF1B254B),
    labelStyle: TextStyle(color: Color(0xFFE0E5F2), fontSize: 14),
    selectedColor: Color(0xFF4318FF),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: Colors.white,
    backgroundColor: Color(0xFF111C44),
    secondarySelectedColor: Color(0xFF4318FF),
    secondaryLabelStyle: TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      side: BorderSide(color: Color(0xFF1B254B)),
    ),
  );
}
