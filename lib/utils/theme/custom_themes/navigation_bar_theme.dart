import 'package:flutter/material.dart';

/// Custom Navigation Bar themes for the EdoxLibrary application.
class XNavigationBarTheme {
  XNavigationBarTheme._();

  /// Light mode navigation bar theme
  static const NavigationBarThemeData lightNavigationBarTheme =
      NavigationBarThemeData(
        height: 70,
        elevation: 3,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Color(0xFF4318FF),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(size: 24, color: Color(0xFFA3AED0)),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2B3674),
          ),
        ),
      );

  /// Dark mode navigation bar theme
  static const NavigationBarThemeData darkNavigationBarTheme =
      NavigationBarThemeData(
        height: 70,
        elevation: 3,
        backgroundColor: Color(0xFF0B1437),
        surfaceTintColor: Colors.transparent,
        indicatorColor: Color(0x664318FF),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(size: 24, color: Color(0xFF677DCD)),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFFE0E5F2),
          ),
        ),
      );
}
