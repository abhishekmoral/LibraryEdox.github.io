import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edox_library/bindings/general_bindings.dart';
import 'package:edox_library/utils/constants/text_strings.dart';
import 'package:edox_library/utils/theme/theme.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/routes/app_routes.dart';
import 'package:edox_library/features/authentication/screens/login/login_screen.dart';
import 'package:edox_library/features/authentication/screens/register/register_screen.dart';
import 'package:edox_library/features/authentication/screens/forgot_password/forgot_password_screen.dart';
import 'package:edox_library/features/authentication/screens/verify_email/verify_email_screen.dart';
import 'package:edox_library/features/members/screens/add_member/add_member_screen.dart';
import 'package:edox_library/features/payments/screens/payments/payments_screen.dart';
import 'package:edox_library/features/payments/screens/collect_payment/collect_payment_screen.dart';
import 'package:edox_library/features/plans/screens/plans_screen.dart';
import 'package:edox_library/features/reminders/screens/reminders_screen.dart';
import 'package:edox_library/features/subscription/screens/subscription_screen.dart';
import 'package:edox_library/navigation_menu.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: XTexts.xAppName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: XAppTheme.lightTheme,
      darkTheme: XAppTheme.darkTheme,
      initialBinding: GeneralBindings(),
      initialRoute: XRoutes.login,
      getPages: [
        GetPage(name: XRoutes.login, page: () => const LoginScreen()),
        GetPage(name: XRoutes.register, page: () => const RegisterScreen()),
        GetPage(name: XRoutes.forgotPassword, page: () => const ForgotPasswordScreen()),
        GetPage(name: XRoutes.verifyEmail, page: () => const VerifyEmailScreen()),
        GetPage(name: XRoutes.navigation, page: () => const NavigationMenu()),
        GetPage(name: XRoutes.addMember, page: () => const AddMemberScreen()),
        GetPage(name: XRoutes.payments, page: () => const PaymentsScreen()),
        GetPage(name: XRoutes.collectPayment, page: () => const CollectPaymentScreen()),
        GetPage(name: XRoutes.plans, page: () => const PlansScreen()),
        GetPage(name: XRoutes.reminders, page: () => const RemindersScreen()),
        GetPage(name: XRoutes.subscription, page: () => const SubscriptionScreen()),
      ],
    );
  }
}
