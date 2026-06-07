import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';

/// Shimmer loading effect wrapper.
class XShimmerLoader extends StatelessWidget {
  const XShimmerLoader({
    super.key,
    this.width = double.infinity,
    this.height = 80,
    this.radius = 12,
    this.child,
  });

  final double width;
  final double height;
  final double radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);
    return Shimmer.fromColors(
      baseColor: dark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: dark ? Colors.grey[700]! : Colors.grey[100]!,
      child: child ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: dark ? XColors.darkCardBackground : XColors.white,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
    );
  }
}
