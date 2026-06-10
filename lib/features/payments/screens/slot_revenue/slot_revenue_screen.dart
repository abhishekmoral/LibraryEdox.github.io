import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/common/widgets/appbar/appbar.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/features/slots/models/slot_model.dart';
import 'package:edox_library/data/repositories/payments/payment_repository.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';

class SlotRevenueData {
  final String slotId;
  final String slotName;
  final String timing;
  final double monthlyRevenue;
  final double todaysCollection;
  final double pendingPayments;

  SlotRevenueData({
    required this.slotId,
    required this.slotName,
    required this.timing,
    required this.monthlyRevenue,
    required this.todaysCollection,
    required this.pendingPayments,
  });
}

class SlotRevenueScreen extends StatefulWidget {
  const SlotRevenueScreen({super.key});

  @override
  State<SlotRevenueScreen> createState() => _SlotRevenueScreenState();
}

class _SlotRevenueScreenState extends State<SlotRevenueScreen> {
  bool _isLoading = false;
  List<SlotRevenueData> _revenueData = [];

  @override
  void initState() {
    super.initState();
    _fetchSlotRevenueBreakdown();
  }

  Future<void> _fetchSlotRevenueBreakdown() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final slotsCubit = context.read<SlotsCubit>();
      final paymentRepo = locator<PaymentRepository>();
      final memberRepo = locator<MemberRepository>();

      final allSlots = [
        SlotModel(
          id: 'default',
          name: 'Complete',
          startTime: '12:00 AM',
          endTime: '11:59 PM',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ...slotsCubit.state.slots,
      ];

      final List<SlotRevenueData> list = [];
      for (final slot in allSlots) {
        final responses = await Future.wait([
          paymentRepo.getMonthlyRevenue(slot.id),
          paymentRepo.getTodaysCollection(slot.id),
          memberRepo.getPendingPaymentsAmount(slot.id),
        ]);

        list.add(SlotRevenueData(
          slotId: slot.id,
          slotName: slot.name,
          timing: '${slot.startTime} - ${slot.endTime}',
          monthlyRevenue: responses[0],
          todaysCollection: responses[1],
          pendingPayments: responses[2],
        ));
      }
      if (mounted) {
        setState(() {
          _revenueData = list;
        });
      }
    } catch (e) {
      if (mounted) {
        XHelperFunctions.showSnackBar('Failed to load slot revenue data: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: const XAppBar(
        title: Text('Slot Revenue Breakdown'),
        showBackArrow: true,
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_revenueData.isEmpty) {
            return const Center(child: Text('No slot data found'));
          }

          return RefreshIndicator(
            onRefresh: _fetchSlotRevenueBreakdown,
            child: ListView.separated(
              padding: const EdgeInsets.all(XSizes.defaultSpace),
              itemCount: _revenueData.length,
              separatorBuilder: (_, __) => const SizedBox(height: XSizes.spaceBtwItems),
              itemBuilder: (context, index) {
                final data = _revenueData[index];

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: dark
                          ? [XColors.darkCardBackground, XColors.darkCardBackground.withValues(alpha: 0.8)]
                          : [XColors.white, XColors.white.withValues(alpha: 0.95)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: dark ? XColors.primary.withValues(alpha: 0.15) : XColors.primary.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: XColors.primary.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: XColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.chart_2, color: XColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.slotName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: dark ? XColors.white : XColors.textPrimary,
                                    ),
                              ),
                              Text(
                                data.timing,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: XColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildMetricTile(
                            context,
                            label: 'Monthly Revenue',
                            value: XHelperFunctions.formatCurrency(data.monthlyRevenue).replaceAll('.00', ''),
                            color: XColors.primary,
                            icon: Iconsax.wallet_money,
                          ),
                          _buildMetricTile(
                            context,
                            label: "Today's Collection",
                            value: XHelperFunctions.formatCurrency(data.todaysCollection).replaceAll('.00', ''),
                            color: XColors.accent,
                            icon: Iconsax.money_3,
                          ),
                          _buildMetricTile(
                            context,
                            label: 'Pending Payments',
                            value: XHelperFunctions.formatCurrency(data.pendingPayments).replaceAll('.00', ''),
                            color: XColors.warning,
                            icon: Iconsax.info_circle,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final dark = XHelperFunctions.isDarkMode(context);

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: dark ? XColors.white : XColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: XColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
