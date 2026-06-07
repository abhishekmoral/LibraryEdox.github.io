import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/common/widgets/cards/plan_card.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';
import 'package:edox_library/common/widgets/inputs/dropdown_field.dart';
import 'package:edox_library/features/plans/models/plan_model.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);
    final plans = <PlanModel>[
      PlanModel(id: '1', planName: 'Monthly', duration: 1, price: 1500, isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      PlanModel(id: '2', planName: 'Quarterly', duration: 3, price: 4000, isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      PlanModel(id: '3', planName: 'Half Yearly', duration: 6, price: 7500, isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      PlanModel(id: '4', planName: 'Annual', duration: 12, price: 14000, isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    ].obs;

    return Scaffold(
      appBar: const XAppBar(title: Text('Membership Plans')),
      body: Padding(
        padding: const EdgeInsets.all(XSizes.defaultSpace),
        child: Column(
          children: [
            /// --- Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(XSizes.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), XColors.primary]),
                borderRadius: BorderRadius.circular(XSizes.cardRadiusLg),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: XColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.calendar_1, color: XColors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Active Plans', style: TextStyle(color: XColors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                      Text('${plans.length} plans configured', style: TextStyle(color: XColors.white.withValues(alpha: 0.7), fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: XSizes.spaceBtwSections),

            /// --- Plans List
            Expanded(
              child: Obx(() => ListView.separated(
                itemCount: plans.length,
                separatorBuilder: (_, __) => const SizedBox(height: XSizes.sm + 4),
                itemBuilder: (context, index) {
                  return XPlanCard(
                    plan: plans[index],
                    onEdit: () => _showPlanDialog(context, plan: plans[index]),
                    onDelete: () {
                      Get.snackbar('Deleted', '${plans[index].planName} plan removed', snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.error, colorText: XColors.white);
                    },
                  );
                },
              )),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPlanDialog(context),
        backgroundColor: XColors.primary,
        icon: const Icon(Iconsax.add, color: XColors.white),
        label: const Text('Add Plan', style: TextStyle(color: XColors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showPlanDialog(BuildContext context, {PlanModel? plan}) {
    final isEdit = plan != null;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(XSizes.defaultSpace),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: XColors.softGrey, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: XSizes.spaceBtwItems),
              Text(isEdit ? 'Edit Plan' : 'Add Plan', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: XSizes.spaceBtwSections),
              XTextField(label: 'Plan Name', hint: 'e.g. Monthly', prefixIcon: Iconsax.tag, initialValue: plan?.planName),
              const SizedBox(height: XSizes.spaceBtwItems),
              XTextField(label: 'Duration (months)', hint: 'e.g. 1', prefixIcon: Iconsax.calendar, keyboardType: TextInputType.number, initialValue: plan?.duration.toString()),
              const SizedBox(height: XSizes.spaceBtwItems),
              XTextField(label: 'Price (₹)', hint: 'e.g. 1500', prefixIcon: Iconsax.money_recive, keyboardType: TextInputType.number, initialValue: plan?.price.toStringAsFixed(0)),
              const SizedBox(height: XSizes.spaceBtwSections),
              XPrimaryButton(
                text: isEdit ? 'Update Plan' : 'Create Plan',
                onPressed: () {
                  Get.back();
                  Get.snackbar('Success', isEdit ? 'Plan updated!' : 'Plan created!', snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.accent, colorText: XColors.white);
                },
              ),
              const SizedBox(height: XSizes.spaceBtwItems),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
