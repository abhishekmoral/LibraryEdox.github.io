import 'package:flutter/material.dart';

/// Custom Card themes for the EdoxLibrary application.
class XCardTheme {
  XCardTheme._();

  /// Light mode card theme
  static const CardThemeData lightCardTheme = CardThemeData(
    color: Colors.white,
    shadowColor: Color(0x0F4318FF),
    surfaceTintColor: Colors.transparent,
    elevation: 2,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );

  /// Dark mode card theme
  static const CardThemeData darkCardTheme = CardThemeData(
    color: Color(0xFF111C44),
    shadowColor: Color(0x1A000000),
    surfaceTintColor: Colors.transparent,
    elevation: 2,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );
}
