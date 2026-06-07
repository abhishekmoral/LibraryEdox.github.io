import 'package:flutter/material.dart';

/// Custom AppBar themes for the EdoxLibrary application.
class XAppBarTheme {
  XAppBarTheme._();

  /// Light mode AppBar theme
  static const AppBarTheme lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Color(0xFF1B2559), size: 24),
    actionsIconTheme: IconThemeData(color: Color(0xFF1B2559), size: 24),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1B2559),
      fontFamily: 'Poppins',
    ),
  );

  /// Dark mode AppBar theme
  static const AppBarTheme darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.white, size: 24),
    actionsIconTheme: IconThemeData(color: Colors.white, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontFamily: 'Poppins',
    ),
  );
}
