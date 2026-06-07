import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/features/members/models/member_model.dart';

class MembersController extends GetxController {
  static MembersController get instance => Get.find();

  final isLoading = false.obs;
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;
  
  final RxList<MemberModel> allMembers = <MemberModel>[].obs;
  final RxList<MemberModel> displayList = <MemberModel>[].obs;
  
  final filters = ['All', 'Active', 'Expired', 'Expiring Soon'];

  final _memberRepository = Get.put(MemberRepository());

  @override
  void onInit() {
    super.onInit();
    fetchMembers();

    // Auto-update when search, filter, or the source list changes
    ever(searchQuery, (_) => _updateList());
    ever(selectedFilter, (_) => _updateList());
    ever(allMembers, (_) => _updateList());
  }

  void fetchMembers() {
    isLoading.value = true;
    try {
      allMembers.bindStream(_memberRepository.getAllMembersStream());
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch members data');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateList() {
    var list = allMembers.toList();

    // Apply status filter
    final filter = selectedFilter.value;
    if (filter == 'Active') {
      list = list.where((m) => m.status == 'active').toList();
    } else if (filter == 'Expired') {
      list = list.where((m) => m.status == 'expired').toList();
    } else if (filter == 'Expiring Soon') {
      list = list.where((m) => m.isExpiringSoon).toList();
    }

    // Apply search
    final q = searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((m) =>
        m.fullName.toLowerCase().contains(q) ||
        m.mobile.contains(q) ||
        m.seatNumber.toLowerCase().contains(q) ||
        m.email.toLowerCase().contains(q)
      ).toList();
    }

    displayList.assignAll(list);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
