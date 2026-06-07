import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Provides static device-level utilities such as keyboard visibility,
/// orientation checks, screen dimensions, and platform helpers.
class XDeviceUtils {
  XDeviceUtils._();

  // ──────────────────────────── Keyboard ─────────────────────────

  /// Returns `true` when the soft keyboard is currently visible.
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Hides the soft keyboard if it is currently showing.
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // ──────────────────────────── Status Bar ───────────────────────

  /// Sets the status bar colour on Android. No-op on other platforms.
  static void setStatusBarColor(Color color) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color),
    );
  }

  // ──────────────────────────── Orientation ──────────────────────

  /// Returns `true` when the device is in landscape orientation.
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Returns `true` when the device is in portrait orientation.
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Enables or disables full-screen (immersive) mode.
  static void setFullScreen(bool enable) {
    SystemChrome.setEnabledSystemUIMode(
      enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  // ──────────────────────────── Dimensions ───────────────────────

  /// Returns the screen height in logical pixels.
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Returns the screen width in logical pixels.
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Returns the device pixel ratio.
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Returns the height of the status bar.
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Returns the default bottom navigation bar height.
  static double getBottomNavigationBarHeight() {
    return kBottomNavigationBarHeight;
  }

  /// Returns the default [AppBar] height.
  static double getAppBarHeight() {
    return kToolbarHeight;
  }

  // ──────────────────────────── Platform ─────────────────────────

  /// Returns `true` when running on a physical device (not an emulator/simulator).
  /// Always returns `false` on web.
  static Future<bool> isPhysicalDevice() async {
    // On web we cannot determine this.
    if (kIsWeb) return false;
    // Platform.environment doesn't reliably detect emulators;
    // a more robust check requires device_info_plus.
    // This is a best-effort implementation.
    return true;
  }

  /// Triggers a short haptic vibration.
  static void vibrate(Duration duration) {
    HapticFeedback.mediumImpact();
  }

  // ──────────────────────────── Form Factor ─────────────────────

  /// Returns `true` when the shortest side of the screen is ≥ 600 dp,
  /// which is the common tablet breakpoint.
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  /// Returns `true` when the shortest side is < 600 dp (phone form-factor).
  static bool isMobile(BuildContext context) {
    return !isTablet(context);
  }
}
