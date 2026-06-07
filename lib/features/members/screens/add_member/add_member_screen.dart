import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/constants/text_strings.dart';
import 'package:edox_library/utils/validators/validation.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';
import 'package:edox_library/common/widgets/inputs/dropdown_field.dart';
import 'package:edox_library/features/members/controllers/add_member_controller.dart';

class AddMemberScreen extends StatelessWidget {
  const AddMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddMemberController());

    return Scaffold(
      appBar: const XAppBar(title: Text('Add Member')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(XSizes.defaultSpace),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              /// Photo Picker
              GestureDetector(
                onTap: () {},
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: XColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Iconsax.camera, color: XColors.primary, size: 28),
                ),
              ),
              const SizedBox(height: 8),
              Text('Add Photo', style: TextStyle(color: XColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: XSizes.spaceBtwSections),

              XTextField(controller: controller.fullName, label: XTexts.xFullName, hint: 'Enter full name', prefixIcon: Iconsax.user, validator: XValidator.validateName),
              const SizedBox(height: XSizes.spaceBtwItems),
              XTextField(controller: controller.mobile, label: XTexts.xMobileNumber, hint: '10-digit mobile', prefixIcon: Iconsax.call, keyboardType: TextInputType.phone, validator: XValidator.validatePhone),
              const SizedBox(height: XSizes.spaceBtwItems),
              XTextField(controller: controller.alternateMobile, label: 'Alternate Number', hint: 'Optional', prefixIcon: Iconsax.call_add),
              const SizedBox(height: XSizes.spaceBtwItems),
              XTextField(controller: controller.email, label: XTexts.xEmail, hint: 'email@example.com', prefixIcon: Iconsax.direct_right, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: XSizes.spaceBtwItems),
              XTextField(controller: controller.address, label: XTexts.xAddress, hint: 'Full address', prefixIcon: Iconsax.location, maxLines: 2),
              const SizedBox(height: XSizes.spaceBtwItems),

              Obx(() => XDropdownField<String>(
                label: 'Gender',
                prefixIcon: Iconsax.user,
                value: controller.gender.value,
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => controller.gender.value = v.toString(),
              )),
              const SizedBox(height: XSizes.spaceBtwItems),

              Obx(() => XDropdownField<String>(
                label: 'Membership Plan',
                prefixIcon: Iconsax.calendar_1,
                value: controller.planId.value,
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly - ₹1,500')),
                  DropdownMenuItem(value: 'quarterly', child: Text('Quarterly - ₹4,000')),
                  DropdownMenuItem(value: 'half_yearly', child: Text('Half Yearly - ₹7,500')),
                  DropdownMenuItem(value: 'annual', child: Text('Annual - ₹14,000')),
                ],
                onChanged: (v) => controller.planId.value = v.toString(),
              )),
              const SizedBox(height: XSizes.spaceBtwItems),

              Obx(() {
                final availableSeats = controller.seatsController.allSeats
                    .where((s) => s.status == 'available')
                    .toList();
                
                return XDropdownField<String>(
                  label: 'Assign Seat',
                  prefixIcon: Iconsax.grid_2,
                  value: controller.seatId.value.isEmpty ? null : controller.seatId.value,
                  items: availableSeats.map((seat) {
                    return DropdownMenuItem(
                      value: seat.seatNumber, 
                      child: Text('${seat.seatNumber} (Available)')
                    );
                  }).toList(),
                  onChanged: (v) => controller.seatId.value = v.toString(),
                );
              }),
              const SizedBox(height: XSizes.spaceBtwItems),

              Obx(() => XDropdownField<String>(
                label: 'Payment Method',
                prefixIcon: Iconsax.money_recive,
                value: controller.paymentMethod.value,
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'upi', child: Text('UPI')),
                  DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                ],
                onChanged: (v) => controller.paymentMethod.value = v.toString(),
              )),
              const SizedBox(height: XSizes.spaceBtwItems),

              XTextField(controller: controller.notes, label: 'Notes', hint: 'Any additional notes', prefixIcon: Iconsax.note_1, maxLines: 3),
              const SizedBox(height: XSizes.spaceBtwSections),

              Obx(() => XPrimaryButton(
                text: 'Add Member',
                isLoading: controller.isLoading.value,
                icon: Iconsax.user_add,
                onPressed: () => controller.saveMember(),
              )),
              const SizedBox(height: XSizes.spaceBtwItems),
            ],
          ),
        ),
      ),
    );
  }
}
