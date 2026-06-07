import 'package:flutter/material.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';

/// Dashboard stat card with icon, value, and title.
class XDashboardCard extends StatelessWidget {
  const XDashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.gradient,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(XSizes.md),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null
              ? (dark ? XColors.darkCardBackground : XColors.white)
              : null,
          borderRadius: BorderRadius.circular(XSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.black.withValues(alpha: 0.2)
                  : XColors.primary.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// --- Icon
            Container(
              padding: const EdgeInsets.all(XSizes.sm + 2),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
              ),
              child: Icon(icon, color: iconColor, size: XSizes.iconMd),
            ),
            const SizedBox(height: XSizes.sm),

            /// --- Value
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: gradient != null ? XColors.white : null,
                  ),
            ),
            const SizedBox(height: 2),

            /// --- Title
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: gradient != null
                        ? XColors.white.withValues(alpha: 0.8)
                        : null,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
