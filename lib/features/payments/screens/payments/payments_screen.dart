import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/features/payments/screens/collect_payment/collect_payment_screen.dart';
import 'package:edox_library/data/repositories/payments/payment_repository.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/features/payments/models/payment_model.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/common/widgets/empty_states/empty_state.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class PaymentDisplayItem {
  final String name;
  final String amount;
  final String plan;
  final String method;
  final String date;
  final bool isPaid;

  PaymentDisplayItem({
    required this.name,
    required this.amount,
    required this.plan,
    required this.method,
    required this.date,
    required this.isPaid,
  });
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int _selectedTab = 0;
  List<PaymentModel> _payments = [];
  List<MemberModel> _members = [];
  bool _isLoading = true;
  StreamSubscription? _paymentsSub;
  StreamSubscription? _membersSub;

  @override
  void initState() {
    super.initState();
    _paymentsSub = PaymentRepository.instance.getAllPaymentsStream().listen((paymentList) {
      if (mounted) {
        setState(() {
          _payments = paymentList;
          _isLoading = false;
        });
      }
    }, onError: (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });

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
    _paymentsSub?.cancel();
    _membersSub?.cancel();
    super.dispose();
  }

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    // Calculate dynamic stats
    double todaysCollection = 0;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    for (final p in _payments) {
      if (p.date.isAfter(startOfToday) || p.date.isAtSameMomentAs(startOfToday)) {
        todaysCollection += p.amount;
      }
    }

    double thisMonthsCollection = 0;
    final startOfMonth = DateTime(now.year, now.month, 1);
    for (final p in _payments) {
      if (p.date.isAfter(startOfMonth) || p.date.isAtSameMomentAs(startOfMonth)) {
        thisMonthsCollection += p.amount;
      }
    }

    double pendingAmount = 0;
    for (final m in _members) {
      if (m.paymentStatus == 'pending' || m.paymentStatus == 'overdue') {
        final planId = m.planId;
        if (planId == 'monthly') pendingAmount += 1500;
        else if (planId == 'quarterly') pendingAmount += 4000;
        else if (planId == 'half_yearly') pendingAmount += 7500;
        else if (planId == 'annual') pendingAmount += 14000;
        else pendingAmount += 1500;
      }
    }

    // Map display items
    final paidItems = _payments.map((p) {
      return PaymentDisplayItem(
        name: p.memberName,
        amount: '₹${p.amount.toInt().toString()}',
        plan: p.planName,
        method: p.paymentMethod.toUpperCase(),
        date: _getFormattedDate(p.date),
        isPaid: true,
      );
    }).toList();

    final pendingItems = _members
        .where((m) => m.paymentStatus == 'pending' || m.paymentStatus == 'overdue')
        .map((m) {
      double fee = 1500;
      if (m.planId == 'monthly') fee = 1500;
      else if (m.planId == 'quarterly') fee = 4000;
      else if (m.planId == 'half_yearly') fee = 7500;
      else if (m.planId == 'annual') fee = 14000;

      return PaymentDisplayItem(
        name: m.fullName,
        amount: '₹${fee.toInt().toString()}',
        plan: m.planName,
        method: '-',
        date: m.paymentStatus == 'overdue' ? 'Overdue' : 'Pending',
        isPaid: false,
      );
    }).toList();

    List<PaymentDisplayItem> displayList = [];
    if (_selectedTab == 0) {
      displayList = [...paidItems, ...pendingItems];
    } else if (_selectedTab == 1) {
      displayList = paidItems;
    } else {
      displayList = pendingItems;
    }

    return Scaffold(
      appBar: const XAppBar(
        title: Text('Payments'),
        showBackArrow: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// --- Stats Row
                Container(
                  margin: const EdgeInsets.all(XSizes.defaultSpace),
                  padding: const EdgeInsets.all(XSizes.md),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [XColors.primary, Color(0xFF7B5AFF)]),
                    borderRadius: BorderRadius.circular(XSizes.cardRadiusLg),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _PayStat(
                        label: 'Today',
                        value: XHelperFunctions.formatCurrency(todaysCollection).replaceAll('.00', ''),
                        icon: Iconsax.calendar_1,
                      ),
                      Container(width: 1, height: 36, color: XColors.white.withValues(alpha: 0.3)),
                      _PayStat(
                        label: 'This Month',
                        value: XHelperFunctions.formatCurrency(thisMonthsCollection).replaceAll('.00', ''),
                        icon: Iconsax.chart,
                      ),
                      Container(width: 1, height: 36, color: XColors.white.withValues(alpha: 0.3)),
                      _PayStat(
                        label: 'Pending',
                        value: XHelperFunctions.formatCurrency(pendingAmount).replaceAll('.00', ''),
                        icon: Iconsax.warning_2,
                      ),
                    ],
                  ),
                ),

                /// --- Tab Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: XSizes.defaultSpace),
                  child: Row(
                    children: List.generate(3, (i) {
                      final tabs = ['All', 'Paid', 'Pending'];
                      final selected = _selectedTab == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? XColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: selected
                                  ? null
                                  : Border.all(
                                      color: dark ? XColors.darkGrey : XColors.borderPrimary),
                            ),
                            child: Center(
                              child: Text(
                                tabs[i],
                                style: TextStyle(
                                  color: selected
                                      ? XColors.white
                                      : (dark ? XColors.softGrey : XColors.darkGrey),
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: XSizes.spaceBtwItems),

                /// --- Payment List
                Expanded(
                  child: displayList.isEmpty
                      ? XEmptyState(
                          title: 'No Payments Found',
                          subtitle: _selectedTab == 0
                              ? 'No transactions or pending bills registered.'
                              : _selectedTab == 1
                                  ? 'No completed payments yet.'
                                  : 'No pending payments found.',
                          icon: Iconsax.money_3,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: XSizes.defaultSpace),
                          itemCount: displayList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: XSizes.sm + 2),
                          itemBuilder: (context, index) {
                            final p = displayList[index];
                            return _PaymentTile(payment: p, dark: dark);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CollectPaymentScreen()),
          );
        },
        backgroundColor: XColors.primary,
        icon: const Icon(Iconsax.money_recive, color: XColors.white),
        label: const Text('Collect Fee', style: TextStyle(color: XColors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _PayStat extends StatelessWidget {
  const _PayStat({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: XColors.white.withValues(alpha: 0.7), size: 18),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: XColors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        Text(label, style: TextStyle(color: XColors.white.withValues(alpha: 0.7), fontSize: 11)),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment, required this.dark});
  final PaymentDisplayItem payment;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final isPaid = payment.isPaid;
    return Container(
      padding: const EdgeInsets.all(XSizes.md),
      decoration: BoxDecoration(
        color: dark ? XColors.darkCardBackground : XColors.white,
        borderRadius: BorderRadius.circular(XSizes.cardRadiusMd),
        boxShadow: [BoxShadow(color: XColors.primary.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isPaid ? XColors.accent : XColors.warning).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPaid ? Iconsax.tick_circle : Iconsax.clock,
              color: isPaid ? XColors.accent : XColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${payment.plan} • ${payment.method}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                payment.amount,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isPaid ? XColors.accent : XColors.warning,
                ),
              ),
              const SizedBox(height: 2),
              Text(payment.date, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
