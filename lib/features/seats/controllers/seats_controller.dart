import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edox_library/data/repositories/seats/seat_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';
import 'package:edox_library/features/seats/models/seat_model.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';
import 'package:edox_library/utils/constants/colors.dart';

class SeatsController extends GetxController {
  static SeatsController get instance => Get.find();

  final _seatRepository = Get.put(SeatRepository());
  final _activityRepository = Get.put(ActivityRepository());

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final isGridView = true.obs;
  final allSeats = <SeatModel>[].obs;
  
  final isAddingSeats = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind stream to automatically update when Firebase changes
    allSeats.bindStream(_seatRepository.getAllSeatsStream());
  }

  List<SeatModel> get filteredSeats {
    if (searchQuery.value.isEmpty) return allSeats;
    final q = searchQuery.value.toLowerCase();
    return allSeats.where((s) {
      return s.seatNumber.toLowerCase().contains(q) ||
          s.memberName.toLowerCase().contains(q) ||
          s.memberMobile.contains(q) ||
          s.status.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> addSeats(String prefix, int start, int count) async {
    try {
      isAddingSeats.value = true;
      
      for (int i = 0; i < count; i++) {
        final num = start + i;
        final seatNum = '$prefix-${num.toString().padLeft(2, '0')}';
        
        final newSeat = SeatModel(
          id: '',
          seatNumber: seatNum,
          status: 'available',
          memberId: '',
          memberName: '',
          memberMobile: '',
          memberExpiry: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _seatRepository.saveSeatRecord(newSeat);
      }

      // Log Activity
      final activity = ActivityModel(
        id: '',
        type: 'seat',
        title: 'Seats Added',
        description: 'Added $count new seats ($prefix)',
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);

      Get.back(); // close the bottom sheet
      Get.snackbar('Success', '$count seat${count > 1 ? 's' : ''} added successfully!', snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.accent, colorText: XColors.white);
      
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.error, colorText: XColors.white);
    } finally {
      isAddingSeats.value = false;
    }
  }

  Future<void> updateSeat(SeatModel seat) async {
    try {
      await _seatRepository.updateSeat(seat);
      
      final activity = ActivityModel(
        id: '',
        type: 'seat',
        title: 'Seat Updated',
        description: 'Seat ${seat.seatNumber} was updated',
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);
      
      Get.snackbar('Success', 'Seat updated successfully!', snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.success, colorText: XColors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.error, colorText: XColors.white);
    }
  }

  Future<void> deleteSeat(SeatModel seat) async {
    try {
      await _seatRepository.deleteSeat(seat.id);
      
      final activity = ActivityModel(
        id: '',
        type: 'seat',
        title: 'Seat Deleted',
        description: 'Seat ${seat.seatNumber} was removed',
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);
      
      Get.snackbar('Success', 'Seat deleted successfully.', snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.success, colorText: XColors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.error, colorText: XColors.white);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
