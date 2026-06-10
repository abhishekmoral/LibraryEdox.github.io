import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/common/widgets/cards/plan_card.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';
import 'package:edox_library/features/plans/models/plan_model.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late List<PlanModel> _plans;

  @override
  void initState() {
    super.initState();
    _plans = [
      PlanModel(id: '1', planName: 'Monthly', duration: 1, price: 1500, isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      PlanModel(id: '2', planName: 'Quarterly', duration: 3, price: 4000, isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      PlanModel(id: '3', planName: 'Half Yearly', duration: 6, price: 7500, isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      PlanModel(id: '4', planName: 'Annual', duration: 12, price: 14000, isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                      Text('${_plans.length} plans configured', style: TextStyle(color: XColors.white.withValues(alpha: 0.7), fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: XSizes.spaceBtwSections),

            /// --- Plans List
            Expanded(
              child: ListView.separated(
                itemCount: _plans.length,
                separatorBuilder: (_, __) => const SizedBox(height: XSizes.sm + 4),
                itemBuilder: (context, index) {
                  final plan = _plans[index];
                  return XPlanCard(
                    plan: plan,
                    onEdit: () => _showPlanDialog(context, plan: plan),
                    onDelete: () {
                      setState(() {
                        _plans.removeAt(index);
                      });
                      XHelperFunctions.showSnackBar('${plan.planName} plan removed');
                    },
                  );
                },
              ),
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

  void _showPlanDialog(BuildContext parentContext, {PlanModel? plan}) {
    final isEdit = plan != null;
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(XSizes.defaultSpace),
          decoration: BoxDecoration(
            color: Theme.of(parentContext).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: XColors.softGrey, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  Text(isEdit ? 'Edit Plan' : 'Add Plan', style: Theme.of(parentContext).textTheme.headlineSmall),
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
                      Navigator.pop(sheetContext);
                      XHelperFunctions.showSnackBar(isEdit ? 'Plan updated!' : 'Plan created!');
                    },
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
