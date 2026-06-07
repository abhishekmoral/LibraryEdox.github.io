import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/validators/validation.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';
import 'package:edox_library/common/widgets/inputs/dropdown_field.dart';

class CollectPaymentScreen extends StatelessWidget {
  const CollectPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final isLoading = false.obs;
    final selectedMethod = Rxn<String>();

    return Scaffold(
      appBar: const XAppBar(title: Text('Collect Fee')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(XSizes.defaultSpace),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- Select Member
              XDropdownField<String>(
                label: 'Select Member',
                prefixIcon: Iconsax.user,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Rahul Sharma - A-01')),
                  DropdownMenuItem(value: '2', child: Text('Priya Patel - A-02')),
                  DropdownMenuItem(value: '3', child: Text('Amit Kumar - A-03')),
                  DropdownMenuItem(value: '5', child: Text('Vikash Gupta - B-03')),
                ],
                onChanged: (v) {},
                validator: (v) => v == null ? 'Select a member' : null,
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Plan
              XDropdownField<String>(
                label: 'Membership Plan',
                prefixIcon: Iconsax.calendar_1,
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly - ₹1,500')),
                  DropdownMenuItem(value: 'quarterly', child: Text('Quarterly - ₹4,000')),
                  DropdownMenuItem(value: 'half_yearly', child: Text('Half Yearly - ₹7,500')),
                  DropdownMenuItem(value: 'annual', child: Text('Annual - ₹14,000')),
                ],
                onChanged: (v) {},
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Amount
              XTextField(
                label: 'Amount (₹)',
                hint: 'Enter amount',
                prefixIcon: Iconsax.money_recive,
                keyboardType: TextInputType.number,
                validator: XValidator.validateAmount,
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Payment Method
              Text('Payment Method', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: XSizes.sm),
              Obx(() => Row(
                children: [
                  _MethodChip(label: 'Cash', icon: Iconsax.money_recive, selected: selectedMethod.value == 'cash', onTap: () => selectedMethod.value = 'cash'),
                  const SizedBox(width: 8),
                  _MethodChip(label: 'UPI', icon: Iconsax.mobile, selected: selectedMethod.value == 'upi', onTap: () => selectedMethod.value = 'upi'),
                  const SizedBox(width: 8),
                  _MethodChip(label: 'Bank', icon: Iconsax.bank, selected: selectedMethod.value == 'bank', onTap: () => selectedMethod.value = 'bank'),
                ],
              )),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Notes
              XTextField(label: 'Notes', hint: 'Payment notes (optional)', prefixIcon: Iconsax.note_1, maxLines: 2),
              const SizedBox(height: XSizes.spaceBtwSections),

              /// --- Submit
              Obx(() => XPrimaryButton(
                text: 'Collect Payment',
                isLoading: isLoading.value,
                icon: Iconsax.tick_circle,
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    isLoading.value = true;
                    Future.delayed(const Duration(seconds: 1), () {
                      isLoading.value = false;
                      Get.back();
                      Get.snackbar('Success', 'Payment collected successfully!', snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.accent, colorText: XColors.white);
                    });
                  }
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label; final IconData icon; final bool selected; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? XColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
            border: Border.all(color: selected ? XColors.primary : XColors.borderPrimary),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: selected ? XColors.white : XColors.darkGrey),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? XColors.white : XColors.darkGrey)),
            ],
          ),
        ),
      ),
    );
  }
}
