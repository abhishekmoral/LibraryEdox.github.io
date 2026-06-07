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
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/members/controllers/edit_member_controller.dart';

class EditMemberScreen extends StatelessWidget {
  const EditMemberScreen({super.key, required this.member});
  final MemberModel member;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditMemberController());
    // Initialize data in controller
    controller.initMemberData(member);

    return Scaffold(
      appBar: const XAppBar(title: Text('Edit Member')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(XSizes.defaultSpace),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: XColors.primary.withValues(alpha: 0.1),
                child: Text(member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?', 
                  style: const TextStyle(color: XColors.primary, fontSize: 28, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: XSizes.spaceBtwSections),

              XTextField(controller: controller.fullName, label: 'Full Name', hint: 'Enter full name', prefixIcon: Iconsax.user, validator: XValidator.validateName),
              const SizedBox(height: XSizes.spaceBtwItems),
              XTextField(controller: controller.mobile, label: 'Mobile', hint: '10-digit mobile', prefixIcon: Iconsax.call, keyboardType: TextInputType.phone, validator: XValidator.validatePhone),
              const SizedBox(height: XSizes.spaceBtwItems),
              XTextField(controller: controller.alternateMobile, label: 'Alternate Mobile', hint: 'Optional', prefixIcon: Iconsax.call_add, keyboardType: TextInputType.phone),
              const SizedBox(height: XSizes.spaceBtwItems),
              XTextField(controller: controller.email, label: 'Email', hint: 'email@example.com', prefixIcon: Iconsax.direct_right),
              const SizedBox(height: XSizes.spaceBtwItems),
              XTextField(controller: controller.address, label: 'Address', hint: 'Full address', prefixIcon: Iconsax.location, maxLines: 2),
              const SizedBox(height: XSizes.spaceBtwItems),
              
              Obx(() {
                final availableSeats = controller.seatsController.allSeats
                    .where((s) => s.status == 'available' || s.seatNumber == controller.seatId.value)
                    .toList();
                
                return XDropdownField<String>(
                  label: 'Assign Seat',
                  prefixIcon: Iconsax.grid_2,
                  value: controller.seatId.value.isEmpty ? null : controller.seatId.value,
                  items: availableSeats.map((seat) {
                    final statusText = seat.status == 'available' ? 'Available' : 'Assigned to this member';
                    return DropdownMenuItem(
                      value: seat.seatNumber, 
                      child: Text('${seat.seatNumber} ($statusText)')
                    );
                  }).toList(),
                  onChanged: (v) => controller.seatId.value = v.toString(),
                );
              }),
              const SizedBox(height: XSizes.spaceBtwItems),

              XTextField(controller: controller.notes, label: 'Notes', hint: 'Any notes', prefixIcon: Iconsax.note_1, maxLines: 3),
              const SizedBox(height: XSizes.spaceBtwSections),

              Obx(() => XPrimaryButton(
                text: 'Save Changes',
                isLoading: controller.isLoading.value,
                onPressed: () => controller.saveChanges(),
              )),
              const SizedBox(height: XSizes.spaceBtwItems),
            ],
          ),
        ),
      ),
    );
  }
}
