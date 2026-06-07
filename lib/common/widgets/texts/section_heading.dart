import 'package:flutter/material.dart';

/// Section heading with optional action button.
class XSectionHeading extends StatelessWidget {
  const XSectionHeading({
    super.key,
    required this.title,
    this.showActionButton = false,
    this.actionText = 'View All',
    this.onActionPressed,
  });

  final String title;
  final bool showActionButton;
  final String actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (showActionButton)
          TextButton(
            onPressed: onActionPressed,
            child: Text(actionText),
          ),
      ],
    );
  }
}
