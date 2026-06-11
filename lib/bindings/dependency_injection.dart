import 'package:get_it/get_it.dart';

// Repositories
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/data/repositories/library/library_repository.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/data/repositories/seats/seat_repository.dart';
import 'package:edox_library/data/repositories/payments/payment_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';
import 'package:edox_library/data/repositories/slots/slot_repository.dart';

// Services
import 'package:edox_library/data/services/firestore_service.dart';
import 'package:edox_library/data/services/firebase_auth_service.dart';
import 'package:edox_library/data/services/firebase_storage_service.dart';
import 'package:edox_library/data/services/fcm_service.dart';
import 'package:edox_library/features/subscription/controllers/razorpay_controller.dart';

// Cubits
import 'package:edox_library/features/authentication/controllers/auth_cubit.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/features/seats/controllers/seats_cubit.dart';
import 'package:edox_library/features/members/controllers/members_cubit.dart';
import 'package:edox_library/features/dashboard/controllers/dashboard_cubit.dart';
import 'package:edox_library/features/personalization/controllers/library_cubit.dart';
import 'package:edox_library/features/settings/controllers/theme_cubit.dart';
import 'package:edox_library/features/settings/controllers/settings_cubit.dart';
import 'package:edox_library/features/subscription/controllers/subscription_cubit.dart';

final locator = GetIt.instance;

Future<void> setupDependencies() async {
  // --- Services ---
  locator.registerLazySingleton<FirestoreService>(() => FirestoreService());
  locator.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  locator.registerLazySingleton<FirebaseStorageService>(() => FirebaseStorageService());
  locator.registerLazySingleton<FCMService>(() => FCMService());
  locator.registerLazySingleton<RazorpayService>(() => RazorpayService());

  // --- Repositories ---
  locator.registerLazySingleton<AuthenticationRepository>(() => AuthenticationRepository());
  locator.registerLazySingleton<LibraryRepository>(() => LibraryRepository());
  locator.registerLazySingleton<SlotRepository>(() => SlotRepository());
  locator.registerLazySingleton<MemberRepository>(() => MemberRepository());
  locator.registerLazySingleton<SeatRepository>(() => SeatRepository());
  locator.registerLazySingleton<PaymentRepository>(() => PaymentRepository());
  locator.registerLazySingleton<ActivityRepository>(() => ActivityRepository());

  // --- Cubits (Global state) ---
  locator.registerLazySingleton<AuthCubit>(() => AuthCubit());
  locator.registerLazySingleton<SlotsCubit>(() => SlotsCubit());
  locator.registerLazySingleton<SeatsCubit>(() => SeatsCubit());
  locator.registerLazySingleton<MembersCubit>(() => MembersCubit());
  locator.registerLazySingleton<DashboardCubit>(() => DashboardCubit());
  locator.registerLazySingleton<LibraryCubit>(() => LibraryCubit());
  locator.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  locator.registerLazySingleton<SettingsCubit>(() => SettingsCubit());
  locator.registerLazySingleton<SubscriptionCubit>(() => SubscriptionCubit());
}
