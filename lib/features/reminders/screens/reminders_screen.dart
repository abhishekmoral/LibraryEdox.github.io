import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/data/services/whatsapp_service.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/common/widgets/empty_states/empty_state.dart';
import 'package:edox_library/features/personalization/controllers/library_cubit.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<MemberModel> _members = [];
  final Set<String> _selectedMemberIds = {};
  bool _isLoading = true;
  StreamSubscription? _membersSub;

  @override
  void initState() {
    super.initState();
    _membersSub = MemberRepository.instance.getAllMembersStream('all').listen((memberList) {
      if (mounted) {
        setState(() {
          _members = memberList;
          _isLoading = false;

          // Auto-select expiring members by default
          final expiringList = memberList.where((m) => m.isExpiringSoon).toList();
          for (final m in expiringList) {
            _selectedMemberIds.add(m.id);
          }
        });
      }
    }, onError: (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _membersSub?.cancel();
    super.dispose();
  }

  void _showMessageTemplateBottomSheet(BuildContext context, {required List<MemberModel> targetMembers, required bool isWhatsApp}) {
    final libraryCubit = locator<LibraryCubit>();
    String libName = 'Library';
    if (libraryCubit.state is LibraryLoaded) {
      libName = (libraryCubit.state as LibraryLoaded).library.libraryName;
    }
    if (libName.trim().isEmpty) {
      libName = 'Library';
    }

    final defaultTemplate = 'Dear {name},\n\n'
        'Your membership details at $libName:\n'
        '- Plan: {plan}\n'
        '- Seat: {seat}\n'
        '- Slot: {slot}\n'
        '- Expiry Date: {expiry_date}\n\n'
        'Please renew soon to keep your seat. Thank you!';
    final controller = TextEditingController(text: defaultTemplate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final dark = XHelperFunctions.isDarkMode(context);
        return Container(
          padding: const EdgeInsets.all(XSizes.defaultSpace),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0B1437) : XColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: XColors.softGrey, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  Text(
                    'Customize Message Template',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  
                  // Explanations about placeholders
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: XColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Use placeholders: {name}, {expiry_date}, {seat}, {slot}, {plan}, {library_name} to auto-fill details dynamically.',
                      style: TextStyle(
                        fontSize: 12,
                        color: dark ? XColors.softGrey : XColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  TextField(
                    controller: controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Write your message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: dark ? XColors.darkCardBackground : XColors.softGrey.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(height: XSizes.spaceBtwSections),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final templateText = controller.text.trim();
                            if (templateText.isEmpty) {
                              XHelperFunctions.showSnackBar('Message cannot be empty.', isError: true);
                              return;
                            }
                            
                            Navigator.pop(sheetContext); // Close sheet
                            
                            // Retrieve slots to resolve slot names
                            final slotsCubit = locator<SlotsCubit>();
                            final slotMap = {for (var s in slotsCubit.state.slots) s.id: s.name};
                            if (!slotMap.containsKey('default')) {
                              slotMap['default'] = 'Complete Shift';
                            }

                            // Build the final messages per member
                            int sentCount = 0;
                            try {
                              for (final m in targetMembers) {
                                final slotName = slotMap[m.slotId] ?? 'Complete Shift';
                                final expiryDateStr = XHelperFunctions.formatDate(m.expiryDate);
                                
                                String finalMsg = templateText
                                    .replaceAll('{name}', m.fullName)
                                    .replaceAll('{expiry_date}', expiryDateStr)
                                    .replaceAll('{seat}', m.seatNumber)
                                    .replaceAll('{slot}', slotName)
                                    .replaceAll('{plan}', m.planName)
                                    .replaceAll('{library_name}', libName);

                                if (isWhatsApp) {
                                  await WhatsAppService.sendMessage(m.mobile, finalMsg);
                                } else {
                                  await WhatsAppService.sendSMS(m.mobile, finalMsg);
                                }
                                sentCount++;
                                
                                // Small delay between sends to avoid rapid-fire URL launch issues
                                await Future.delayed(const Duration(milliseconds: 600));
                              }

                              XHelperFunctions.showSnackBar(
                                'Sent ${isWhatsApp ? "WhatsApp" : "SMS"} reminders to $sentCount member(s).',
                              );
                            } catch (e) {
                              XHelperFunctions.showSnackBar('Failed to send some messages: $e', isError: true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isWhatsApp ? const Color(0xFF25D366) : XColors.primary,
                          ),
                          child: Text('Send via ${isWhatsApp ? "WhatsApp" : "SMS"}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    // Filter for expiring soon members
    final expiringMembers = _members.where((m) => m.isExpiringSoon).toList();
    final selectedMembersList = expiringMembers.where((m) => _selectedMemberIds.contains(m.id)).toList();

    return Scaffold(
      appBar: const XAppBar(title: Text('Reminders')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(XSizes.defaultSpace),
              child: Column(
                children: [
                  /// --- Bulk Reminder Card
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
                        Text(
                          selectedMembersList.isEmpty
                              ? 'Select expiring members below to send reminders'
                              : 'Send reminders to ${selectedMembersList.length} selected member(s)',
                          style: TextStyle(color: XColors.white.withValues(alpha: 0.8), fontSize: 13),
                        ),
                        const SizedBox(height: XSizes.spaceBtwItems),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (selectedMembersList.isEmpty) {
                                    XHelperFunctions.showSnackBar('Please select at least one member.');
                                    return;
                                  }
                                  _showMessageTemplateBottomSheet(context, targetMembers: selectedMembersList, isWhatsApp: true);
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
                                  if (selectedMembersList.isEmpty) {
                                    XHelperFunctions.showSnackBar('Please select at least one member.');
                                    return;
                                  }
                                  _showMessageTemplateBottomSheet(context, targetMembers: selectedMembersList, isWhatsApp: false);
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

                  /// --- Expiring Members Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: expiringMembers.isNotEmpty &&
                                expiringMembers.every((m) => _selectedMemberIds.contains(m.id)),
                            onChanged: (selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedMemberIds.addAll(expiringMembers.map((m) => m.id));
                                } else {
                                  _selectedMemberIds.removeAll(expiringMembers.map((m) => m.id));
                                }
                              });
                            },
                            activeColor: XColors.primary,
                          ),
                          Text(
                            'Expiring Soon',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: XColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${expiringMembers.length} members', style: const TextStyle(color: XColors.warning, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  /// --- Expiring List
                  Expanded(
                    child: expiringMembers.isEmpty
                        ? XEmptyState(
                            title: 'No Expirations Soon',
                            subtitle: 'All members have active plans with sufficient time remaining.',
                            icon: Iconsax.notification,
                          )
                        : ListView.separated(
                            itemCount: expiringMembers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: XSizes.sm + 2),
                            itemBuilder: (context, index) {
                              final member = expiringMembers[index];
                              final isSelected = _selectedMemberIds.contains(member.id);
                              final days = member.expiryDate.difference(DateTime.now()).inDays;

                              return Container(
                                padding: const EdgeInsets.all(XSizes.md - 4),
                                decoration: BoxDecoration(
                                  color: dark ? XColors.darkCardBackground : XColors.white,
                                  borderRadius: BorderRadius.circular(XSizes.cardRadiusMd),
                                  boxShadow: [BoxShadow(color: XColors.primary.withValues(alpha: 0.04), blurRadius: 12)],
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (selected) {
                                        setState(() {
                                          if (selected == true) {
                                            _selectedMemberIds.add(member.id);
                                          } else {
                                            _selectedMemberIds.remove(member.id);
                                          }
                                        });
                                      },
                                      activeColor: XColors.primary,
                                    ),
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: XColors.warning.withValues(alpha: 0.1),
                                      child: Text(
                                        member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : 'M',
                                        style: const TextStyle(color: XColors.warning, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                          Text('Expires in $days days • Seat ${member.seatNumber}', style: Theme.of(context).textTheme.bodySmall),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showMessageTemplateBottomSheet(context, targetMembers: [member], isWhatsApp: true);
                                      },
                                      icon: const Icon(Iconsax.message, color: Color(0xFF25D366), size: 22),
                                      tooltip: 'WhatsApp Reminder',
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showMessageTemplateBottomSheet(context, targetMembers: [member], isWhatsApp: false);
                                      },
                                      icon: const Icon(Iconsax.sms, color: XColors.primary, size: 22),
                                      tooltip: 'SMS Reminder',
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
