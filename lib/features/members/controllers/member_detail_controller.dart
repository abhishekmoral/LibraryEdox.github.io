import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';

class MemberDetailController extends GetxController {
  static MemberDetailController get instance => Get.find();

  final _memberRepository = Get.put(MemberRepository());
  final _activityRepository = Get.put(ActivityRepository());

  final isDeleting = false.obs;
  final isRenewing = false.obs;

  void deleteMember(MemberModel member) async {
    // Show confirmation dialog
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: XColors.darkGrey)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: XColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      isDeleting.value = true;
      await _memberRepository.deleteMember(member.id);

      // Log Activity
      final activity = ActivityModel(
        id: '',
        type: 'member',
        title: 'Member Deleted',
        description: '${member.fullName} was removed',
        memberId: member.id,
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);

      Get.snackbar(
        'Success',
        'Member deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: XColors.success,
        colorText: XColors.white,
      );

      // Go back to members list
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.error, colorText: XColors.white);
    } finally {
      isDeleting.value = false;
    }
  }

  void renewMembership(MemberModel member) async {
    // Show renewal dialog
    String selectedPlan = 'monthly';
    
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Renew Membership'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select renewal plan:'),
            const SizedBox(height: XSizes.spaceBtwItems),
            StatefulBuilder(
              builder: (context, setState) {
                return DropdownButtonFormField<String>(
                  value: selectedPlan,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(XSizes.borderRadiusMd)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: XSizes.md, vertical: XSizes.sm),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly - ₹1,500')),
                    DropdownMenuItem(value: 'quarterly', child: Text('Quarterly - ₹4,000')),
                    DropdownMenuItem(value: 'half_yearly', child: Text('Half Yearly - ₹7,500')),
                    DropdownMenuItem(value: 'annual', child: Text('Annual - ₹14,000')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => selectedPlan = v);
                  },
                );
              }
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: XColors.darkGrey)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Renew', style: TextStyle(color: XColors.primary)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      isRenewing.value = true;
      
      // Calculate new expiry
      DateTime newExpiry = member.expiryDate;
      // If already expired, start from today. If active, add to existing expiry.
      if (newExpiry.isBefore(DateTime.now())) {
        newExpiry = DateTime.now();
      }
      
      String planName = 'Monthly';
      if (selectedPlan == 'quarterly') {
        newExpiry = newExpiry.add(const Duration(days: 90));
        planName = 'Quarterly';
      } else if (selectedPlan == 'half_yearly') {
        newExpiry = newExpiry.add(const Duration(days: 180));
        planName = 'Half Yearly';
      } else if (selectedPlan == 'annual') {
        newExpiry = newExpiry.add(const Duration(days: 365));
        planName = 'Annual';
      } else {
        newExpiry = newExpiry.add(const Duration(days: 30));
      }

      final updatedMember = member.copyWith(
        expiryDate: newExpiry,
        planId: selectedPlan,
        planName: planName,
        status: 'active',
        updatedAt: DateTime.now(),
      );

      await _memberRepository.updateMember(updatedMember);

      // Log Activity
      final activity = ActivityModel(
        id: '',
        type: 'member',
        title: 'Membership Renewed',
        description: '${member.fullName} renewed for $planName',
        memberId: member.id,
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);

      Get.back(); // Pop detail screen
      Get.snackbar(
        'Success',
        'Membership renewed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: XColors.success,
        colorText: XColors.white,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.error, colorText: XColors.white);
    } finally {
      isRenewing.value = false;
    }
  }
}
