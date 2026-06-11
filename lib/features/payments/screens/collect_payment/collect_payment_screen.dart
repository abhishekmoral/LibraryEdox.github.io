import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:collection/collection.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/validators/validation.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';
import 'package:edox_library/common/widgets/inputs/dropdown_field.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/data/repositories/payments/payment_repository.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/payments/models/payment_model.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/features/dashboard/controllers/dashboard_cubit.dart';

class CollectPaymentScreen extends StatefulWidget {
  const CollectPaymentScreen({super.key});

  @override
  State<CollectPaymentScreen> createState() => _CollectPaymentScreenState();
}

class _CollectPaymentScreenState extends State<CollectPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _selectedMethod = 'cash';

  List<MemberModel> _members = [];
  MemberModel? _selectedMember;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedPlanId = 'monthly';
  StreamSubscription? _membersSub;

  @override
  void initState() {
    super.initState();
    _membersSub = MemberRepository.instance.getAllMembersStream('all').listen((memberList) {
      if (mounted) {
        setState(() {
          _members = memberList;
        });
      }
    });
  }

  @override
  void dispose() {
    _membersSub?.cancel();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const XAppBar(title: Text('Collect Fee')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(XSizes.defaultSpace),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- Select Member
              XDropdownField<String>(
                label: 'Select Member',
                prefixIcon: Iconsax.user,
                value: _selectedMember?.id,
                items: _members.map((m) {
                  return DropdownMenuItem<String>(
                    value: m.id,
                    child: Text('${m.fullName} - ${m.seatNumber}'),
                  );
                }).toList(),
                onChanged: (v) {
                  final member = _members.firstWhereOrNull((m) => m.id == v);
                  if (member != null) {
                    setState(() {
                      _selectedMember = member;
                      _selectedPlanId = member.planId.isNotEmpty ? member.planId : 'monthly';
                      double fee = 1500;
                      if (_selectedPlanId == 'monthly') fee = 1500;
                      else if (_selectedPlanId == 'quarterly') fee = 4000;
                      else if (_selectedPlanId == 'half_yearly') fee = 7500;
                      else if (_selectedPlanId == 'annual') fee = 14000;
                      _amountController.text = fee.toInt().toString();
                    });
                  }
                },
                validator: (v) => v == null ? 'Select a member' : null,
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Plan
              XDropdownField<String>(
                label: 'Membership Plan',
                prefixIcon: Iconsax.calendar_1,
                value: _selectedPlanId,
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly - ₹1,500')),
                  DropdownMenuItem(value: 'quarterly', child: Text('Quarterly - ₹4,000')),
                  DropdownMenuItem(value: 'half_yearly', child: Text('Half Yearly - ₹7,500')),
                  DropdownMenuItem(value: 'annual', child: Text('Annual - ₹14,000')),
                  DropdownMenuItem(value: 'manual', child: Text('Manual Plan - Custom Amount')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _selectedPlanId = v;
                      double fee = 1500;
                      if (_selectedPlanId == 'monthly') fee = 1500;
                      else if (_selectedPlanId == 'quarterly') fee = 4000;
                      else if (_selectedPlanId == 'half_yearly') fee = 7500;
                      else if (_selectedPlanId == 'annual') fee = 14000;
                      else fee = 0;
                      
                      if (_selectedPlanId != 'manual') {
                        _amountController.text = fee.toInt().toString();
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Amount
              XTextField(
                label: 'Amount (₹)',
                hint: 'Enter amount',
                controller: _amountController,
                prefixIcon: Iconsax.money_recive,
                keyboardType: TextInputType.number,
                validator: XValidator.validateAmount,
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Payment Method
              Text('Payment Method', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: XSizes.sm),
              Row(
                children: [
                  _MethodChip(
                    label: 'Cash', 
                    icon: Iconsax.money_recive, 
                    selected: _selectedMethod == 'cash', 
                    onTap: () => setState(() => _selectedMethod = 'cash'),
                  ),
                  const SizedBox(width: 8),
                  _MethodChip(
                    label: 'UPI', 
                    icon: Iconsax.mobile, 
                    selected: _selectedMethod == 'upi', 
                    onTap: () => setState(() => _selectedMethod = 'upi'),
                  ),
                  const SizedBox(width: 8),
                  _MethodChip(
                    label: 'Bank', 
                    icon: Iconsax.bank, 
                    selected: _selectedMethod == 'bank', 
                    onTap: () => setState(() => _selectedMethod = 'bank'),
                  ),
                ],
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Notes
              XTextField(
                label: 'Notes',
                hint: 'Payment notes (optional)',
                controller: _notesController,
                prefixIcon: Iconsax.note_1,
                maxLines: 2,
              ),
              const SizedBox(height: XSizes.spaceBtwSections),

              /// --- Submit
              XPrimaryButton(
                text: 'Collect Payment',
                isLoading: _isLoading,
                icon: Iconsax.tick_circle,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedMember == null) {
                      XHelperFunctions.showSnackBar('Please select a member.');
                      return;
                    }
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      final amount = double.parse(_amountController.text.trim());

                      // 1. Save payment record
                      final payment = PaymentModel(
                        id: '',
                        memberId: _selectedMember!.id,
                        memberName: _selectedMember!.fullName,
                        amount: amount,
                        date: DateTime.now(),
                        paymentMethod: _selectedMethod,
                        planId: _selectedPlanId,
                        planName: _selectedPlanId == 'monthly'
                            ? 'Monthly'
                            : _selectedPlanId == 'quarterly'
                                ? 'Quarterly'
                                : _selectedPlanId == 'half_yearly'
                                    ? 'Half Yearly'
                                    : _selectedPlanId == 'annual'
                                        ? 'Annual'
                                        : 'Manual Plan',
                        type: 'fee_collection',
                        slotId: _selectedMember!.slotId,
                        notes: _notesController.text.trim(),
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      await PaymentRepository.instance.savePaymentRecord(payment);

                      // 2. Update member paymentStatus to 'paid'
                      final updatedMember = _selectedMember!.copyWith(
                        paymentStatus: 'paid',
                        updatedAt: DateTime.now(),
                      );
                      await MemberRepository.instance.updateMember(updatedMember);

                      // 3. Update dashboard cubit state
                      if (locator.isRegistered<DashboardCubit>()) {
                        locator<DashboardCubit>().fetchDashboardData();
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        XHelperFunctions.showSnackBar('Payment collected successfully!');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        XHelperFunctions.showSnackBar('Error collecting payment: $e', isError: true);
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label; final IconData icon; final bool selected; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? XColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
            border: Border.all(color: selected ? XColors.primary : XColors.borderPrimary),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: selected ? XColors.white : XColors.darkGrey),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? XColors.white : XColors.darkGrey)),
            ],
          ),
        ),
      ),
    );
  }
}
