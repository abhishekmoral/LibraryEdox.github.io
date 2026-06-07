import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';
import 'package:edox_library/features/seats/controllers/seats_controller.dart' as edox_seats;
import 'package:edox_library/data/repositories/seats/seat_repository.dart';
import 'package:edox_library/data/repositories/payments/payment_repository.dart';
import 'package:edox_library/features/payments/models/payment_model.dart';
import 'package:edox_library/features/dashboard/controllers/dashboard_controller.dart';
import 'package:edox_library/utils/constants/colors.dart';

class AddMemberController extends GetxController {
  static AddMemberController get instance => Get.find();

  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  // Form Controllers
  final fullName = TextEditingController();
  final mobile = TextEditingController();
  final alternateMobile = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final notes = TextEditingController();

  // Dropdown States
  final gender = 'male'.obs;
  final planId = 'monthly'.obs;
  final seatId = ''.obs;
  final paymentMethod = 'cash'.obs;

  final _memberRepository = Get.put(MemberRepository());
  final _activityRepository = Get.put(ActivityRepository());
  final seatsController = Get.put(edox_seats.SeatsController());

  void saveMember() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Mock processing Plan and Seat details
      DateTime expiryDate = DateTime.now();
      String planName = 'Monthly';
      if (planId.value == 'quarterly') {
        expiryDate = DateTime.now().add(const Duration(days: 90));
        planName = 'Quarterly';
      } else if (planId.value == 'half_yearly') {
        expiryDate = DateTime.now().add(const Duration(days: 180));
        planName = 'Half Yearly';
      } else if (planId.value == 'annual') {
        expiryDate = DateTime.now().add(const Duration(days: 365));
        planName = 'Annual';
      } else {
        expiryDate = DateTime.now().add(const Duration(days: 30));
      }

      final newMember = MemberModel(
        id: '', // Firestore will auto-generate this when using add()
        fullName: fullName.text.trim(),
        mobile: mobile.text.trim(),
        alternateMobile: alternateMobile.text.trim(),
        email: email.text.trim(),
        address: address.text.trim(),
        gender: gender.value,
        photo: '',
        seatId: seatId.value,
        seatNumber: seatId.value.isNotEmpty ? seatId.value : 'Unassigned',
        joiningDate: DateTime.now(),
        planId: planId.value,
        planName: planName,
        expiryDate: expiryDate,
        paymentStatus: 'paid', // Defaulting to paid for MVP
        status: 'active',
        notes: notes.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      final memberId = await _memberRepository.saveMemberRecord(newMember);

      // Update the assigned seat
      if (seatId.value.isNotEmpty) {
        final seat = seatsController.allSeats.firstWhereOrNull((s) => s.seatNumber == seatId.value);
        if (seat != null) {
          final updatedSeat = seat.copyWith(
            status: 'occupied',
            memberId: memberId,
            memberName: fullName.text.trim(),
            memberMobile: mobile.text.trim(),
            memberExpiry: expiryDate,
            updatedAt: DateTime.now(),
          );
          await Get.find<SeatRepository>().updateSeat(updatedSeat);
        }
      }

      // Create Payment Record for the newly added member
      double amountPaid = 0.0;
      if (planId.value == 'monthly') amountPaid = 1500;
      else if (planId.value == 'quarterly') amountPaid = 4000;
      else if (planId.value == 'half_yearly') amountPaid = 7500;
      else if (planId.value == 'annual') amountPaid = 14000;

      final payment = PaymentModel(
        id: '',
        memberId: memberId,
        memberName: fullName.text.trim(),
        amount: amountPaid,
        paymentMethod: paymentMethod.value,
        type: 'new',
        date: DateTime.now(),
        planId: planId.value,
        planName: planName,
        notes: notes.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await Get.put(PaymentRepository()).savePaymentRecord(payment);

      // Log Activity
      final activity = ActivityModel(
        id: '',
        type: 'member',
        title: 'New Member Added',
        description: '${fullName.text.trim()} joined the library',
        memberId: memberId,
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);

      // Refresh Dashboard Stats so the new revenue is visible immediately
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().fetchDashboardData();
      }

      // Reset and go back
      Get.back();

      Get.snackbar(
        'Success',
        'Member added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: XColors.success,
        colorText: XColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: XColors.error,
        colorText: XColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullName.dispose();
    mobile.dispose();
    alternateMobile.dispose();
    email.dispose();
    address.dispose();
    notes.dispose();
    super.onClose();
  }
}
