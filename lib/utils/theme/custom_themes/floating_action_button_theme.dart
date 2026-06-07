import 'package:flutter/material.dart';

/// Custom Floating Action Button themes for the EdoxLibrary application.
class XFloatingActionButtonTheme {
  XFloatingActionButtonTheme._();

  /// Light mode FAB theme
  static const FloatingActionButtonThemeData lightFloatingActionButtonTheme =
      FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF4318FF),
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        splashColor: Color(0xFF7551FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      );

  /// Dark mode FAB theme
  static const FloatingActionButtonThemeData darkFloatingActionButtonTheme =
      FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF4318FF),
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        splashColor: Color(0xFF7551FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      );
}
