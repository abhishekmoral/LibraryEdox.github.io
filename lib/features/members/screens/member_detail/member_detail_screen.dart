import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/common/widgets/containers/status_badge.dart';
import 'package:edox_library/common/widgets/containers/rounded_container.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/members/controllers/member_detail_controller.dart';
import 'package:edox_library/features/members/screens/edit_member/edit_member_screen.dart';

class MemberDetailScreen extends StatelessWidget {
  const MemberDetailScreen({super.key, required this.member});
  final MemberModel member;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberDetailController());
    final dark = XHelperFunctions.isDarkMode(context);
    
    return Scaffold(
      appBar: XAppBar(
        title: const Text('Member Details'),
        actions: [
          IconButton(onPressed: () => Get.to(() => EditMemberScreen(member: member)), icon: const Icon(Iconsax.edit)),
          IconButton(onPressed: () => controller.deleteMember(member), icon: const Icon(Iconsax.trash, color: XColors.error)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(XSizes.defaultSpace),
        child: Column(
          children: [
            /// --- Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(XSizes.defaultSpace),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [XColors.primary, XColors.primary.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(XSizes.cardRadiusLg),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: XColors.white.withValues(alpha: 0.2),
                    child: Text(member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(color: XColors.white, fontSize: 30, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: XSizes.sm),
                  Text(member.fullName, style: const TextStyle(color: XColors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(member.mobile, style: TextStyle(color: XColors.white.withValues(alpha: 0.8), fontSize: 14)),
                  const SizedBox(height: XSizes.sm),
                  XStatusBadge(
                    text: member.status.replaceAll('_', ' '),
                    color: XColors.white,
                    textColor: XColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: XSizes.spaceBtwItems),

            /// --- Action Buttons
            Row(
              children: [
                Expanded(child: _ActionBtn(icon: Iconsax.call, label: 'Call', color: XColors.accent, onTap: () {})),
                const SizedBox(width: 8),
                Expanded(child: _ActionBtn(icon: Iconsax.message, label: 'WhatsApp', color: const Color(0xFF25D366), onTap: () {})),
                const SizedBox(width: 8),
                Expanded(child: _ActionBtn(icon: Iconsax.sms, label: 'SMS', color: XColors.primary, onTap: () {})),
                const SizedBox(width: 8),
                Expanded(child: _ActionBtn(icon: Iconsax.notification, label: 'Remind', color: XColors.warning, onTap: () {})),
              ],
            ),
            const SizedBox(height: XSizes.spaceBtwSections),

            /// --- Membership Info
            _InfoSection(title: 'Membership', dark: dark, children: [
              _InfoRow('Plan', member.planName),
              _InfoRow('Joining Date', XHelperFunctions.formatDate(member.joiningDate)),
              _InfoRow('Expiry Date', XHelperFunctions.formatDate(member.expiryDate)),
              _InfoRow('Days Remaining', '${member.daysRemaining} days'),
              _InfoRow('Payment Status', member.paymentStatus.toUpperCase()),
            ]),
            const SizedBox(height: XSizes.spaceBtwItems),

            /// --- Seat Info
            _InfoSection(title: 'Seat Information', dark: dark, children: [
              _InfoRow('Seat Number', member.seatNumber.isEmpty ? 'Not Assigned' : member.seatNumber),
            ]),
            const SizedBox(height: XSizes.spaceBtwItems),

            /// --- Personal Info
            _InfoSection(title: 'Personal Details', dark: dark, children: [
              _InfoRow('Email', member.email.isEmpty ? 'N/A' : member.email),
              _InfoRow('Gender', member.gender.isEmpty ? 'N/A' : member.gender),
              _InfoRow('Address', member.address.isEmpty ? 'N/A' : member.address),
              if (member.notes.isNotEmpty) _InfoRow('Notes', member.notes),
            ]),
            const SizedBox(height: XSizes.spaceBtwSections),

            /// --- Renew Button
            Obx(() => XPrimaryButton(
              text: 'Renew Membership', 
              icon: Iconsax.refresh, 
              isLoading: controller.isRenewing.value,
              onPressed: () => controller.renewMembership(member)
            )),
            const SizedBox(height: XSizes.spaceBtwItems),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon; final String label; final Color color; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.dark, required this.children});
  final String title; final bool dark; final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: XSizes.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(XSizes.md),
          decoration: BoxDecoration(
            color: dark ? XColors.darkCardBackground : XColors.white,
            borderRadius: BorderRadius.circular(XSizes.cardRadiusMd),
            boxShadow: [BoxShadow(color: XColors.primary.withValues(alpha: 0.04), blurRadius: 12)],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label; final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
