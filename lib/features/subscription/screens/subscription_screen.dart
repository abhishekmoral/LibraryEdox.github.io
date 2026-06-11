import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edox_library/features/subscription/controllers/razorpay_controller.dart';
import 'package:edox_library/features/subscription/controllers/subscription_cubit.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    RazorpayService.instance.init();
  }

  @override
  void dispose() {
    RazorpayService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: const XAppBar(title: Text('Subscription')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(XSizes.defaultSpace),
        child: Column(
          children: [
            /// --- Current Plan
            BlocBuilder<SubscriptionCubit, SubscriptionState>(
              builder: (context, subState) {
                String planName = 'Loading...';
                String subtitle = 'Checking subscription...';
                String statusText = 'Unknown';
                Color statusBgColor = XColors.white.withValues(alpha: 0.2);
                Color statusTextColor = XColors.white;

                if (subState is SubscriptionLoaded) {
                  final sub = subState.subscription;
                  planName = '${sub.planName} Plan';
                  if (sub.isActive) {
                    subtitle = '${sub.daysRemaining} days remaining';
                    statusText = 'Active';
                    statusBgColor = const Color(0xFF05CD99); // Active green
                  } else {
                    subtitle = 'Your plan has expired';
                    statusText = 'Expired';
                    statusBgColor = const Color(0xFFFF4C61); // Expired red
                  }
                } else if (subState is SubscriptionFailure) {
                  planName = 'Error';
                  subtitle = subState.message;
                  statusText = 'Failed';
                  statusBgColor = XColors.error;
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(XSizes.defaultSpace),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [XColors.primary, Color(0xFF7B5AFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(XSizes.cardRadiusLg),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: XColors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: const Icon(Iconsax.crown_1, color: XColors.white, size: 28),
                      ),
                      const SizedBox(height: XSizes.sm),
                      Text(planName, style: const TextStyle(color: XColors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(color: XColors.white.withValues(alpha: 0.8), fontSize: 14)),
                      const SizedBox(height: XSizes.spaceBtwItems),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(20)),
                        child: Text(statusText, style: TextStyle(color: statusTextColor, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: XSizes.spaceBtwSections),

            /// --- Plans
            Text('Upgrade Your Plan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: XSizes.spaceBtwItems),

            _PlanTile(
              title: 'Basic',
              price: '₹499/mo',
              features: const [
                'Unlimited seats',
                'Unlimited members',
                'WhatsApp & SMS reminders',
                'Advanced analytics',
                'Advanced seat layout',
                'Premium 24/7 support',
              ],
              color: XColors.accent,
              dark: dark,
              onSelect: () => RazorpayService.instance.openCheckout(context, 'Basic', 499.0),
            ),
            const SizedBox(height: XSizes.spaceBtwItems),

            _PlanTile(
              title: 'Premium',
              price: '₹999 for 90 days',
              features: const [
                'Unlimited seats',
                'Unlimited members',
                'WhatsApp & SMS reminders',
                'Advanced analytics',
                'Advanced seat layout',
                'Premium 24/7 support',
              ],
              color: XColors.primary,
              dark: dark,
              recommended: true,
              onSelect: () => RazorpayService.instance.openCheckout(context, 'Premium', 999.0),
            ),
            const SizedBox(height: XSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.title, required this.price, required this.features, required this.color, required this.dark, this.recommended = false, this.onSelect});
  final String title; final String price; final List<String> features; final Color color; final bool dark; final bool recommended; final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(XSizes.md),
      decoration: BoxDecoration(
        color: dark ? XColors.darkCardBackground : XColors.white,
        borderRadius: BorderRadius.circular(XSizes.cardRadiusLg),
        border: recommended ? Border.all(color: color, width: 2) : null,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
              if (recommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('RECOMMENDED', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(price, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: XSizes.spaceBtwItems),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Iconsax.tick_circle, size: 16, color: color),
                const SizedBox(width: 8),
                Text(f, style: const TextStyle(fontSize: 13)),
              ],
            ),
          )),
          const SizedBox(height: XSizes.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(backgroundColor: color),
              child: Text('Select $title'),
            ),
          ),
        ],
      ),
    );
  }
}
