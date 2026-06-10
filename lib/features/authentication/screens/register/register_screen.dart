import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/constants/text_strings.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/utils/validators/validation.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';
import 'package:edox_library/features/authentication/controllers/register/register_cubit.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(XSizes.defaultSpace),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Center(
                    child: SizedBox(width: 500, child: const _RegisterContent()),
                  );
                }
                return const _RegisterContent();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterContent extends StatefulWidget {
  const _RegisterContent();

  @override
  State<_RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<_RegisterContent> {
  final libraryNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();
  final registerFormKey = GlobalKey<FormState>();
  bool hidePassword = true;

  @override
  void dispose() {
    libraryNameController.dispose();
    ownerNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: XColors.error,
            ),
          );
        } else if (state is RegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your account has been created successfully.'),
              backgroundColor: XColors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is RegisterLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            /// --- Back Button
            IconButton(
              onPressed: () => Navigator.pop(context),
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
              key: registerFormKey,
              child: Column(
                children: [
                  XTextField(
                    controller: libraryNameController,
                    label: XTexts.xLibraryName,
                    hint: 'Enter your library name',
                    prefixIcon: Iconsax.building,
                    validator: (v) => XValidator.validateEmptyText(XTexts.xLibraryName, v),
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(
                    controller: ownerNameController,
                    label: XTexts.xOwnerName,
                    hint: 'Enter owner full name',
                    prefixIcon: Iconsax.user,
                    validator: XValidator.validateName,
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(
                    controller: mobileController,
                    label: XTexts.xMobileNumber,
                    hint: 'Enter 10-digit mobile number',
                    prefixIcon: Iconsax.call,
                    keyboardType: TextInputType.phone,
                    validator: XValidator.validatePhone,
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(
                    controller: emailController,
                    label: XTexts.xEmail,
                    hint: 'Enter your email',
                    prefixIcon: Iconsax.direct_right,
                    keyboardType: TextInputType.emailAddress,
                    validator: XValidator.validateEmail,
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(
                    controller: passwordController,
                    label: XTexts.xPassword,
                    hint: 'Create a strong password',
                    prefixIcon: Iconsax.password_check,
                    obscureText: hidePassword,
                    validator: XValidator.validatePassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword ? Iconsax.eye_slash : Iconsax.eye,
                      ),
                    ),
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(
                    controller: addressController,
                    label: XTexts.xAddress,
                    hint: 'Enter library address',
                    prefixIcon: Iconsax.location,
                    maxLines: 2,
                    validator: XValidator.validateAddress,
                  ),
                  const SizedBox(height: XSizes.spaceBtwSections),

                  /// --- Register Button
                  XPrimaryButton(
                    text: XTexts.xCreateAccount,
                    isLoading: isLoading,
                    onPressed: () {
                      if (registerFormKey.currentState!.validate()) {
                        context.read<RegisterCubit>().register(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              libraryName: libraryNameController.text.trim(),
                              ownerName: ownerNameController.text.trim(),
                              mobile: mobileController.text.trim(),
                              address: addressController.text.trim(),
                            );
                      }
                    },
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
                    onPressed: () => Navigator.pop(context),
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
      },
    );
  }
}
