import 'package:get/get.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/data/repositories/library/library_repository.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/data/repositories/seats/seat_repository.dart';
import 'package:edox_library/data/repositories/payments/payment_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    // Services will be registered here when Firebase is configured

    // Repositories will be registered here
    Get.put(AuthenticationRepository());
    Get.put(LibraryRepository());
    Get.put(MemberRepository());
    Get.put(SeatRepository());
    Get.put(PaymentRepository());
    Get.put(ActivityRepository());
    // Get.put(SeatRepository());
    // Get.put(PaymentRepository());
    // Get.put(PlanRepository());
    // Get.put(NotificationRepository());
    // Get.put(SettingsRepository());
    // Get.put(SubscriptionRepository());
  }
}
