import 'package:flutter/material.dart';
import 'package:edox_library/utils/theme/custom_themes/appbar_theme.dart';
import 'package:edox_library/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:edox_library/utils/theme/custom_themes/card_theme.dart';
import 'package:edox_library/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:edox_library/utils/theme/custom_themes/chip_theme.dart';
import 'package:edox_library/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:edox_library/utils/theme/custom_themes/floating_action_button_theme.dart';
import 'package:edox_library/utils/theme/custom_themes/navigation_bar_theme.dart';
import 'package:edox_library/utils/theme/custom_themes/outlined_button_theme.dart';
import 'package:edox_library/utils/theme/custom_themes/text_field_theme.dart';
import 'package:edox_library/utils/theme/custom_themes/text_theme.dart';

/// Main app theme configuration for the EdoxLibrary application.
///
/// Provides Material 3 [ThemeData] for both light and dark modes with
/// a modern SaaS-style color palette (deep purple-blue primary, soft backgrounds).
class XAppTheme {
  XAppTheme._();

  /// Light theme configuration
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: const Color(0xFF4318FF),
    scaffoldBackgroundColor: const Color(0xFFF4F7FE),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF4318FF),
      secondary: Color(0xFF39B8FF),
      surface: Colors.white,
      error: Color(0xFFE53E3E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1B2559),
      onError: Colors.white,
    ),
    textTheme: XTextTheme.lightTextTheme,
    appBarTheme: XAppBarTheme.lightAppBarTheme,
    elevatedButtonTheme: XElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: XOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: XTextFormFieldTheme.lightInputDecorationTheme,
    bottomSheetTheme: XBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: XCheckBoxTheme.lightCheckboxTheme,
    chipTheme: XChipTheme.lightChipTheme,
    cardTheme: XCardTheme.lightCardTheme,
    floatingActionButtonTheme:
        XFloatingActionButtonTheme.lightFloatingActionButtonTheme,
    navigationBarTheme: XNavigationBarTheme.lightNavigationBarTheme,
  );

  /// Dark theme configuration
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF4318FF),
    scaffoldBackgroundColor: const Color(0xFF0B1437),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4318FF),
      secondary: Color(0xFF39B8FF),
      surface: Color(0xFF111C44),
      error: Color(0xFFFC5A5A),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    textTheme: XTextTheme.darkTextTheme,
    appBarTheme: XAppBarTheme.darkAppBarTheme,
    elevatedButtonTheme: XElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: XOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: XTextFormFieldTheme.darkInputDecorationTheme,
    bottomSheetTheme: XBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme: XCheckBoxTheme.darkCheckboxTheme,
    chipTheme: XChipTheme.darkChipTheme,
    cardTheme: XCardTheme.darkCardTheme,
    floatingActionButtonTheme:
        XFloatingActionButtonTheme.darkFloatingActionButtonTheme,
    navigationBarTheme: XNavigationBarTheme.darkNavigationBarTheme,
  );
}
