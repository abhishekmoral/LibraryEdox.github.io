import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';

/// Empty state widget with icon, title, subtitle, and action.
class XEmptyState extends StatelessWidget {
  const XEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Iconsax.document,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(XSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: XColors.softGrey),
            const SizedBox(height: XSizes.spaceBtwItems),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: XColors.darkGrey,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: XSizes.sm),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: XColors.softGrey,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: XSizes.spaceBtwSections),
              XPrimaryButton(
                text: actionText!,
                onPressed: onAction,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
