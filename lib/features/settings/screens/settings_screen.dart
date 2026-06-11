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
import 'package:edox_library/features/settings/controllers/settings_cubit.dart';
import 'package:edox_library/routes/app_routes.dart';
import 'package:edox_library/features/subscription/controllers/subscription_cubit.dart';

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
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settingsState) {
                  bool whatsappVal = true;
                  bool smsVal = false;
                  List<int> reminderDays = [7, 5, 3, 1];

                  if (settingsState is SettingsLoaded) {
                    whatsappVal = settingsState.settings.whatsappEnabled;
                    smsVal = settingsState.settings.smsEnabled;
                    reminderDays = settingsState.settings.reminderDays;
                  }

                  final daysLabel = reminderDays.map((d) => d == 0 ? 'Expiry day' : '$d days').join(', ');
                  final reminderSubtitle = daysLabel.isEmpty ? 'No reminder days' : '$daysLabel before expiry';

                  return _SettingsSection(
                    title: 'Notifications',
                    dark: dark,
                    children: [
                      _SettingsTile(
                        icon: Iconsax.message,
                        title: 'WhatsApp Reminders',
                        subtitle: 'Send expiry reminders via WhatsApp',
                        dark: dark,
                        trailing: Switch(
                          value: whatsappVal,
                          activeColor: XColors.primary,
                          onChanged: settingsState is SettingsLoaded
                              ? (v) => context.read<SettingsCubit>().toggleWhatsApp(v)
                              : null,
                        ),
                      ),
                      _SettingsTile(
                        icon: Iconsax.sms,
                        title: 'SMS Reminders',
                        subtitle: 'Send expiry reminders via SMS',
                        dark: dark,
                        trailing: Switch(
                          value: smsVal,
                          activeColor: XColors.primary,
                          onChanged: settingsState is SettingsLoaded
                              ? (v) => context.read<SettingsCubit>().toggleSMS(v)
                              : null,
                        ),
                      ),
                      _SettingsTile(
                        icon: Iconsax.notification,
                        title: 'Reminder Settings',
                        subtitle: reminderSubtitle,
                        dark: dark,
                        onTap: settingsState is SettingsLoaded
                            ? () => _showReminderDaysDialog(context, reminderDays, dark)
                            : null,
                      ),
                    ],
                  );
                },
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
                    subtitle: 'Change your account password', 
                    dark: dark, 
                    onTap: () => _showChangePasswordDialog(context, dark),
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
                  BlocBuilder<SubscriptionCubit, SubscriptionState>(
                    builder: (context, subState) {
                      String planLabel = 'Loading...';
                      if (subState is SubscriptionLoaded) {
                        final sub = subState.subscription;
                        planLabel = '${sub.planName} Plan - ${sub.daysRemaining} days remaining';
                      } else if (subState is SubscriptionFailure) {
                        planLabel = 'Error loading subscription';
                      }
                      return _SettingsTile(
                        icon: Iconsax.crown_1, 
                        title: 'Subscription', 
                        subtitle: planLabel, 
                        dark: dark, 
                        onTap: () => Navigator.pushNamed(context, XRoutes.subscription),
                      );
                    },
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

  void _showChangePasswordDialog(BuildContext context, bool dark) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return AlertDialog(
              backgroundColor: dark ? const Color(0xFF0B1437) : XColors.white,
              title: Row(
                children: [
                  const Icon(Iconsax.password_check, color: XColors.primary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Change Password',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dark ? XColors.white : XColors.textPrimary,
                        ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Please enter your current password to verify your identity, then choose a new password.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: dark ? XColors.softGrey : XColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          prefixIcon: const Icon(Iconsax.key),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Current password is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Iconsax.lock),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'New password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: const Icon(Iconsax.lock_1),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() => isLoading = true);
                          try {
                            await AuthenticationRepository.instance.updatePassword(
                              currentPasswordController.text,
                              newPasswordController.text,
                            );
                            Navigator.pop(dialogContext);
                            XHelperFunctions.showSnackBar('Password updated successfully!');
                          } catch (e) {
                            setDialogState(() => isLoading = false);
                            XHelperFunctions.showSnackBar(e.toString(), isError: true);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: XColors.primary,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: XColors.white,
                          ),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showReminderDaysDialog(BuildContext parentContext, List<int> currentDays, bool dark) {
    final availableDays = [10, 7, 5, 3, 2, 1, 0];
    final selectedDays = List<int>.from(currentDays);

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return AlertDialog(
              backgroundColor: dark ? const Color(0xFF0B1437) : XColors.white,
              title: Text(
                'Select Reminder Days',
                style: Theme.of(parentContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dark ? XColors.white : XColors.textPrimary,
                    ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: availableDays.map((day) {
                  final isSelected = selectedDays.contains(day);
                  final label = day == 0 ? 'On Expiry Day' : '$day Days Before';
                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(
                      label,
                      style: TextStyle(color: dark ? XColors.softGrey : XColors.textPrimary),
                    ),
                    activeColor: XColors.primary,
                    onChanged: (val) {
                      setDialogState(() {
                        if (val == true) {
                          selectedDays.add(day);
                          selectedDays.sort((a, b) => b.compareTo(a));
                        } else {
                          selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    parentContext.read<SettingsCubit>().updateReminderDays(selectedDays);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
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
                    Text('Select Slot / Shift', style: Theme.of(parentContext).textTheme.headlineSmall),
                  ],
                ),
                const SizedBox(height: XSizes.spaceBtwItems),
                Flexible(
                  child: BlocBuilder<SlotsCubit, SlotsState>(
                    builder: (context, slotState) {
                      final List<SlotModel> displaySlots = slotState.slots;

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
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(sheetContext);
                                          _showEditSlotBottomSheet(parentContext, slot, dark);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          child: Icon(Iconsax.edit, color: XColors.primary, size: 20),
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

  void _showEditSlotBottomSheet(BuildContext parentContext, SlotModel slot, bool dark) {
    final nameCtrl = TextEditingController(text: slot.name);
    final startCtrl = TextEditingController(text: slot.startTime);
    final endCtrl = TextEditingController(text: slot.endTime);
    final formKey = GlobalKey<FormState>();

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
                      Text('Adjust Shift Timing', style: Theme.of(sheetContext).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text('Edit the start and end times for this predefined shift.', style: Theme.of(sheetContext).textTheme.bodySmall),
                      const SizedBox(height: XSizes.spaceBtwSections),
                      XTextField(
                        controller: nameCtrl,
                        label: 'Shift Name',
                        prefixIcon: Iconsax.edit,
                        enabled: false,
                        readOnly: true,
                      ),
                      const SizedBox(height: XSizes.spaceBtwItems),
                      XTextField(
                        controller: startCtrl,
                        label: 'Start Time',
                        hint: 'Select Start Time',
                        prefixIcon: Iconsax.clock,
                        readOnly: true,
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: sheetContext,
                            initialTime: const TimeOfDay(hour: 7, minute: 0),
                          );
                          if (picked != null) {
                            final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
                            final minute = picked.minute.toString().padLeft(2, '0');
                            final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
                            startCtrl.text = '$hour:$minute $period';
                          }
                        },
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please select start time' : null,
                      ),
                      const SizedBox(height: XSizes.spaceBtwItems),
                      XTextField(
                        controller: endCtrl,
                        label: 'End Time',
                        hint: 'Select End Time',
                        prefixIcon: Iconsax.clock,
                        readOnly: true,
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: sheetContext,
                            initialTime: const TimeOfDay(hour: 14, minute: 0),
                          );
                          if (picked != null) {
                            final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
                            final minute = picked.minute.toString().padLeft(2, '0');
                            final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
                            endCtrl.text = '$hour:$minute $period';
                          }
                        },
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please select end time' : null,
                      ),
                      const SizedBox(height: XSizes.spaceBtwSections),
                      XPrimaryButton(
                        text: 'Save Changes',
                        icon: Iconsax.tick_circle,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final updatedSlot = slot.copyWith(
                            startTime: startCtrl.text.trim(),
                            endTime: endCtrl.text.trim(),
                            updatedAt: DateTime.now(),
                          );
                          final success = await sheetContext.read<SlotsCubit>().updateSlot(
                            parentContext,
                            updatedSlot,
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
