import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edox_library/utils/constants/colors.dart';

/// Full-screen loader overlay.
class XLoader {
  XLoader._();

  /// Show loading dialog.
  static void show({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? XColors.darkCardBackground : XColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: XColors.primary),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: Get.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide loading dialog.
  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
