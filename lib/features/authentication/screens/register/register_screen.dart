import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/constants/text_strings.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/utils/validators/validation.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';
import 'package:edox_library/features/authentication/screens/verify_email/verify_email_screen.dart';
import 'package:edox_library/features/authentication/controllers/register/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
                  child: SizedBox(width: 500, child: _RegisterContent()),
                );
              }
              return _RegisterContent();
            },
          ),
        ),
      ),
    );
  }
}

class _RegisterContent extends StatelessWidget {
  _RegisterContent();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());
    final dark = XHelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),

        /// --- Back Button
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new),
          style: IconButton.styleFrom(
            backgroundColor: dark ? XColors.darkCardBackground : XColors.lightBackground,
          ),
        ),
        const SizedBox(height: XSizes.spaceBtwItems),

        /// --- Header
        Text(
          XTexts.xRegisterTitle,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: XSizes.sm),
        Text(
          XTexts.xRegisterSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: XSizes.spaceBtwSections),

        /// --- Form
        Form(
          key: controller.registerFormKey,
          child: Column(
            children: [
              XTextField(
                controller: controller.libraryNameController,
                label: XTexts.xLibraryName,
                hint: 'Enter your library name',
                prefixIcon: Iconsax.building,
                validator: (v) => XValidator.validateEmptyText(XTexts.xLibraryName, v),
              ),
              const SizedBox(height: XSizes.spaceBtwItems),
              XTextField(
                controller: controller.ownerNameController,
                label: XTexts.xOwnerName,
                hint: 'Enter owner full name',
                prefixIcon: Iconsax.user,
                validator: XValidator.validateName,
              ),
              const SizedBox(height: XSizes.spaceBtwItems),
              XTextField(
                controller: controller.mobileController,
                label: XTexts.xMobileNumber,
                hint: 'Enter 10-digit mobile number',
                prefixIcon: Iconsax.call,
                keyboardType: TextInputType.phone,
                validator: XValidator.validatePhone,
              ),
              const SizedBox(height: XSizes.spaceBtwItems),
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
                  hint: 'Create a strong password',
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
              const SizedBox(height: XSizes.spaceBtwItems),
              XTextField(
                controller: controller.addressController,
                label: XTexts.xAddress,
                hint: 'Enter library address',
                prefixIcon: Iconsax.location,
                maxLines: 2,
                validator: XValidator.validateAddress,
              ),
              const SizedBox(height: XSizes.spaceBtwSections),

              /// --- Register Button
              Obx(
                () => XPrimaryButton(
                  text: XTexts.xCreateAccount,
                  isLoading: controller.isLoading.value,
                  onPressed: () => controller.register(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: XSizes.spaceBtwSections),

        /// --- Login Link
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                XTexts.xAlreadyHaveAccount,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  XTexts.xLogin,
                  style: TextStyle(
                    color: XColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: XSizes.spaceBtwItems),
      ],
    );
  }
}
