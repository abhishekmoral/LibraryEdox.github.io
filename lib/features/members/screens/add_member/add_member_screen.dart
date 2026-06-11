import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/constants/text_strings.dart';
import 'package:edox_library/utils/validators/validation.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';
import 'package:edox_library/common/widgets/inputs/dropdown_field.dart';

import 'package:edox_library/features/members/controllers/add_member_cubit.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/features/seats/controllers/seats_cubit.dart';

class AddMemberScreen extends StatelessWidget {
  const AddMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddMemberCubit(),
      child: const _AddMemberForm(),
    );
  }
}

class _AddMemberForm extends StatefulWidget {
  const _AddMemberForm();

  @override
  State<_AddMemberForm> createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<_AddMemberForm> {
  final fullName = TextEditingController();
  final mobile = TextEditingController();
  final alternateMobile = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final notes = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final feeController = TextEditingController(text: '1500');
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final future = now.add(const Duration(days: 30));
    startDateController.text = _formatDate(now);
    endDateController.text = _formatDate(future);
  }

  @override
  void dispose() {
    fullName.dispose();
    mobile.dispose();
    alternateMobile.dispose();
    email.dispose();
    address.dispose();
    notes.dispose();
    startDateController.dispose();
    endDateController.dispose();
    feeController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final cubit = context.read<AddMemberCubit>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.joiningDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      cubit.setJoiningDate(picked);
      setState(() {
        startDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final cubit = context.read<AddMemberCubit>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.expiryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      cubit.setExpiryDate(picked);
      setState(() {
        endDateController.text = _formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch slots and seats so they reactively update
    final slotsCubit = context.watch<SlotsCubit>();
    final seatsCubit = context.watch<SeatsCubit>();

    return Scaffold(
      appBar: const XAppBar(title: Text('Add Member')),
      body: BlocBuilder<AddMemberCubit, AddMemberState>(
        builder: (context, state) {
          final actualSlots = slotsCubit.state.slots;

          final allSeatsForSlot = seatsCubit.getResolvedSeatsForSlot(state.selectedSlotId);
          // Keep only seats that are free (not occupied and not under maintenance)
          final availableSeats = allSeatsForSlot.where((s) => !s.isOccupied && s.status != 'maintenance').toList();

          // Reset selection if the previously chosen seat is no longer available
          final currentSeat = state.seatId;
          if (currentSeat.isNotEmpty) {
            final chosenSeat = availableSeats.firstWhereOrNull((s) => s.seatNumber == currentSeat);
            if (chosenSeat == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<AddMemberCubit>().setSeatId('');
              });
            }
          }

          final seatDropdownValue = currentSeat.isNotEmpty &&
                  availableSeats.any((s) => s.seatNumber == currentSeat)
              ? currentSeat
              : ''; // '' represents Unassigned

          return SingleChildScrollView(
            padding: const EdgeInsets.all(XSizes.defaultSpace),
            child: Form(
              key: formKey,
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
                  const Text('Add Photo', style: TextStyle(color: XColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: XSizes.spaceBtwSections),

                  XTextField(controller: fullName, label: XTexts.xFullName, hint: 'Enter full name', prefixIcon: Iconsax.user, validator: XValidator.validateName),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(controller: mobile, label: XTexts.xMobileNumber, hint: '10-digit mobile', prefixIcon: Iconsax.call, keyboardType: TextInputType.phone, validator: XValidator.validatePhone),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(controller: alternateMobile, label: 'Alternate Number', hint: 'Optional', prefixIcon: Iconsax.call_add),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(controller: email, label: XTexts.xEmail, hint: 'email@example.com', prefixIcon: Iconsax.direct_right, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(controller: address, label: XTexts.xAddress, hint: 'Full address', prefixIcon: Iconsax.location, maxLines: 2),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  XDropdownField<String>(
                    label: 'Gender',
                    prefixIcon: Iconsax.user,
                    value: state.gender,
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) {
                      if (v != null) context.read<AddMemberCubit>().setGender(v);
                    },
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  XDropdownField<String>(
                    label: 'Slot / Shift',
                    prefixIcon: Iconsax.clock,
                    value: state.selectedSlotId,
                    items: actualSlots.map((slot) {
                      return DropdownMenuItem(
                        value: slot.id,
                        child: Text('${slot.name} (${slot.startTime} - ${slot.endTime})'),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        context.read<AddMemberCubit>().setSelectedSlotId(v);
                      }
                    },
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  XTextField(
                    controller: startDateController,
                    label: 'Start Date',
                    prefixIcon: Iconsax.calendar,
                    readOnly: true,
                    onTap: () => _selectStartDate(context),
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  XTextField(
                    controller: endDateController,
                    label: 'End Date',
                    prefixIcon: Iconsax.calendar,
                    readOnly: true,
                    onTap: () => _selectEndDate(context),
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  XTextField(
                    controller: feeController,
                    label: 'Fee Amount (₹)',
                    hint: 'Enter fee amount',
                    prefixIcon: Iconsax.wallet_3,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a fee amount';
                      }
                      if (double.tryParse(val.trim()) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  XDropdownField<String>(
                    label: 'Assign Seat',
                    prefixIcon: Iconsax.grid_2,
                    value: seatDropdownValue,
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text(
                          'Unassigned (No Seat)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: XColors.textSecondary,
                          ),
                        ),
                      ),
                      ...availableSeats.map((seat) {
                        final freeSlotNames = seatsCubit.getFreeSlotNamesForSeat(seat.seatNumber);
                        String freeText;
                        if (freeSlotNames.length == slotsCubit.state.slots.length) {
                          freeText = 'All Shifts';
                        } else {
                          freeText = freeSlotNames.join(', ');
                        }
                        final labelText = '${seat.seatNumber} (Free: $freeText)';

                        return DropdownMenuItem(
                          value: seat.seatNumber, 
                          child: Text(
                            labelText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      if (v.isEmpty) {
                        context.read<AddMemberCubit>().setSeatId('');
                        return;
                      }
                      final chosenSeat = availableSeats.firstWhereOrNull((s) => s.seatNumber == v);
                      if (chosenSeat == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Seat $v is already occupied or under maintenance.'),
                            backgroundColor: XColors.error,
                          ),
                        );
                        return;
                      }
                      context.read<AddMemberCubit>().setSeatId(v);
                    },
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  XDropdownField<String>(
                    label: 'Payment Method',
                    prefixIcon: Iconsax.money_recive,
                    value: state.paymentMethod,
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'upi', child: Text('UPI')),
                      DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                    ],
                    onChanged: (v) {
                      if (v != null) context.read<AddMemberCubit>().setPaymentMethod(v);
                    },
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  XTextField(controller: notes, label: 'Notes', hint: 'Any additional notes', prefixIcon: Iconsax.note_1, maxLines: 3),
                  const SizedBox(height: XSizes.spaceBtwSections),

                  XPrimaryButton(
                    text: 'Add Member',
                    isLoading: state.isLoading,
                    icon: Iconsax.user_add,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<AddMemberCubit>().saveMember(
                          context,
                          fullName: fullName.text,
                          mobile: mobile.text,
                          alternateMobile: alternateMobile.text,
                          email: email.text,
                          address: address.text,
                          notes: notes.text,
                          fee: double.parse(feeController.text.trim()),
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
