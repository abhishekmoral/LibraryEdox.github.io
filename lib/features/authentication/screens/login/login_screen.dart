import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/constants/text_strings.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/utils/validators/validation.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';
import 'package:edox_library/features/authentication/screens/register/register_screen.dart';
import 'package:edox_library/features/authentication/screens/forgot_password/forgot_password_screen.dart';
import 'package:edox_library/features/authentication/controllers/login/login_controller.dart';
import 'package:iconsax/iconsax.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(XSizes.defaultSpace),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Center(
                  child: SizedBox(width: 500, child: _LoginContent()),
                );
              }
              return _LoginContent();
            },
          ),
        ),
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  _LoginContent();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final dark = XHelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),

        /// --- Logo & Header
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [XColors.primary, Color(0xFF7B5AFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: XColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Iconsax.book_1, color: XColors.white, size: 40),
          ),
        ),
        const SizedBox(height: XSizes.spaceBtwItems),
        Center(
          child: Text(
            XTexts.xAppName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: XColors.primary,
                ),
          ),
        ),
        const SizedBox(height: XSizes.spaceBtwSections + 8),

        /// --- Title
        Text(
          XTexts.xLoginTitle,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: XSizes.sm),
        Text(
          XTexts.xLoginSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: XSizes.spaceBtwSections),

        /// --- Form
        Form(
          key: controller.loginFormKey,
          child: Column(
            children: [
              XTextField(
                controller: controller.emailController,
                label: XTexts.xEmail,
                hint: 'Enter your email',
                prefixIcon: Iconsax.direct_right,
                keyboardType: TextInputType.emailAddress,
                validator: XValidator.validateEmail,
              ),
              const SizedBox(height: XSizes.spaceBtwItems),
              Obx(
                () => XTextField(
                  controller: controller.passwordController,
                  label: XTexts.xPassword,
                  hint: 'Enter your password',
                  prefixIcon: Iconsax.password_check,
                  obscureText: controller.hidePassword.value,
                  validator: XValidator.validatePassword,
                  suffixIcon: IconButton(
                    onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                    icon: Icon(
                      controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: XSizes.sm),

              /// --- Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.to(() => const ForgotPasswordScreen()),
                  child: const Text(XTexts.xForgotPassword),
                ),
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Login Button
              Obx(
                () => XPrimaryButton(
                  text: XTexts.xLogin,
                  isLoading: controller.isLoading.value,
                  onPressed: () => controller.login(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: XSizes.spaceBtwSections),

        /// --- Divider
        Row(
          children: [
            Expanded(child: Divider(color: dark ? XColors.darkGrey : XColors.softGrey)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: XSizes.sm),
              child: Text('Or', style: Theme.of(context).textTheme.bodySmall),
            ),
            Expanded(child: Divider(color: dark ? XColors.darkGrey : XColors.softGrey)),
          ],
        ),
        const SizedBox(height: XSizes.spaceBtwSections),

        /// --- Register Link
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                XTexts.xDontHaveAccount,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => Get.to(() => const RegisterScreen()),
                child: const Text(
                  XTexts.xRegister,
                  style: TextStyle(
                    color: XColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
