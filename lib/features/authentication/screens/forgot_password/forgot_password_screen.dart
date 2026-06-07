import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/constants/text_strings.dart';
import 'package:edox_library/utils/validators/validation.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isLoading = false.obs;

    return Scaffold(
      appBar: const XAppBar(title: Text(''), showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(XSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- Header Icon
              Container(
                padding: const EdgeInsets.all(XSizes.md),
                decoration: BoxDecoration(
                  color: XColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Iconsax.lock_1, color: XColors.primary, size: 32),
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Title
              Text(
                XTexts.xForgotPassword,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: XSizes.sm),
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: XSizes.spaceBtwSections),

              /// --- Form
              Form(
                key: formKey,
                child: Column(
                  children: [
                    XTextField(
                      controller: emailController,
                      label: XTexts.xEmail,
                      hint: 'Enter your registered email',
                      prefixIcon: Iconsax.direct_right,
                      keyboardType: TextInputType.emailAddress,
                      validator: XValidator.validateEmail,
                    ),
                    const SizedBox(height: XSizes.spaceBtwSections),
                    Obx(
                      () => XPrimaryButton(
                        text: 'Send Reset Link',
                        isLoading: isLoading.value,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            isLoading.value = true;
                            Future.delayed(const Duration(seconds: 1), () {
                              isLoading.value = false;
                              Get.back();
                              Get.snackbar(
                                'Email Sent',
                                'Password reset link has been sent to your email.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: XColors.accent,
                                colorText: XColors.white,
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
