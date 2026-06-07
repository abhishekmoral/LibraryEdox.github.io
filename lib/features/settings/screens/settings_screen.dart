import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/constants/text_strings.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/personalization/controllers/library_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);
    final controller = Get.put(LibraryController());

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
              
              Obx(() {
                if (controller.profileLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final library = controller.library.value;
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
              }),
              
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
                        Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
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
                  _SettingsTile(icon: Iconsax.money_recive, title: 'Payments', subtitle: 'View payments & collect fees', dark: dark, onTap: () => Get.toNamed('/payments')),
                  _SettingsTile(icon: Iconsax.calendar_1, title: 'Plans', subtitle: 'Manage membership plans', dark: dark, onTap: () => Get.toNamed('/plans')),
                  _SettingsTile(icon: Iconsax.notification, title: 'Reminders', subtitle: 'Send WhatsApp & SMS reminders', dark: dark, onTap: () => Get.toNamed('/reminders')),
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
                        final email = AuthenticationRepository.instance.authUser.value?.email;
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
                    onTap: () => Get.toNamed('/subscription')
                  ),
                ],
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Logout
              SizedBox(
                width: double.infinity,
                height: XSizes.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: () => Get.offAllNamed('/login'),
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
