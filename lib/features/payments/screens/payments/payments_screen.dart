import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/features/payments/screens/collect_payment/collect_payment_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int _selectedTab = 0;
  final List<Map<String, String>> _allPayments = _getMockPayments();

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    // Filter payments based on selected tab index (0 = All, 1 = Paid, 2 = Pending)
    final filteredPayments = _allPayments.where((p) {
      if (_selectedTab == 0) return true;
      if (_selectedTab == 1) return p['status'] == 'Paid';
      return p['status'] == 'Pending';
    }).toList();

    return Scaffold(
      appBar: const XAppBar(
        title: Text('Payments'),
        showBackArrow: true,
      ),
      body: Column(
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
                const _PayStat(label: 'Today', value: '₹4,500', icon: Iconsax.calendar_1),
                Container(width: 1, height: 36, color: XColors.white.withValues(alpha: 0.3)),
                const _PayStat(label: 'This Month', value: '₹67,500', icon: Iconsax.chart),
                Container(width: 1, height: 36, color: XColors.white.withValues(alpha: 0.3)),
                const _PayStat(label: 'Pending', value: '₹9,000', icon: Iconsax.warning_2),
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
                        border: selected ? null : Border.all(color: dark ? XColors.darkGrey : XColors.borderPrimary),
                      ),
                      child: Center(
                        child: Text(tabs[i], style: TextStyle(
                          color: selected ? XColors.white : (dark ? XColors.softGrey : XColors.darkGrey),
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400, fontSize: 13,
                        )),
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
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: XSizes.defaultSpace),
              itemCount: filteredPayments.length,
              separatorBuilder: (_, __) => const SizedBox(height: XSizes.sm + 2),
              itemBuilder: (context, index) {
                final p = filteredPayments[index];
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
  final String label; final String value; final IconData icon;

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
  final Map<String, String> payment; final bool dark;

  @override
  Widget build(BuildContext context) {
    final isPaid = payment['status'] == 'Paid';
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
              color: isPaid ? XColors.accent : XColors.warning, size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${payment['plan']} • ${payment['method']}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(payment['amount']!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isPaid ? XColors.accent : XColors.warning)),
              const SizedBox(height: 2),
              Text(payment['date']!, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

List<Map<String, String>> _getMockPayments() {
  return [
    {'name': 'Rahul Sharma', 'amount': '₹1,500', 'plan': 'Monthly', 'method': 'UPI', 'date': 'Today', 'status': 'Paid'},
    {'name': 'Neha Singh', 'amount': '₹7,500', 'plan': 'Half Yearly', 'method': 'Cash', 'date': 'Today', 'status': 'Paid'},
    {'name': 'Priya Patel', 'amount': '₹4,000', 'plan': 'Quarterly', 'method': 'UPI', 'date': 'Yesterday', 'status': 'Paid'},
    {'name': 'Vikash Gupta', 'amount': '₹1,500', 'plan': 'Monthly', 'method': 'Cash', 'date': 'Pending', 'status': 'Pending'},
    {'name': 'Amit Kumar', 'amount': '₹1,500', 'plan': 'Monthly', 'method': '-', 'date': 'Overdue', 'status': 'Pending'},
    {'name': 'Deepak Joshi', 'amount': '₹1,500', 'plan': 'Monthly', 'method': '-', 'date': 'Overdue', 'status': 'Pending'},
    {'name': 'Anjali Verma', 'amount': '₹4,000', 'plan': 'Quarterly', 'method': 'Bank Transfer', 'date': '28 May', 'status': 'Paid'},
  ];
}
