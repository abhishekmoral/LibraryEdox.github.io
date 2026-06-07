import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/features/seats/controllers/seats_controller.dart' as edox_seats;
import 'package:edox_library/data/repositories/seats/seat_repository.dart';

class EditMemberController extends GetxController {
  static EditMemberController get instance => Get.find();

  final _memberRepository = Get.put(MemberRepository());
  final _activityRepository = Get.put(ActivityRepository());
  final seatsController = Get.put(edox_seats.SeatsController());

  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  // Form Controllers
  final fullName = TextEditingController();
  final mobile = TextEditingController();
  final alternateMobile = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final notes = TextEditingController();

  final seatId = ''.obs;

  late MemberModel originalMember;

  void initMemberData(MemberModel member) {
    originalMember = member;
    fullName.text = member.fullName;
    mobile.text = member.mobile;
    alternateMobile.text = member.alternateMobile;
    email.text = member.email;
    address.text = member.address;
    notes.text = member.notes;
    seatId.value = member.seatId;
  }

  void saveChanges() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final updatedMember = originalMember.copyWith(
        fullName: fullName.text.trim(),
        mobile: mobile.text.trim(),
        alternateMobile: alternateMobile.text.trim(),
        email: email.text.trim(),
        address: address.text.trim(),
        notes: notes.text.trim(),
        seatId: seatId.value,
        seatNumber: seatId.value.isNotEmpty ? seatId.value : 'Unassigned',
        updatedAt: DateTime.now(),
      );

      await _memberRepository.updateMember(updatedMember);

      // Handle Seat Reassignment
      if (seatId.value != originalMember.seatId) {
        final seatRepo = Get.find<SeatRepository>();
        
        // 1. Free up the old seat
        if (originalMember.seatId.isNotEmpty) {
          final oldSeat = seatsController.allSeats.firstWhereOrNull((s) => s.seatNumber == originalMember.seatId);
          if (oldSeat != null) {
            final freedSeat = oldSeat.copyWith(
              status: 'available',
              memberId: '',
              memberName: '',
              memberMobile: '',
              memberExpiry: null,
              updatedAt: DateTime.now(),
            );
            await seatRepo.updateSeat(freedSeat);
          }
        }
        
        // 2. Occupy the new seat
        if (seatId.value.isNotEmpty) {
          final newSeat = seatsController.allSeats.firstWhereOrNull((s) => s.seatNumber == seatId.value);
          if (newSeat != null) {
            final occupiedSeat = newSeat.copyWith(
              status: 'occupied',
              memberId: updatedMember.id,
              memberName: updatedMember.fullName,
              memberMobile: updatedMember.mobile,
              memberExpiry: updatedMember.expiryDate,
              updatedAt: DateTime.now(),
            );
            await seatRepo.updateSeat(occupiedSeat);
          }
        }
      } else if (seatId.value.isNotEmpty) {
        // Seat is the same, but member details might have changed
        final currentSeat = seatsController.allSeats.firstWhereOrNull((s) => s.seatNumber == seatId.value);
        if (currentSeat != null) {
          final updatedSeat = currentSeat.copyWith(
            memberName: updatedMember.fullName,
            memberMobile: updatedMember.mobile,
            memberExpiry: updatedMember.expiryDate,
            updatedAt: DateTime.now(),
          );
          await Get.find<SeatRepository>().updateSeat(updatedSeat);
        }
      }

      // Log Activity
      final activity = ActivityModel(
        id: '',
        type: 'member',
        title: 'Member Profile Updated',
        description: '${updatedMember.fullName} updated their profile',
        memberId: updatedMember.id,
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);

      Get.back(); // Pop screen
      Get.back(); // Pop detail screen to refresh the list / Avoid old data state

      Get.snackbar(
        'Success',
        'Member details updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: XColors.success,
        colorText: XColors.white,
      );

    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.error, colorText: XColors.white);
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
