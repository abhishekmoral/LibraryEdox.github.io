import 'package:flutter/material.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';

/// Full-screen loader overlay.
class XLoader {
  XLoader._();

  static BuildContext? _dialogContext;

  /// Show loading dialog.
  static void show({String? message}) {
    final context = XHelperFunctions.navigatorKey.currentContext;
    if (context == null) return;

    // Hide any existing loader first
    hide();

    final dark = XHelperFunctions.isDarkMode(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        _dialogContext = dialogCtx;
        return PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: dark ? XColors.darkCardBackground : XColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: XColors.primary),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Material(
                      color: Colors.transparent,
                      child: Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Hide loading dialog.
  static void hide() {
    if (_dialogContext != null) {
      final context = _dialogContext;
      _dialogContext = null;
      try {
        Navigator.of(context!).pop();
      } catch (_) {
        // Dialog might have already been popped
      }
    }
  }
}
