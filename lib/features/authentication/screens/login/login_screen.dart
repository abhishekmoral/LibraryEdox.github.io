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
import 'package:edox_library/features/authentication/screens/register/register_screen.dart';
import 'package:edox_library/features/authentication/screens/forgot_password/forgot_password_screen.dart';
import 'package:edox_library/features/authentication/controllers/login/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(XSizes.defaultSpace),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Center(
                    child: SizedBox(width: 500, child: const _LoginContent()),
                  );
                }
                return const _LoginContent();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent();

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: XColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is LoginLoading;

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
              key: loginFormKey,
              child: Column(
                children: [
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
                    hint: 'Enter your password',
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
                  const SizedBox(height: XSizes.sm),

                  /// --- Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: const Text(XTexts.xForgotPassword),
                    ),
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  /// --- Login Button
                  XPrimaryButton(
                    text: XTexts.xLogin,
                    isLoading: isLoading,
                    onPressed: () {
                      if (loginFormKey.currentState!.validate()) {
                        context.read<LoginCubit>().login(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                      }
                    },
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
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
      },
    );
  }
}
