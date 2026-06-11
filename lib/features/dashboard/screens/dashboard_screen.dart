import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/texts/section_heading.dart';
import 'package:edox_library/navigation_menu.dart';
import 'package:edox_library/features/dashboard/controllers/dashboard_cubit.dart';
import 'package:edox_library/features/dashboard/models/dashboard_stats_model.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';
import 'package:edox_library/features/payments/screens/slot_revenue/slot_revenue_screen.dart';
import 'package:edox_library/features/members/controllers/members_cubit.dart';
import 'package:collection/collection.dart';
import 'package:edox_library/features/members/screens/member_detail/member_detail_screen.dart';
import 'package:edox_library/features/members/screens/recycle_bin/recycle_bin_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: XColors.primary,
              onRefresh: () async => await context.read<DashboardCubit>().fetchDashboardData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(XSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// --- Greeting Header with animated gradient
                    _DashboardHeader(dark: dark),
                    const SizedBox(height: XSizes.spaceBtwItems + 4),

                    /// --- Hero Revenue Banner
                    _HeroRevenueBanner(stats: state.stats, dark: dark),
                    const SizedBox(height: XSizes.spaceBtwSections),

                    /// --- Stat Cards (2x2 top stats)
                    _TopStatsRow(stats: state.stats, isLoading: state.isLoading),
                    const SizedBox(height: XSizes.spaceBtwItems),
                    _BottomStatsRow(stats: state.stats, isLoading: state.isLoading),
                    const SizedBox(height: XSizes.spaceBtwSections),

                    /// --- Slot-wise Seat Details
                    _SlotWiseSeatDetails(slotDetails: state.slotSeatDetails, isLoading: state.isLoading),
                    const SizedBox(height: XSizes.spaceBtwSections),

                    /// --- Revenue Chart
                    _RevenueChart(chartData: state.revenueChartData, dark: dark),
                    const SizedBox(height: XSizes.spaceBtwSections),

                    /// --- Quick Actions
                    _QuickActions(dark: dark),
                    const SizedBox(height: XSizes.spaceBtwSections),

                    /// --- Recent Activity
                    _RecentActivity(recentActivity: state.recentActivity, dark: dark),
                    const SizedBox(height: XSizes.spaceBtwItems),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DASHBOARD HEADER
// ═══════════════════════════════════════════════════════════════
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                XHelperFunctions.getGreeting(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: dark ? XColors.textSecondary : XColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [XColors.primary, Color(0xFF868CFF)],
                ).createShader(bounds),
                child: Text(
                  'EdoxLibrary',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: XColors.white,
                        letterSpacing: -0.5,
                      ),
                ),
              ),
            ],
          ),
        ),

        /// Notification bell
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dark
                    ? [XColors.darkCardBackground, XColors.darkCardBackground.withValues(alpha: 0.8)]
                    : [XColors.white, XColors.white.withValues(alpha: 0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: dark ? XColors.primary.withValues(alpha: 0.15) : XColors.primary.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: XColors.primary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Badge(
              smallSize: 9,
              backgroundColor: XColors.error,
              child: Icon(Iconsax.notification, color: dark ? XColors.white : XColors.textPrimary, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HERO REVENUE BANNER
// ═══════════════════════════════════════════════════════════════
class _HeroRevenueBanner extends StatelessWidget {
  const _HeroRevenueBanner({required this.stats, required this.dark});
  final DashboardStatsModel stats;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SlotRevenueScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4318FF), Color(0xFF7B5AFF), Color(0xFF868CFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: XColors.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
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
                    color: XColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.wallet_3, color: XColors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Revenue',
                      style: TextStyle(
                        color: XColors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      XHelperFunctions.formatCurrency(stats.monthlyRevenue).replaceAll('.00', ''),
                      style: const TextStyle(
                        color: XColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: XColors.white.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HeroBannerStat(
                  label: "Today's Collection",
                  value: XHelperFunctions.formatCurrency(stats.todaysCollection).replaceAll('.00', ''),
                  icon: Iconsax.arrow_up_3,
                  iconColor: XColors.accent,
                ),
                Container(width: 1, height: 36, color: XColors.white.withValues(alpha: 0.15)),
                _HeroBannerStat(
                  label: 'Pending',
                  value: XHelperFunctions.formatCurrency(stats.pendingPayments.toDouble()).replaceAll('.00', ''),
                  icon: Iconsax.clock,
                  iconColor: XColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBannerStat extends StatelessWidget {
  const _HeroBannerStat({required this.label, required this.value, required this.icon, required this.iconColor});
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: XColors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: XColors.white, fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TOP STATS ROW (Members + Active)
// ═══════════════════════════════════════════════════════════════
class _TopStatsRow extends StatelessWidget {
  const _TopStatsRow({required this.stats, required this.isLoading});
  final DashboardStatsModel stats;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        Expanded(
          child: _GlassStatCard(
            title: 'Total Members',
            value: stats.totalMembers.toString(),
            icon: Iconsax.people,
            iconGradient: const [Color(0xFF4318FF), Color(0xFF868CFF)],
            dark: dark,
            onTap: () {
              context.read<MembersCubit>().setSelectedFilter('All');
              TabChangeNotification(1).dispatch(context); // Members tab
            },
          ),
        ),
        const SizedBox(width: XSizes.gridViewSpacing),
        Expanded(
          child: _GlassStatCard(
            title: 'Active Members',
            value: stats.activeMembers.toString(),
            icon: Iconsax.tick_circle,
            iconGradient: const [Color(0xFF05CD99), Color(0xFF61EFCD)],
            dark: dark,
            onTap: () {
              context.read<MembersCubit>().setSelectedFilter('Active');
              TabChangeNotification(1).dispatch(context); // Members tab
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BOTTOM STATS ROW (Seats + Expired)
// ═══════════════════════════════════════════════════════════════
class _BottomStatsRow extends StatelessWidget {
  const _BottomStatsRow({required this.stats, required this.isLoading});
  final DashboardStatsModel stats;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    if (isLoading) return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: _GlassStatCard(
            title: 'Total Seats',
            value: '${stats.availableSeats}/${stats.totalSeats}',
            icon: Iconsax.grid_2,
            iconGradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
            dark: dark,
            subtitle: 'Available',
            onTap: () {
              TabChangeNotification(2).dispatch(context); // Seats tab
            },
          ),
        ),
        const SizedBox(width: XSizes.gridViewSpacing),
        Expanded(
          child: _GlassStatCard(
            title: 'Expired',
            value: stats.expiredMembers.toString(),
            icon: Iconsax.close_circle,
            iconGradient: const [Color(0xFFFF4C61), Color(0xFFFF8F9E)],
            dark: dark,
            subtitle: 'Members',
            onTap: () {
              context.read<MembersCubit>().setSelectedFilter('Expired');
              TabChangeNotification(1).dispatch(context); // Members tab
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GLASS STAT CARD WIDGET
// ═══════════════════════════════════════════════════════════════
class _GlassStatCard extends StatelessWidget {
  const _GlassStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconGradient,
    required this.dark,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final List<Color> iconGradient;
  final bool dark;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark ? XColors.darkCardBackground : XColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: dark ? iconGradient[0].withValues(alpha: 0.12) : iconGradient[0].withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.black.withValues(alpha: 0.25)
                  : iconGradient[0].withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Gradient icon container
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: iconGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: iconGradient[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: XColors.white, size: 20),
                ),
                if (subtitle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: iconGradient[0].withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        color: iconGradient[0],
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? XColors.textSecondary : XColors.textSecondary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REVENUE CHART
// ═══════════════════════════════════════════════════════════════
class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.chartData, required this.dark});
  final List<double> chartData;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const XSectionHeading(title: 'Revenue Overview'),
        const SizedBox(height: XSizes.spaceBtwItems),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: dark ? XColors.darkCardBackground : XColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: dark ? XColors.primary.withValues(alpha: 0.08) : XColors.primary.withValues(alpha: 0.04),
            ),
            boxShadow: [
              BoxShadow(
                color: dark
                    ? Colors.black.withValues(alpha: 0.2)
                    : XColors.primary.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: dark ? XColors.darkGrey.withValues(alpha: 0.2) : XColors.softGrey.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [5, 5],
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
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              months[value.toInt()],
                              style: TextStyle(
                                color: dark ? XColors.textSecondary : XColors.darkGrey,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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
                    curveSmoothness: 0.35,
                    gradient: const LinearGradient(
                      colors: [XColors.primary, Color(0xFF868CFF)],
                    ),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 5,
                        color: XColors.primary,
                        strokeWidth: 3,
                        strokeColor: XColors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          XColors.primary.withValues(alpha: 0.25),
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
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// QUICK ACTIONS
// ═══════════════════════════════════════════════════════════════
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
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
              gradient: const [Color(0xFF4318FF), Color(0xFF7B5AFF)],
              dark: dark,
              onTap: () => Navigator.pushNamed(context, '/add-member'),
            ),
            _ActionItem(
              icon: Iconsax.grid_edit,
              label: 'Assign\nSeat',
              gradient: const [Color(0xFF05CD99), Color(0xFF61EFCD)],
              dark: dark,
              onTap: () {
                TabChangeNotification(2).dispatch(context); // Seats tab
              },
            ),
            _ActionItem(
              icon: Iconsax.money_recive,
              label: 'Collect\nFee',
              gradient: const [Color(0xFFFF8A00), Color(0xFFFFC837)],
              dark: dark,
              onTap: () => Navigator.pushNamed(context, '/collect-payment'),
            ),
            _ActionItem(
              icon: Iconsax.refresh,
              label: 'Renew\nPlan',
              gradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
              dark: dark,
              onTap: () {
                TabChangeNotification(1).dispatch(context); // Members tab
              },
            ),
            _ActionItem(
              icon: Iconsax.trash,
              label: 'Recycle\nBin',
              gradient: const [Color(0xFFFF4C61), Color(0xFFFF8F9E)],
              dark: dark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecycleBinScreen()),
              ),
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
    required this.gradient,
    required this.dark,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final List<Color> gradient;
  final bool dark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: XColors.white, size: 24),
          ),
          const SizedBox(height: XSizes.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// RECENT ACTIVITY
// ═══════════════════════════════════════════════════════════════
class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.recentActivity, required this.dark});
  final List<ActivityModel> recentActivity;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const XSectionHeading(title: 'Recent Activity', showActionButton: true),
        const SizedBox(height: XSizes.spaceBtwItems),
        Container(
          decoration: BoxDecoration(
            color: dark ? XColors.darkCardBackground : XColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: dark ? XColors.primary.withValues(alpha: 0.08) : XColors.primary.withValues(alpha: 0.04),
            ),
            boxShadow: [
              BoxShadow(
                color: dark
                    ? Colors.black.withValues(alpha: 0.2)
                    : XColors.primary.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: recentActivity.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(XSizes.lg),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Iconsax.activity, color: XColors.textSecondary, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'No recent activity',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: XColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentActivity.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: 70,
                    color: dark ? XColors.darkGrey.withValues(alpha: 0.2) : XColors.lightGrey,
                  ),
                  itemBuilder: (context, index) {
                    final a = recentActivity[index];

                    IconData icon;
                    List<Color> iconGradient;
                    switch (a.type) {
                      case 'member':
                        icon = Iconsax.user_add;
                        iconGradient = [const Color(0xFF05CD99), const Color(0xFF61EFCD)];
                        break;
                      case 'payment':
                        icon = Iconsax.card_receive;
                        iconGradient = [const Color(0xFF4318FF), const Color(0xFF868CFF)];
                        break;
                      case 'seat':
                        icon = Iconsax.grid_edit;
                        iconGradient = [const Color(0xFFFFC837), const Color(0xFFFF8A00)];
                        break;
                      default:
                        icon = Iconsax.info_circle;
                        iconGradient = [XColors.grey, XColors.softGrey];
                    }

                    final memberId = a.memberId;
                    final isMemberActivity = memberId != null && memberId.isNotEmpty;

                    return ListTile(
                      onTap: isMemberActivity
                          ? () {
                              final membersCubit = context.read<MembersCubit>();
                              final member = membersCubit.state.allMembers.firstWhereOrNull((m) => m.id == memberId);
                              if (member != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MemberDetailScreen(member: member),
                                  ),
                                );
                              }
                            }
                          : null,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: iconGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: iconGradient[0].withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: XColors.white, size: 18),
                      ),
                      title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(a.description, style: Theme.of(context).textTheme.bodySmall),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: dark ? XColors.darkGrey.withValues(alpha: 0.3) : XColors.lightGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatTime(a.createdAt),
                          style: TextStyle(
                            color: dark ? XColors.textSecondary : XColors.darkGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: XSizes.md, vertical: 6),
                    );
                  },
                ),
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

// ═══════════════════════════════════════════════════════════════
// SLOT-WISE SEAT DETAILS
// ═══════════════════════════════════════════════════════════════
class _SlotWiseSeatDetails extends StatelessWidget {
  const _SlotWiseSeatDetails({required this.slotDetails, required this.isLoading});
  final List<SlotSeatDetails> slotDetails;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    if (isLoading) return const SizedBox();
    if (slotDetails.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const XSectionHeading(title: 'Slot-wise Seats'),
        const SizedBox(height: XSizes.spaceBtwItems),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: slotDetails.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final details = slotDetails[index];
              return _SlotSeatCard(details: details, dark: dark);
            },
          ),
        ),
      ],
    );
  }
}

class _SlotSeatCard extends StatelessWidget {
  const _SlotSeatCard({required this.details, required this.dark});
  final SlotSeatDetails details;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final name = details.slotName.toLowerCase();
    List<Color> gradientColors;
    IconData icon;
    
    if (name.contains('morning')) {
      gradientColors = const [Color(0xFFFFA07A), Color(0xFFFFD700)]; // Sunrise peach/gold
      icon = Iconsax.sun_1;
    } else if (name.contains('day')) {
      gradientColors = const [Color(0xFF00BFFF), Color(0xFF00FA9A)]; // Day sky/teal
      icon = Iconsax.sun_1;
    } else if (name.contains('evening')) {
      gradientColors = const [Color(0xFFFE8C00), Color(0xFFF83600)]; // Evening sunset
      icon = Iconsax.clock;
    } else if (name.contains('night')) {
      gradientColors = const [Color(0xFF1F1C2C), Color(0xFF928DAB)]; // Night deep charcoal/indigo
      icon = Iconsax.moon;
    } else {
      gradientColors = const [Color(0xFF6A11CB), Color(0xFF2575FC)]; // Complete purple/royal blue
      icon = Iconsax.grid_2;
    }

    final double fillPercentage = details.totalSeats == 0
        ? 0.0
        : (details.occupiedSeats / details.totalSeats).clamp(0.0, 1.0);

    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? XColors.darkCardBackground : XColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark 
              ? gradientColors[0].withValues(alpha: 0.15) 
              : gradientColors[0].withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: dark 
                ? Colors.black.withValues(alpha: 0.25) 
                : gradientColors[0].withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: XColors.white, size: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: gradientColors[0].withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${(fillPercentage * 100).toInt()}% Occupied',
                  style: TextStyle(
                    color: gradientColors[0],
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            details.slotName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            details.timing,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: dark ? XColors.textSecondary : XColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fillPercentage,
              backgroundColor: dark ? XColors.darkGrey.withValues(alpha: 0.15) : XColors.lightGrey,
              valueColor: AlwaysStoppedAnimation<Color>(gradientColors[0]),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SeatStat(label: 'Free', value: '${details.availableSeats}', color: const Color(0xFF05CD99)),
              _SeatStat(label: 'Filled', value: '${details.occupiedSeats}', color: const Color(0xFFFF4C61)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeatStat extends StatelessWidget {
  const _SeatStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 10, color: XColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
