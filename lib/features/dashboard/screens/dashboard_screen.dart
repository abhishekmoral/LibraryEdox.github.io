import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/cards/dashboard_card.dart';
import 'package:edox_library/common/widgets/texts/section_heading.dart';
import 'package:edox_library/common/widgets/containers/rounded_container.dart';
import 'package:edox_library/features/members/screens/add_member/add_member_screen.dart';
import 'package:edox_library/navigation_menu.dart';

import 'package:edox_library/features/dashboard/controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);
    final controller = Get.put(DashboardController());

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: XColors.primary,
          onRefresh: () async => await controller.fetchDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(XSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- Greeting Header
                _DashboardHeader(dark: dark),
                const SizedBox(height: XSizes.spaceBtwSections),

                /// --- Stat Cards
                const _StatsGrid(),
                const SizedBox(height: XSizes.spaceBtwSections),

                /// --- Revenue Chart
                _RevenueChart(dark: dark),
                const SizedBox(height: XSizes.spaceBtwSections),

                /// --- Quick Actions
                const _QuickActions(),
                const SizedBox(height: XSizes.spaceBtwSections),

                /// --- Recent Activity
                _RecentActivity(dark: dark),
                const SizedBox(height: XSizes.spaceBtwItems),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// --- Dashboard Header ---
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              XHelperFunctions.getGreeting(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'EdoxLibrary',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(XSizes.sm + 2),
          decoration: BoxDecoration(
            color: dark ? XColors.darkCardBackground : XColors.white,
            borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
            boxShadow: [
              BoxShadow(
                color: XColors.primary.withValues(alpha: 0.06),
                blurRadius: 12,
              ),
            ],
          ),
          child: Badge(
            smallSize: 8,
            backgroundColor: XColors.error,
            child: Icon(Iconsax.notification, color: dark ? XColors.white : XColors.black),
          ),
        ),
      ],
    );
  }
}

/// --- Stats Grid ---
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    final controller = DashboardController.instance;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final stats = controller.stats.value;

      return GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: XSizes.gridViewSpacing,
        crossAxisSpacing: XSizes.gridViewSpacing,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.1, // Adjusted from 1.5 to prevent bottom overflow on smaller screens
        children: [
          XDashboardCard(
            title: 'Total Members',
            value: stats.totalMembers.toString(),
            icon: Iconsax.people,
            iconColor: XColors.primary,
          ),
          XDashboardCard(
            title: 'Active Members',
            value: stats.activeMembers.toString(),
            icon: Iconsax.tick_circle,
            iconColor: XColors.accent,
          ),
          XDashboardCard(
            title: 'Expired',
            value: stats.expiredMembers.toString(),
            icon: Iconsax.close_circle,
            iconColor: XColors.error,
          ),
          XDashboardCard(
            title: 'Expiring Soon',
            value: stats.expiringSoon.toString(),
            icon: Iconsax.warning_2,
            iconColor: XColors.warning,
          ),
          XDashboardCard(
            title: 'Total Seats',
            value: stats.totalSeats.toString(),
            icon: Iconsax.grid_2,
            iconColor: const Color(0xFF8B5CF6),
          ),
          XDashboardCard(
            title: 'Available Seats',
            value: stats.availableSeats.toString(),
            icon: Iconsax.grid_edit,
            iconColor: XColors.seatAvailable,
          ),
          XDashboardCard(
            title: 'Pending Payments',
            value: '₹${XHelperFunctions.formatCurrency(stats.pendingPayments.toDouble()).replaceAll('.00', '').replaceAll('₹', '')}',
            icon: Iconsax.money_recive,
            iconColor: XColors.seatMaintenance,
          ),
          XDashboardCard(
            title: 'Today\'s Collection',
            value: '₹${XHelperFunctions.formatCurrency(stats.todaysCollection).replaceAll('.00', '').replaceAll('₹', '')}',
            icon: Iconsax.wallet,
            iconColor: XColors.primary,
          ),
        ],
      );
    });
  }
}

/// --- Revenue Chart ---
class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const XSectionHeading(title: 'Revenue Overview'),
        const SizedBox(height: XSizes.spaceBtwItems),
        XRoundedContainer(
          backgroundColor: dark ? XColors.darkCardBackground : XColors.white,
          padding: const EdgeInsets.all(XSizes.md),
          child: Obx(() {
            final stats = DashboardController.instance.stats.value;
            final chartData = DashboardController.instance.revenueChartData;
            
            return Column(
              children: [
                /// --- Revenue stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MiniStat(label: 'Monthly', value: XHelperFunctions.formatCurrency(stats.monthlyRevenue).replaceAll('.00', ''), color: XColors.primary),
                    Container(width: 1, height: 30, color: XColors.softGrey),
                    _MiniStat(label: 'Today', value: XHelperFunctions.formatCurrency(stats.todaysCollection).replaceAll('.00', ''), color: XColors.accent),
                    Container(width: 1, height: 30, color: XColors.softGrey),
                    _MiniStat(label: 'Pending', value: XHelperFunctions.formatCurrency(stats.pendingPayments.toDouble()).replaceAll('.00', ''), color: XColors.warning),
                  ],
                ),
                const SizedBox(height: XSizes.spaceBtwItems),

                /// --- Chart
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 20000,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: dark ? XColors.darkGrey.withValues(alpha: 0.3) : XColors.softGrey,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final now = DateTime.now();
                              final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                              final months = List.generate(6, (index) {
                                final d = DateTime(now.year, now.month - 5 + index, 1);
                                return monthNames[d.month - 1];
                              });
                              if (value.toInt() >= 0 && value.toInt() < months.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    months[value.toInt()],
                                    style: TextStyle(
                                      color: dark ? XColors.softGrey : XColors.darkGrey,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                          isCurved: true,
                          color: XColors.primary,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) =>
                                FlDotCirclePainter(
                              radius: 4,
                              color: XColors.primary,
                              strokeWidth: 2,
                              strokeColor: XColors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                XColors.primary.withValues(alpha: 0.2),
                                XColors.primary.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      minY: 0,
                      maxY: chartData.isEmpty ? 10000 : (chartData.reduce((a, b) => a > b ? a : b) * 1.2).clamp(10000.0, double.infinity),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// --- Quick Actions ---
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);
    return Column(
      children: [
        const XSectionHeading(title: 'Quick Actions'),
        const SizedBox(height: XSizes.spaceBtwItems),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ActionItem(
              icon: Iconsax.user_add,
              label: 'Add\nMember',
              color: XColors.primary,
              dark: dark,
              onTap: () => Get.toNamed('/add-member'),
            ),
            _ActionItem(
              icon: Iconsax.grid_edit,
              label: 'Assign\nSeat',
              color: XColors.accent,
              dark: dark,
              onTap: () {
                final navController = Get.find<NavigationController>();
                navController.selectedIndex.value = 2; // Seats tab
              },
            ),
            _ActionItem(
              icon: Iconsax.money_recive,
              label: 'Collect\nFee',
              color: XColors.seatMaintenance,
              dark: dark,
              onTap: () => Get.toNamed('/collect-payment'),
            ),
            _ActionItem(
              icon: Iconsax.refresh,
              label: 'Renew\nPlan',
              color: const Color(0xFF8B5CF6),
              dark: dark,
              onTap: () {
                final navController = Get.find<NavigationController>();
                navController.selectedIndex.value = 1; // Members tab
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.dark,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool dark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(XSizes.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: XSizes.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// --- Recent Activity ---
class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final controller = DashboardController.instance;

    return Column(
      children: [
        const XSectionHeading(title: 'Recent Activity', showActionButton: true),
        const SizedBox(height: XSizes.spaceBtwItems),
        Container(
          decoration: BoxDecoration(
            color: dark ? XColors.darkCardBackground : XColors.white,
            borderRadius: BorderRadius.circular(XSizes.cardRadiusLg),
            boxShadow: [
              BoxShadow(
                color: dark
                    ? Colors.black.withValues(alpha: 0.2)
                    : XColors.primary.withValues(alpha: 0.04),
                blurRadius: 12,
              ),
            ],
          ),
          child: Obx(() {
            if (controller.recentActivity.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(XSizes.md),
                child: Center(child: Text('No recent activity')),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentActivity.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: dark ? XColors.darkGrey.withValues(alpha: 0.3) : XColors.lightGrey,
              ),
              itemBuilder: (context, index) {
                final a = controller.recentActivity[index];
                
                IconData icon;
                Color color;
                switch (a.type) {
                  case 'member':
                    icon = Iconsax.user_add;
                    color = XColors.accent;
                    break;
                  case 'payment':
                    icon = Iconsax.card_receive;
                    color = XColors.primary;
                    break;
                  case 'seat':
                    icon = Iconsax.grid_edit;
                    color = XColors.warning;
                    break;
                  default:
                    icon = Iconsax.info_circle;
                    color = XColors.grey;
                }

                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(a.description, style: Theme.of(context).textTheme.bodySmall),
                  trailing: Text(_formatTime(a.createdAt), style: Theme.of(context).textTheme.labelSmall),
                  contentPadding: const EdgeInsets.symmetric(horizontal: XSizes.md, vertical: 4),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
