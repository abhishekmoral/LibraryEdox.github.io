import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/constants/text_strings.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/personalization/controllers/library_cubit.dart';
import 'package:edox_library/features/authentication/models/library_model.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/features/slots/models/slot_model.dart';
import 'package:edox_library/features/settings/controllers/theme_cubit.dart';
import 'package:edox_library/routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? XColors.dark : XColors.light,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(XSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Library Information Section
              Text(
                XTexts.xLibraryInfo,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dark ? XColors.white : XColors.black,
                    ),
              ),
              const SizedBox(height: XSizes.spaceBtwItems),
              
              BlocBuilder<LibraryCubit, LibraryState>(
                builder: (context, state) {
                  if (state is LibraryLoading || state is LibraryInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final library = state is LibraryLoaded ? state.library : LibraryModel.empty();
                  return Container(
                    padding: const EdgeInsets.all(XSizes.md),
                    decoration: BoxDecoration(
                      color: dark ? XColors.darkCardBackground : XColors.white,
                      borderRadius: BorderRadius.circular(XSizes.cardRadiusLg),
                    ),
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Iconsax.building,
                          title: 'Library Name',
                          subtitle: library.libraryName.isNotEmpty ? library.libraryName : 'EdoxLibrary',
                          dark: dark,
                        ),
                        _SettingsTile(
                          icon: Iconsax.user,
                          title: 'Owner Name',
                          subtitle: library.ownerName.isNotEmpty ? library.ownerName : 'Admin',
                          dark: dark,
                        ),
                        _SettingsTile(
                          icon: Iconsax.call,
                          title: 'Mobile',
                          subtitle: library.mobile.isNotEmpty ? library.mobile : 'Not provided',
                          dark: dark,
                        ),
                        _SettingsTile(
                          icon: Iconsax.direct_right,
                          title: 'Email',
                          subtitle: library.email.isNotEmpty ? library.email : 'Not provided',
                          dark: dark,
                        ),
                        _SettingsTile(
                          icon: Iconsax.location,
                          title: 'Address',
                          subtitle: library.address.isNotEmpty ? library.address : 'Not provided',
                          dark: dark,
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: XSizes.spaceBtwSections),

              /// --- Theme
              _SettingsSection(
                title: 'Appearance',
                dark: dark,
                children: [
                  _SettingsTile(
                    icon: dark ? Iconsax.moon : Iconsax.sun_1,
                    title: 'Theme',
                    subtitle: dark ? 'Dark Mode' : 'Light Mode',
                    dark: dark,
                    trailing: Switch(
                      value: dark,
                      activeColor: XColors.primary,
                      onChanged: (val) {
                        context.read<ThemeCubit>().toggleTheme(val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Notifications
              _SettingsSection(
                title: 'Notifications',
                dark: dark,
                children: [
                  _SettingsTile(
                    icon: Iconsax.message,
                    title: 'WhatsApp Reminders',
                    subtitle: 'Send expiry reminders via WhatsApp',
                    dark: dark,
                    trailing: Switch(value: true, activeColor: XColors.primary, onChanged: (v) {}),
                  ),
                  _SettingsTile(
                    icon: Iconsax.sms,
                    title: 'SMS Reminders',
                    subtitle: 'Send expiry reminders via SMS',
                    dark: dark,
                    trailing: Switch(value: false, activeColor: XColors.primary, onChanged: (v) {}),
                  ),
                  _SettingsTile(icon: Iconsax.notification, title: 'Reminder Settings', subtitle: '7, 5, 3, 1 days before expiry', dark: dark, onTap: () {}),
                ],
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Management
              _SettingsSection(
                title: 'Management',
                dark: dark,
                children: [
                  _SettingsTile(
                    icon: Iconsax.money_recive, 
                    title: 'Payments', 
                    subtitle: 'View payments & collect fees', 
                    dark: dark, 
                    onTap: () => Navigator.pushNamed(context, XRoutes.payments),
                  ),
                  _SettingsTile(
                    icon: Iconsax.calendar_1, 
                    title: 'Plans', 
                    subtitle: 'Manage membership plans', 
                    dark: dark, 
                    onTap: () => Navigator.pushNamed(context, XRoutes.plans),
                  ),
                  _SettingsTile(
                    icon: Iconsax.notification, 
                    title: 'Reminders', 
                    subtitle: 'Send WhatsApp & SMS reminders', 
                    dark: dark, 
                    onTap: () => Navigator.pushNamed(context, XRoutes.reminders),
                  ),
                  BlocBuilder<SlotsCubit, SlotsState>(
                    builder: (context, slotState) {
                      final activeSlot = slotState.selectedSlot.name;
                      return _SettingsTile(
                        icon: Iconsax.clock,
                        title: 'Slots / Shifts',
                        subtitle: 'Active: $activeSlot',
                        dark: dark,
                        onTap: () => _showSlotsBottomSheet(context, dark),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Account
              _SettingsSection(
                title: 'Account',
                dark: dark,
                children: [
                  _SettingsTile(
                    icon: Iconsax.password_check, 
                    title: 'Change Password', 
                    subtitle: 'Send a password reset email', 
                    dark: dark, 
                    onTap: () async {
                      try {
                        final email = AuthenticationRepository.instance.currentUser?.email;
                        if (email != null && email.isNotEmpty) {
                          await AuthenticationRepository.instance.sendPasswordResetEmail(email);
                          XHelperFunctions.showSnackBar('Password Reset Email Sent! Check your inbox.');
                        } else {
                          XHelperFunctions.showSnackBar('Error: No email associated with this account.', isError: true);
                        }
                      } catch (e) {
                        XHelperFunctions.showSnackBar('Error: ${e.toString()}', isError: true);
                      }
                    }
                  ),
                  _SettingsTile(
                    icon: Iconsax.cloud, 
                    title: 'Backup', 
                    subtitle: 'Cloud backup your data', 
                    dark: dark, 
                    onTap: () {
                      XHelperFunctions.showSnackBar(
                        'Cloud Sync Active: Your library data is automatically backed up and synced to the cloud in real-time!'
                      );
                    }
                  ),
                  _SettingsTile(
                    icon: Iconsax.crown_1, 
                    title: 'Subscription', 
                    subtitle: 'Trial Plan - 30 days remaining', 
                    dark: dark, 
                    onTap: () => Navigator.pushNamed(context, XRoutes.subscription),
                  ),
                ],
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Logout
              SizedBox(
                width: double.infinity,
                height: XSizes.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthenticationRepository.instance.logout();
                  },
                  icon: const Icon(Iconsax.logout, color: XColors.error),
                  label: const Text('Logout', style: TextStyle(color: XColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: XColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(XSizes.borderRadiusLg)),
                  ),
                ),
              ),
              const SizedBox(height: XSizes.spaceBtwSections),

              /// --- App Version
              Center(
                child: Text('EdoxLibrary v1.0.0', style: Theme.of(context).textTheme.labelSmall),
              ),
              const SizedBox(height: XSizes.spaceBtwItems),
            ],
          ),
        ),
      ),
    );
  }

  void _showSlotsBottomSheet(BuildContext parentContext, bool dark) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: parentContext.read<SlotsCubit>(),
          child: Container(
            padding: const EdgeInsets.all(XSizes.defaultSpace),
            decoration: BoxDecoration(
              color: Theme.of(parentContext).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: XColors.softGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: XSizes.spaceBtwItems),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Slot', style: Theme.of(parentContext).textTheme.headlineSmall),
                    IconButton(
                      onPressed: () {
                        final slotsCubit = parentContext.read<SlotsCubit>();
                        final completeDayCount = slotsCubit.state.slots.where((s) => s.startTime == '12:00 AM' && s.endTime == '11:59 PM').length;
                        final standardCount = slotsCubit.state.slots.length - completeDayCount;

                        if (standardCount >= 3 && completeDayCount >= 1) {
                          XHelperFunctions.showSnackBar(
                            'Maximum of 3 custom timing slots and 1 complete day slot have been created.',
                            isError: true,
                          );
                        } else {
                          Navigator.pop(sheetContext);
                          _showCreateSlotBottomSheet(parentContext, dark);
                        }
                      },
                      icon: const Icon(Iconsax.add_circle, color: XColors.primary, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: XSizes.spaceBtwItems),
                Flexible(
                  child: BlocBuilder<SlotsCubit, SlotsState>(
                    builder: (context, slotState) {
                      final List<SlotModel> displaySlots = [
                        SlotModel(
                          id: 'default',
                          name: 'Complete',
                          startTime: '12:00 AM',
                          endTime: '11:59 PM',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                        ...slotState.slots,
                      ];

                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: displaySlots.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final slot = displaySlots[index];
                          final isSelected = slotState.selectedSlotId == slot.id;

                          return GestureDetector(
                            onTap: () {
                              context.read<SlotsCubit>().selectSlot(slot);
                              Navigator.pop(sheetContext);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? XColors.primary.withValues(alpha: 0.1)
                                    : (dark ? XColors.darkCardBackground : XColors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? XColors.primary
                                      : (dark ? XColors.darkGrey.withValues(alpha: 0.3) : XColors.borderPrimary),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          slot.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? XColors.primary
                                                : (dark ? XColors.white : XColors.textPrimary),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${slot.startTime} - ${slot.endTime}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: XColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (slot.id != 'all' && slot.id != 'default')
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (dialogContext) {
                                                return AlertDialog(
                                                  title: const Text('Delete Slot'),
                                                  content: Text('Are you sure you want to delete the slot "${slot.name}"?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(dialogContext),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        context.read<SlotsCubit>().deleteSlot(context, slot.id);
                                                        Navigator.pop(dialogContext);
                                                      },
                                                      style: ElevatedButton.styleFrom(backgroundColor: XColors.error),
                                                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8),
                                            child: Icon(Iconsax.trash, color: XColors.error, size: 20),
                                          ),
                                        ),
                                      if (isSelected)
                                        const Icon(Iconsax.tick_circle, color: XColors.primary),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: XSizes.spaceBtwSections),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateSlotBottomSheet(BuildContext parentContext, bool dark) {
    final nameCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isWholeDayNotifier = ValueNotifier<bool>(false);

    // Listen to changes on isWholeDayNotifier to pre-fill or clear time fields
    isWholeDayNotifier.addListener(() {
      final val = isWholeDayNotifier.value;
      if (val) {
        startCtrl.text = '12:00 AM';
        endCtrl.text = '11:59 PM';
      } else {
        startCtrl.clear();
        endCtrl.clear();
      }
    });

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: parentContext.read<SlotsCubit>(),
          child: Container(
            padding: const EdgeInsets.all(XSizes.defaultSpace),
            decoration: BoxDecoration(
              color: Theme.of(parentContext).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: XColors.softGrey,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: XSizes.spaceBtwItems),
                      Text('Create Custom Slot', style: Theme.of(sheetContext).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text('Specify Gym slot timing and name', style: Theme.of(sheetContext).textTheme.bodySmall),
                      const SizedBox(height: XSizes.spaceBtwSections),
                      XTextField(
                        controller: nameCtrl,
                        label: 'Slot Name',
                        hint: 'e.g. Morning, Afternoon, Evening',
                        prefixIcon: Iconsax.edit,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter slot name' : null,
                      ),
                      const SizedBox(height: XSizes.spaceBtwItems),
                      ValueListenableBuilder<bool>(
                        valueListenable: isWholeDayNotifier,
                        builder: (context, isWholeDay, _) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: dark ? XColors.borderPrimary : XColors.borderSecondary),
                              borderRadius: BorderRadius.circular(XSizes.inputFieldRadius),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Iconsax.calendar_1, color: dark ? XColors.white : XColors.black),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Whole Day Timing', style: Theme.of(context).textTheme.titleSmall),
                                        Text('12:00 AM - 11:59 PM', style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: isWholeDay,
                                  activeColor: XColors.primary,
                                  onChanged: (val) => isWholeDayNotifier.value = val,
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: XSizes.spaceBtwItems),
                      ValueListenableBuilder<bool>(
                        valueListenable: isWholeDayNotifier,
                        builder: (context, isWholeDay, _) {
                          return XTextField(
                            controller: startCtrl,
                            label: 'Start Time',
                            hint: 'Select Start Time',
                            prefixIcon: Iconsax.clock,
                            readOnly: true,
                            enabled: !isWholeDay,
                            onTap: isWholeDay ? null : () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: const TimeOfDay(hour: 5, minute: 0),
                              );
                              if (picked != null) {
                                final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
                                final minute = picked.minute.toString().padLeft(2, '0');
                                final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
                                startCtrl.text = '$hour:$minute $period';
                              }
                            },
                            validator: (v) => v == null || v.trim().isEmpty ? 'Please select start time' : null,
                          );
                        }
                      ),
                      const SizedBox(height: XSizes.spaceBtwItems),
                      ValueListenableBuilder<bool>(
                        valueListenable: isWholeDayNotifier,
                        builder: (context, isWholeDay, _) {
                          return XTextField(
                            controller: endCtrl,
                            label: 'End Time',
                            hint: 'Select End Time',
                            prefixIcon: Iconsax.clock,
                            readOnly: true,
                            enabled: !isWholeDay,
                            onTap: isWholeDay ? null : () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: const TimeOfDay(hour: 9, minute: 0),
                              );
                              if (picked != null) {
                                final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
                                final minute = picked.minute.toString().padLeft(2, '0');
                                final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
                                endCtrl.text = '$hour:$minute $period';
                              }
                            },
                            validator: (v) => v == null || v.trim().isEmpty ? 'Please select end time' : null,
                          );
                        }
                      ),
                      const SizedBox(height: XSizes.spaceBtwSections),
                      XPrimaryButton(
                        text: 'Create Slot',
                        icon: Iconsax.add,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final success = await sheetContext.read<SlotsCubit>().createSlot(
                            parentContext,
                            nameCtrl.text.trim(),
                            startCtrl.text.trim(),
                            endCtrl.text.trim(),
                          );
                          if (success) {
                            Navigator.pop(sheetContext);
                          }
                        },
                      ),
                      const SizedBox(height: XSizes.spaceBtwItems),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.dark, required this.children});
  final String title;
  final bool dark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: XSizes.sm),
        Container(
          decoration: BoxDecoration(
            color: dark ? XColors.darkCardBackground : XColors.white,
            borderRadius: BorderRadius.circular(XSizes.cardRadiusLg),
            boxShadow: [
              BoxShadow(
                color: dark ? Colors.black.withValues(alpha: 0.2) : XColors.primary.withValues(alpha: 0.04),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            children: List.generate(children.length, (i) {
              return Column(
                children: [
                  children[i],
                  if (i < children.length - 1)
                    Divider(height: 1, indent: 56, color: dark ? XColors.darkGrey.withValues(alpha: 0.3) : XColors.lightGrey),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.dark,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool dark;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: XColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: XColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: trailing ?? (onTap != null ? const Icon(Iconsax.arrow_right_3, size: 18) : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: XSizes.md, vertical: 2),
    );
  }
}
