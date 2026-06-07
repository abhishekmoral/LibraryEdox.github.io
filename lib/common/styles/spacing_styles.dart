import 'package:flutter/material.dart';

/// Reusable [EdgeInsetsGeometry] presets used for consistent spacing
/// across the EdoxLibrary application.
class XSpacingStyle {
  XSpacingStyle._();

  /// Padding that accounts for the AppBar height at the top,
  /// with standard horizontal and bottom padding.
  /// Useful for screens that do **not** have an AppBar but need
  /// equivalent top spacing.
  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
    top: kToolbarHeight + 24,
    left: 24,
    right: 24,
    bottom: 24,
  );

  /// Default page-level padding — 24 dp on all sides.
  static const EdgeInsetsGeometry defaultPadding = EdgeInsets.all(24);

  /// Padding used around major sections within a page.
  static const EdgeInsetsGeometry sectionPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 16,
  );

  /// Inner padding for card widgets.
  static const EdgeInsetsGeometry cardPadding = EdgeInsets.all(16);
}
