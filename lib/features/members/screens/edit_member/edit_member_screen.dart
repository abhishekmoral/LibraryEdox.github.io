import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/validators/validation.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';
import 'package:edox_library/common/widgets/inputs/dropdown_field.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/members/controllers/edit_member_cubit.dart';
import 'package:edox_library/features/seats/controllers/seats_cubit.dart';

class EditMemberScreen extends StatelessWidget {
  const EditMemberScreen({super.key, required this.member});
  final MemberModel member;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditMemberCubit()..initMemberData(member),
      child: const _EditMemberForm(),
    );
  }
}

class _EditMemberForm extends StatefulWidget {
  const _EditMemberForm();

  @override
  State<_EditMemberForm> createState() => _EditMemberFormState();
}

class _EditMemberFormState extends State<_EditMemberForm> {
  late TextEditingController fullName;
  late TextEditingController mobile;
  late TextEditingController alternateMobile;
  late TextEditingController email;
  late TextEditingController address;
  late TextEditingController notes;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final editCubit = context.read<EditMemberCubit>();
    fullName = TextEditingController(text: editCubit.originalMember.fullName);
    mobile = TextEditingController(text: editCubit.originalMember.mobile);
    alternateMobile = TextEditingController(text: editCubit.originalMember.alternateMobile);
    email = TextEditingController(text: editCubit.originalMember.email);
    address = TextEditingController(text: editCubit.originalMember.address);
    notes = TextEditingController(text: editCubit.originalMember.notes);
  }

  @override
  void dispose() {
    fullName.dispose();
    mobile.dispose();
    alternateMobile.dispose();
    email.dispose();
    address.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seatsCubit = context.watch<SeatsCubit>();
    final editCubit = context.read<EditMemberCubit>();

    return Scaffold(
      appBar: const XAppBar(title: Text('Edit Member')),
      body: BlocBuilder<EditMemberCubit, EditMemberState>(
        builder: (context, state) {
          final memberSlotId = editCubit.originalMember.slotId;
          final allSeats = seatsCubit.getResolvedSeatsForSlot(memberSlotId, excludeMemberId: editCubit.originalMember.id);
          
          // Keep only seats that are free (not occupied by anyone else and not under maintenance)
          final availableSeats = allSeats.where((s) => !s.isOccupied && s.status != 'maintenance').toList();

          // Ensure dropdown value is valid (selectable)
          final currentSeat = state.seatId;
          final seatDropdownValue = currentSeat.isNotEmpty &&
                  availableSeats.any((s) => s.seatNumber == currentSeat)
              ? currentSeat
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(XSizes.defaultSpace),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: XColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      editCubit.originalMember.fullName.isNotEmpty ? editCubit.originalMember.fullName[0].toUpperCase() : '?', 
                      style: const TextStyle(color: XColors.primary, fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: XSizes.spaceBtwSections),

                  XTextField(controller: fullName, label: 'Full Name', hint: 'Enter full name', prefixIcon: Iconsax.user, validator: XValidator.validateName),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(controller: mobile, label: 'Mobile', hint: '10-digit mobile', prefixIcon: Iconsax.call, keyboardType: TextInputType.phone, validator: XValidator.validatePhone),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(controller: alternateMobile, label: 'Alternate Mobile', hint: 'Optional', prefixIcon: Iconsax.call_add, keyboardType: TextInputType.phone),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(controller: email, label: 'Email', hint: 'email@example.com', prefixIcon: Iconsax.direct_right),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(controller: address, label: 'Address', hint: 'Full address', prefixIcon: Iconsax.location, maxLines: 2),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  XDropdownField<String>(
                    label: 'Assign Seat',
                    prefixIcon: Iconsax.grid_2,
                    value: seatDropdownValue,
                    items: availableSeats.map((seat) {
                      final freeSlots = seatsCubit.getFreeSlotNamesForSeat(
                        seat.seatNumber,
                        excludeMemberId: editCubit.originalMember.id,
                      );
                      final isCurrentSeat = seat.seatNumber == editCubit.originalMember.seatNumber;
                      final labelText = isCurrentSeat
                          ? '${seat.seatNumber} (Current Seat - Free: ${freeSlots.join(", ")})'
                          : '${seat.seatNumber} (Free: ${freeSlots.join(", ")})';

                      return DropdownMenuItem(
                        value: seat.seatNumber, 
                        child: Text(
                          labelText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      final chosenSeat = availableSeats.firstWhereOrNull((s) => s.seatNumber == v);
                      if (chosenSeat == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Seat $v is already occupied or in maintenance.'),
                            backgroundColor: XColors.error,
                          ),
                        );
                        return;
                      }
                      context.read<EditMemberCubit>().setSeatId(v);
                    },
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  XTextField(controller: notes, label: 'Notes', hint: 'Any notes', prefixIcon: Iconsax.note_1, maxLines: 3),
                  const SizedBox(height: XSizes.spaceBtwSections),

                  XPrimaryButton(
                    text: 'Save Changes',
                    isLoading: state.isLoading,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<EditMemberCubit>().saveChanges(
                          context,
                          fullName: fullName.text,
                          mobile: mobile.text,
                          alternateMobile: alternateMobile.text,
                          email: email.text,
                          address: address.text,
                          notes: notes.text,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
