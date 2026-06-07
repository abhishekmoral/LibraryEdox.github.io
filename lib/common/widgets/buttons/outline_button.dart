import 'package:flutter/material.dart';
import 'package:edox_library/utils/constants/sizes.dart';

/// Outlined button used throughout the app.
class XOutlineButton extends StatelessWidget {
  const XOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: XSizes.buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: XSizes.sm),
                      Text(text),
                    ],
                  )
                : Text(text),
      ),
    );
  }
}
