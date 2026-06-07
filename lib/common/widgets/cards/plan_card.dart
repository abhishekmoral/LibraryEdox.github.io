import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/features/plans/models/plan_model.dart';

/// Card displaying plan info with edit/delete actions.
class XPlanCard extends StatelessWidget {
  const XPlanCard({
    super.key,
    required this.plan,
    this.onEdit,
    this.onDelete,
  });

  final PlanModel plan;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.all(XSizes.md),
      decoration: BoxDecoration(
        color: dark ? XColors.darkCardBackground : XColors.white,
        borderRadius: BorderRadius.circular(XSizes.cardRadiusMd),
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: 0.15)
                : XColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// --- Icon
          Container(
            padding: const EdgeInsets.all(XSizes.sm + 2),
            decoration: BoxDecoration(
              color: XColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
            ),
            child: const Icon(Iconsax.calendar_1, color: XColors.primary, size: 22),
          ),
          const SizedBox(width: XSizes.sm + 4),

          /// --- Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.planName,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  plan.durationText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          /// --- Price
          Text(
            XHelperFunctions.formatCurrency(plan.price),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: XColors.primary,
                ),
          ),
          const SizedBox(width: XSizes.sm),

          /// --- Actions
          PopupMenuButton(
            icon: const Icon(Iconsax.more, size: 20),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: onEdit,
                child: const Row(
                  children: [
                    Icon(Iconsax.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: onDelete,
                child: const Row(
                  children: [
                    Icon(Iconsax.trash, size: 18, color: XColors.error),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: XColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
