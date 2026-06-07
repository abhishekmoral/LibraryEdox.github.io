import 'package:flutter/material.dart';

/// Custom Bottom Sheet themes for the EdoxLibrary application.
class XBottomSheetTheme {
  XBottomSheetTheme._();

  /// Light mode bottom sheet theme
  static const BottomSheetThemeData lightBottomSheetTheme =
      BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        dragHandleColor: Color(0xFFE0E5F2),
        constraints: BoxConstraints(minWidth: double.infinity),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      );

  /// Dark mode bottom sheet theme
  static const BottomSheetThemeData darkBottomSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: Color(0xFF111C44),
    modalBackgroundColor: Color(0xFF111C44),
    dragHandleColor: Color(0xFF1B254B),
    constraints: BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
  );
}
