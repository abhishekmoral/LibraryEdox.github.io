import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/features/payments/models/payment_model.dart';

/// Card displaying payment info.
class XPaymentCard extends StatelessWidget {
  const XPaymentCard({
    super.key,
    required this.payment,
    this.onTap,
  });

  final PaymentModel payment;
  final VoidCallback? onTap;

  IconData get _methodIcon {
    switch (payment.paymentMethod) {
      case 'upi':
        return Iconsax.mobile;
      case 'bank_transfer':
        return Iconsax.bank;
      case 'cash':
      default:
        return Iconsax.money_recive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: XColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
              ),
              child: Icon(_methodIcon, color: XColors.accent, size: 22),
            ),
            const SizedBox(width: XSizes.sm + 4),

            /// --- Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.memberName,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${payment.planName} • ${payment.paymentMethod.replaceAll('_', ' ').toUpperCase()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            /// --- Amount + Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  XHelperFunctions.formatCurrency(payment.amount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: XColors.accent,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  XHelperFunctions.formatDate(payment.date),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
