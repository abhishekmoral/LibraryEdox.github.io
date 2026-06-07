import 'package:flutter/material.dart';
import 'package:edox_library/utils/constants/sizes.dart';

/// Small colored badge for status display.
class XStatusBadge extends StatelessWidget {
  const XStatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.textColor,
  });

  final String text;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: XSizes.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(XSizes.borderRadiusSm + 2),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor ?? color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
