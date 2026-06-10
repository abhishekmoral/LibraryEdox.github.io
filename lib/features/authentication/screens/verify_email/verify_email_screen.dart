import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(XSizes.defaultSpace),
          child: Column(
            children: [
              const SizedBox(height: 80),

              /// --- Icon
              Container(
                padding: const EdgeInsets.all(XSizes.xl),
                decoration: BoxDecoration(
                  color: XColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.direct_right,
                  color: XColors.primary,
                  size: 60,
                ),
              ),
              const SizedBox(height: XSizes.spaceBtwSections),

              /// --- Title
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: XSizes.sm),
              Text(
                email ?? 'your@email.com',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: XColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: XSizes.spaceBtwItems),
              Text(
                'We\'ve sent a verification link to your email address. Please check your inbox and click the link to verify your account.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: XSizes.spaceBtwSections),

              /// --- Continue Button
              XPrimaryButton(
                text: 'Continue',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Resend
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification email has been resent.'),
                      backgroundColor: XColors.accent,
                    ),
                  );
                },
                child: const Text('Resend Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
