import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/utils/constants/text_strings.dart';
import 'package:edox_library/utils/theme/theme.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/routes/app_routes.dart';

// Screens
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

// Cubits
import 'package:edox_library/features/authentication/controllers/auth_cubit.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/features/seats/controllers/seats_cubit.dart';
import 'package:edox_library/features/members/controllers/members_cubit.dart';
import 'package:edox_library/features/dashboard/controllers/dashboard_cubit.dart';
import 'package:edox_library/features/personalization/controllers/library_cubit.dart';
import 'package:edox_library/features/settings/controllers/theme_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => locator<AuthCubit>()),
        BlocProvider<SlotsCubit>(create: (context) => locator<SlotsCubit>()),
        BlocProvider<SeatsCubit>(create: (context) => locator<SeatsCubit>()),
        BlocProvider<MembersCubit>(create: (context) => locator<MembersCubit>()),
        BlocProvider<DashboardCubit>(create: (context) => locator<DashboardCubit>()),
        BlocProvider<LibraryCubit>(create: (context) => locator<LibraryCubit>()),
        BlocProvider<ThemeCubit>(create: (context) => locator<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: XTexts.xAppName,
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: XAppTheme.lightTheme,
            darkTheme: XAppTheme.darkTheme,
            navigatorKey: XHelperFunctions.navigatorKey,
            scaffoldMessengerKey: XHelperFunctions.scaffoldMessengerKey,
            initialRoute: XRoutes.navigation,
            routes: {
              XRoutes.navigation: (context) => const AuthWrapper(),
              XRoutes.login: (context) => const LoginScreen(),
              XRoutes.register: (context) => const RegisterScreen(),
              XRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
              XRoutes.verifyEmail: (context) => const VerifyEmailScreen(),
              XRoutes.addMember: (context) => const AddMemberScreen(),
              XRoutes.payments: (context) => const PaymentsScreen(),
              XRoutes.collectPayment: (context) => const CollectPaymentScreen(),
              XRoutes.plans: (context) => const PlansScreen(),
              XRoutes.reminders: (context) => const RemindersScreen(),
              XRoutes.subscription: (context) => const SubscriptionScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const NavigationMenu();
        } else if (state is Unauthenticated) {
          return const LoginScreen();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
