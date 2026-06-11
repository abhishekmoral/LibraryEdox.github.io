import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/subscription/controllers/razorpay_controller.dart';

class PlanExpiredScreen extends StatefulWidget {
  const PlanExpiredScreen({super.key});

  @override
  State<PlanExpiredScreen> createState() => _PlanExpiredScreenState();
}

class _PlanExpiredScreenState extends State<PlanExpiredScreen> {
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
      backgroundColor: dark ? const Color(0xFF0B1437) : XColors.light,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: XSizes.defaultSpace, vertical: XSizes.spaceBtwSections),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Warning icon & expired message block
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: XColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.warning_2,
                  color: XColors.error,
                  size: 48,
                ),
              ),
              const SizedBox(height: XSizes.spaceBtwItems),
              
              Text(
                'Plan Expired',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dark ? XColors.white : XColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Your plan is expired. If you want to continue, you need to buy a plan.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: dark ? XColors.softGrey : XColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const SizedBox(height: XSizes.spaceBtwSections),

              // Plan options
              Text(
                'Select a Plan to Continue',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dark ? XColors.white : XColors.textPrimary,
                    ),
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              _PlanCard(
                title: 'Basic Plan',
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
                onTap: () => RazorpayService.instance.openCheckout(context, 'Basic', 499.0),
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              _PlanCard(
                title: 'Premium Plan',
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
                onTap: () => RazorpayService.instance.openCheckout(context, 'Premium', 999.0),
              ),
              const SizedBox(height: XSizes.spaceBtwSections),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: XSizes.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthenticationRepository.instance.logout();
                  },
                  icon: const Icon(Iconsax.logout, color: XColors.error),
                  label: const Text('Logout & Switch Account', style: TextStyle(color: XColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: XColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(XSizes.borderRadiusLg)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.features,
    required this.color,
    required this.dark,
    this.recommended = false,
    required this.onTap,
  });

  final String title;
  final String price;
  final List<String> features;
  final Color color;
  final bool dark;
  final bool recommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(XSizes.md),
      decoration: BoxDecoration(
        color: dark ? XColors.darkCardBackground : XColors.white,
        borderRadius: BorderRadius.circular(XSizes.cardRadiusLg),
        border: recommended ? Border.all(color: color, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              if (recommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'RECOMMENDED',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: XSizes.spaceBtwItems),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Iconsax.tick_circle, size: 16, color: color),
                    const SizedBox(width: 8),
                    Text(
                      f,
                      style: TextStyle(
                        fontSize: 13,
                        color: dark ? XColors.white : XColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: XSizes.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Buy $title'),
            ),
          ),
        ],
      ),
    );
  }
}
