import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);
    final reminders = _getMockReminders();

    return Scaffold(
      appBar: const XAppBar(title: Text('Reminders')),
      body: Padding(
        padding: const EdgeInsets.all(XSizes.defaultSpace),
        child: Column(
          children: [
            /// --- Quick Send
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(XSizes.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF25D366), Color(0xFF128C7E)]),
                borderRadius: BorderRadius.circular(XSizes.cardRadiusLg),
              ),
              child: Column(
                children: [
                  const Text('Bulk Reminder', style: TextStyle(color: XColors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text('Send reminders to all expiring members', style: TextStyle(color: XColors.white.withValues(alpha: 0.8), fontSize: 13)),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.snackbar('Sent!', 'WhatsApp reminders sent to 3 members', snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF25D366), colorText: XColors.white);
                          },
                          icon: const Icon(Iconsax.message, size: 18),
                          label: const Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(backgroundColor: XColors.white, foregroundColor: const Color(0xFF25D366)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.snackbar('Sent!', 'SMS reminders sent to 3 members', snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.primary, colorText: XColors.white);
                          },
                          icon: const Icon(Iconsax.sms, size: 18),
                          label: const Text('SMS'),
                          style: ElevatedButton.styleFrom(backgroundColor: XColors.white.withValues(alpha: 0.2), foregroundColor: XColors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: XSizes.spaceBtwSections),

            /// --- Expiring Members
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expiring Soon', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: XColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${reminders.length} members', style: const TextStyle(color: XColors.warning, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: XSizes.spaceBtwItems),

            /// --- List
            Expanded(
              child: ListView.separated(
                itemCount: reminders.length,
                separatorBuilder: (_, __) => const SizedBox(height: XSizes.sm + 2),
                itemBuilder: (context, index) {
                  final r = reminders[index];
                  return Container(
                    padding: const EdgeInsets.all(XSizes.md),
                    decoration: BoxDecoration(
                      color: dark ? XColors.darkCardBackground : XColors.white,
                      borderRadius: BorderRadius.circular(XSizes.cardRadiusMd),
                      boxShadow: [BoxShadow(color: XColors.primary.withValues(alpha: 0.04), blurRadius: 12)],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: XColors.warning.withValues(alpha: 0.1),
                          child: Text(r['name']![0], style: const TextStyle(color: XColors.warning, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text('Expires in ${r['days']} days • Seat ${r['seat']}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Get.snackbar('Sent!', 'Reminder sent to ${r['name']}', snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF25D366), colorText: XColors.white);
                          },
                          icon: const Icon(Iconsax.message, color: Color(0xFF25D366), size: 22),
                        ),
                        IconButton(
                          onPressed: () {
                            Get.snackbar('Sent!', 'SMS sent to ${r['name']}', snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.primary, colorText: XColors.white);
                          },
                          icon: const Icon(Iconsax.sms, color: XColors.primary, size: 22),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Map<String, String>> _getMockReminders() {
  return [
    {'name': 'Priya Patel', 'days': '5', 'seat': 'A-02', 'mobile': '9876543211'},
    {'name': 'Vikash Gupta', 'days': '2', 'seat': 'B-03', 'mobile': '9876543214'},
    {'name': 'Rohit Mehra', 'days': '7', 'seat': 'C-02', 'mobile': '9876543220'},
  ];
}
