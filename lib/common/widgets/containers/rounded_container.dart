import 'package:flutter/material.dart';
import 'package:edox_library/utils/constants/sizes.dart';

/// Rounded container with optional border.
class XRoundedContainer extends StatelessWidget {
  const XRoundedContainer({
    super.key,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.child,
    this.showBorder = false,
    this.radius = XSizes.cardRadiusLg,
    this.backgroundColor,
    this.borderColor,
  });

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final bool showBorder;
  final double radius;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(XSizes.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: showBorder
            ? Border.all(color: borderColor ?? Theme.of(context).dividerColor)
            : null,
      ),
      child: child,
    );
  }
}
