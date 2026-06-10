import 'package:flutter/material.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/common/widgets/buttons/outline_button.dart';

/// Confirmation dialog.
class XConfirmDialog {
  XConfirmDialog._();

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Yes',
    String cancelText = 'No',
    Color? confirmColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(XSizes.cardRadiusLg),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          XOutlineButton(
            text: cancelText,
            width: 100,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: XSizes.sm),
          SizedBox(
            width: 100,
            height: XSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor ?? XColors.primary,
              ),
              child: Text(confirmText),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.all(XSizes.md),
      ),
    );
  }
}
