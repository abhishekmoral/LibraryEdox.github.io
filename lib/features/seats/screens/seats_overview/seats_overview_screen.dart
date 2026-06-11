import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/cards/seat_card.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';
import 'package:edox_library/features/seats/models/seat_model.dart';
import 'package:edox_library/features/seats/controllers/seats_cubit.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/features/slots/models/slot_model.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/members/controllers/members_cubit.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/members/screens/member_detail/member_detail_screen.dart';

class SeatsOverviewScreen extends StatefulWidget {
  const SeatsOverviewScreen({super.key});

  @override
  State<SeatsOverviewScreen> createState() => _SeatsOverviewScreenState();
}

class _SeatsOverviewScreenState extends State<SeatsOverviewScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seatsCubit = context.watch<SeatsCubit>();
    final seatsState = seatsCubit.state;
    final dark = XHelperFunctions.isDarkMode(context);

    final all = seatsCubit.resolvedSeats;
    final available = all.where((s) => s.status == 'available').length;
    final occupied = all.where((s) => s.status == 'occupied').length;
    final maintenance = all.where((s) => s.status == 'maintenance').length;
    final filtered = seatsCubit.filteredSeats;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: XSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: XSizes.defaultSpace),

              /// --- Header (stays pinned)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [XColors.primary, Color(0xFF868CFF)],
                    ).createShader(bounds),
                    child: Text(
                      'Seats',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: XColors.white,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                  Row(
                    children: [
                      _ViewToggle(
                        icon: Iconsax.grid_2,
                        selected: seatsState.isGridView,
                        onTap: () {
                          if (!seatsState.isGridView) {
                            seatsCubit.toggleViewMode();
                          }
                        },
                        dark: dark,
                      ),
                      const SizedBox(width: 8),
                      _ViewToggle(
                        icon: Iconsax.menu,
                        selected: !seatsState.isGridView,
                        onTap: () {
                          if (seatsState.isGridView) {
                            seatsCubit.toggleViewMode();
                          }
                        },
                        dark: dark,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Everything below scrolls together
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    /// --- Stats Bar (scrolls up)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: dark ? XColors.darkCardBackground : XColors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: dark ? XColors.primary.withValues(alpha: 0.08) : XColors.primary.withValues(alpha: 0.04),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: dark
                                  ? Colors.black.withValues(alpha: 0.2)
                                  : XColors.primary.withValues(alpha: 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(value: '${all.length}', label: 'Total', gradient: [XColors.primary, const Color(0xFF868CFF)]),
                            _StatDivider(dark: dark),
                            _StatItem(value: '$available', label: 'Free', gradient: [const Color(0xFF05CD99), const Color(0xFF61EFCD)]),
                            _StatDivider(dark: dark),
                            _StatItem(value: '$occupied', label: 'Occupied', gradient: [const Color(0xFFFF4C61), const Color(0xFFFF8F9E)]),
                            _StatDivider(dark: dark),
                            _StatItem(value: '$maintenance', label: 'Maint.', gradient: [const Color(0xFFFF8A00), const Color(0xFFFFC837)]),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: XSizes.spaceBtwItems)),

                    /// --- Search (scrolls up)
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: BoxDecoration(
                          color: dark ? XColors.darkCardBackground : XColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: dark ? XColors.primary.withValues(alpha: 0.08) : XColors.primary.withValues(alpha: 0.04),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: dark
                                  ? Colors.black.withValues(alpha: 0.15)
                                  : XColors.primary.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (val) => seatsCubit.setSearchQuery(val),
                          decoration: InputDecoration(
                            hintText: 'Search seat or member...',
                            hintStyle: TextStyle(
                              color: dark ? XColors.textSecondary : XColors.softGrey,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Iconsax.search_normal,
                              size: 20,
                              color: dark ? XColors.textSecondary : XColors.softGrey,
                            ),
                            suffixIcon: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: searchController,
                              builder: (context, value, __) {
                                if (value.text.isEmpty) return const SizedBox.shrink();
                                return IconButton(
                                  onPressed: () {
                                    searchController.clear();
                                    seatsCubit.setSearchQuery('');
                                  },
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: XColors.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.close, size: 14, color: XColors.error),
                                  ),
                                );
                              },
                            ),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: XSizes.md, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: XSizes.spaceBtwItems)),

                    /// --- Legend (scrolls up)
                    SliverToBoxAdapter(
                      child: Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: const [
                          _Legend(gradient: [Color(0xFF05CD99), Color(0xFF61EFCD)], label: 'Available'),
                          _Legend(gradient: [Color(0xFFFF4C61), Color(0xFFFF8F9E)], label: 'Occupied'),
                          _Legend(gradient: [Color(0xFFFFC837), Color(0xFFFFE08A)], label: 'Expiring'),
                          _Legend(gradient: [Color(0xFFFF8A00), Color(0xFFFFC837)], label: 'Maintenance'),
                        ],
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: XSizes.spaceBtwItems)),

                    /// --- Seats content
                    if (filtered.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: XColors.primary.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Iconsax.search_normal, size: 40, color: XColors.textSecondary),
                              ),
                              const SizedBox(height: 16),
                              Text('No seats found', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('Try a different search term', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: XColors.textSecondary)),
                            ],
                          ),
                        ),
                      )
                    else if (seatsState.isGridView)
                      SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: XSizes.gridViewSpacing,
                          crossAxisSpacing: XSizes.gridViewSpacing,
                          childAspectRatio: 0.72,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => XSeatCard(
                            seat: filtered[index],
                            onTap: () => _showEditSeatSheet(context, seatsCubit, filtered[index]),
                            onLongPress: () {},
                          ),
                          childCount: filtered.length,
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: XSizes.sm + 2),
                            child: _SeatListTile(
                              seat: filtered[index],
                              dark: dark,
                              onTap: () => _showEditSeatSheet(context, seatsCubit, filtered[index]),
                            ),
                          ),
                          childCount: filtered.length,
                        ),
                      ),

                    /// Bottom padding
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [XColors.primary, Color(0xFF7B5AFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: XColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showAddSeatsSheet(context, seatsCubit),
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.add, color: XColors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Add Seats',
                    style: TextStyle(color: XColors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSeatsSheet(BuildContext context, SeatsCubit seatsCubit) {
    final prefixCtrl = TextEditingController(
      text: seatsCubit.state.allSeats.isNotEmpty
          ? seatsCubit.state.allSeats.last.seatNumber.split('-').first
          : 'A',
    );
    final countCtrl = TextEditingController(text: '1');
    final startCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(XSizes.defaultSpace),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: XColors.softGrey, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  Text('Add Seats', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('Add one or multiple seats at once', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: XSizes.spaceBtwSections),

                  XTextField(
                    controller: prefixCtrl,
                    label: 'Row Prefix',
                    hint: 'e.g. A, B, C',
                    prefixIcon: Iconsax.text,
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(
                    controller: startCtrl,
                    label: 'Start Number',
                    hint: 'e.g. 1',
                    prefixIcon: Iconsax.hashtag,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  XTextField(
                    controller: countCtrl,
                    label: 'Number of Seats',
                    hint: 'How many seats to add',
                    prefixIcon: Iconsax.grid_2,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: XSizes.spaceBtwSections),

                  BlocBuilder<SeatsCubit, SeatsState>(
                    bloc: seatsCubit,
                    builder: (context, state) {
                      return XPrimaryButton(
                        text: 'Add Seats',
                        icon: Iconsax.add,
                        isLoading: state.isAddingSeats,
                        onPressed: () {
                          final prefix = prefixCtrl.text.trim();
                          final count = int.tryParse(countCtrl.text.trim()) ?? 1;
                          final start = int.tryParse(startCtrl.text.trim()) ?? (state.allSeats.length + 1);

                          if (prefix.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a row prefix'), backgroundColor: XColors.error),
                            );
                            return;
                          }
                          if (count < 1 || count > 50) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Enter between 1–50 seats'), backgroundColor: XColors.error),
                            );
                            return;
                          }

                          seatsCubit.addSeats(context, prefix, start, count);
                        },
                      );
                    },
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

  void _showEditSeatSheet(BuildContext context, SeatsCubit seatsCubit, SeatModel seat) {
    final seatNumCtrl = TextEditingController(text: seat.seatNumber);
    String status = seat.status;
    final dark = XHelperFunctions.isDarkMode(context);

    final membersCubit = context.read<MembersCubit>();
    final seatMembers = membersCubit.state.allMembers.where(
      (m) => m.seatNumber == seat.seatNumber && m.status == 'active'
    ).toList();
    final memberNames = seatMembers.isNotEmpty
        ? seatMembers.map((m) => m.fullName).join(' & ')
        : seat.memberName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(XSizes.defaultSpace),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: XColors.softGrey, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: XSizes.spaceBtwItems),
                  Text('Edit Seat', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: XSizes.spaceBtwSections),

                  XTextField(
                    controller: seatNumCtrl,
                    label: 'Seat Number',
                    prefixIcon: Iconsax.grid_2,
                  ),
                  const SizedBox(height: XSizes.spaceBtwItems),

                  if (seat.isAvailable || seat.status == 'maintenance')
                    StatefulBuilder(
                      builder: (context, setModalState) {
                        return DropdownButtonFormField<String>(
                          value: status,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            prefixIcon: const Icon(Iconsax.info_circle),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(XSizes.borderRadiusMd)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'available', child: Text('Available')),
                            DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setModalState(() {
                                status = v;
                              });
                            }
                          },
                        );
                      },
                    ),
                  if (seat.status == 'occupied')
                    Container(
                      padding: const EdgeInsets.all(XSizes.md),
                      decoration: BoxDecoration(
                        color: XColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
                      ),
                      child: Row(
                        children: [
                          const Icon(Iconsax.warning_2, color: XColors.warning),
                          const SizedBox(width: XSizes.sm),
                          Expanded(
                            child: Text(
                              'This seat is currently occupied by $memberNames. Its status cannot be changed directly.',
                              style: const TextStyle(fontSize: 12, color: XColors.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: XSizes.spaceBtwItems),
                  Text(
                    'Slot-wise Occupancy',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dark ? XColors.white : XColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getSeatOccupancyBreakdown(context, seat.seatNumber),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text(
                          'Error loading occupancy breakdown',
                          style: TextStyle(color: XColors.error, fontSize: 12),
                        );
                      }

                      final list = snapshot.data!;
                      return Container(
                        decoration: BoxDecoration(
                          color: dark ? XColors.darkCardBackground : XColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: dark ? XColors.primary.withValues(alpha: 0.15) : XColors.primary.withValues(alpha: 0.08),
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: dark ? XColors.darkGrey.withValues(alpha: 0.3) : XColors.lightGrey,
                          ),
                          itemBuilder: (context, idx) {
                            final item = list[idx];
                            final isOccupied = item['status'] == 'occupied';
                            final isMaint = item['status'] == 'maintenance';
                            final member = item['member'] as MemberModel?;

                            Color statusColor = const Color(0xFF05CD99); // available
                            IconData statusIcon = Iconsax.tick_circle;
                            String infoText = 'Available';

                            if (isOccupied) {
                              statusColor = const Color(0xFFFF4C61);
                              statusIcon = Iconsax.user;
                              infoText = item['memberMobile'].toString().trim().isNotEmpty
                                  ? '${item['memberName']} (${item['memberMobile']})'
                                  : item['memberName'];
                            } else if (isMaint) {
                              statusColor = const Color(0xFFFF8A00);
                              statusIcon = Iconsax.warning_2;
                              infoText = 'Maintenance';
                            }

                            final Widget rowContent = Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(statusIcon, color: statusColor, size: 16),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['slotName'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: dark ? XColors.white : XColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item['timing'],
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontSize: 10,
                                                color: XColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      infoText,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isOccupied
                                            ? (dark ? XColors.white : XColors.textPrimary)
                                            : statusColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (member != null) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 14,
                                      color: dark ? XColors.textSecondary : XColors.darkGrey,
                                    ),
                                  ],
                                ],
                              ),
                            );

                            if (member != null) {
                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context); // Close Edit Seat Sheet
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MemberDetailScreen(member: member),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: rowContent,
                              );
                            }

                            return rowContent;
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: XSizes.spaceBtwSections),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext); // Close sheet
                            seatsCubit.deleteSeat(context, seat);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: XColors.error,
                            side: const BorderSide(color: XColors.error),
                            padding: const EdgeInsets.symmetric(vertical: XSizes.md),
                          ),
                          child: const Text('Delete Seat'),
                        ),
                      ),
                      const SizedBox(width: XSizes.spaceBtwItems),
                      Expanded(
                        child: XPrimaryButton(
                          text: 'Save',
                          icon: Iconsax.tick_circle,
                          onPressed: () {
                            if (seatNumCtrl.text.trim().isEmpty) return;
                            
                            final updatedSeat = seat.copyWith(
                              seatNumber: seatNumCtrl.text.trim(),
                              status: seat.status == 'occupied' ? 'occupied' : status,
                              updatedAt: DateTime.now(),
                            );
                            
                            Navigator.pop(dialogContext); // Close sheet
                            seatsCubit.updateSeat(context, updatedSeat);
                          },
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

  Future<List<Map<String, dynamic>>> _getSeatOccupancyBreakdown(BuildContext context, String seatNumber) async {
    final libraryId = AuthenticationRepository.instance.currentUser?.uid ?? '';
    final slotsCubit = context.read<SlotsCubit>();
    final loadedSlots = slotsCubit.state.slots;
    final List<SlotModel> slots = [];
    if (!loadedSlots.any((s) => s.id == 'default')) {
      slots.add(
        SlotModel(
          id: 'default',
          name: 'Complete Shift',
          startTime: '12:00 AM',
          endTime: '11:59 PM',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    slots.addAll(loadedSlots);

    // Fetch all members assigned to this seat number in this library
    final membersSnapshot = await FirebaseFirestore.instance
        .collection('libraries')
        .doc(libraryId)
        .collection('members')
        .where('seatNumber', isEqualTo: seatNumber)
        .get();

    // Fetch the physical seat base details to check if it's in maintenance
    final seatSnapshot = await FirebaseFirestore.instance
        .collection('libraries')
        .doc(libraryId)
        .collection('seats')
        .where('seatNumber', isEqualTo: seatNumber)
        .limit(1)
        .get();

    final baseSeatStatus = seatSnapshot.docs.isNotEmpty
        ? (seatSnapshot.docs.first.data()['status'] ?? 'available')
        : 'available';

    final slotMap = {for (var s in slots) s.id: s};
    final List<Map<String, dynamic>> breakdown = [];

    for (final slot in slots) {
      DocumentSnapshot<Map<String, dynamic>>? memberDoc;
      bool isExact = false;
      
      // 1. Exact match first
      for (final doc in membersSnapshot.docs) {
        if (doc.data()['slotId'] == slot.id && doc.data()['status'] == 'active') {
          memberDoc = doc;
          isExact = true;
          break;
        }
      }

      // 2. Overlapping slot match next
      if (memberDoc == null) {
        for (final doc in membersSnapshot.docs) {
          if (doc.data()['status'] == 'active') {
            final memberSlotId = doc.data()['slotId'];
            final memberSlot = slotMap[memberSlotId];
            if (memberSlot != null) {
              final overlap = slotsCubit.doSlotsOverlap(
                slot.name, slot.startTime, slot.endTime,
                memberSlot.name, memberSlot.startTime, memberSlot.endTime,
              );
              if (overlap) {
                memberDoc = doc;
                break;
              }
            }
          }
        }
      }

      if (memberDoc != null) {
        final memberData = memberDoc.data()!;
        final memberObj = MemberModel.fromSnapshot(memberDoc);
        
        if (!isExact) {
          breakdown.add({
            'slotName': slot.name,
            'timing': '${slot.startTime} - ${slot.endTime}',
            'status': 'occupied',
            'memberName': 'Unavailable',
            'memberMobile': '',
            'memberExpiry': null,
            'member': memberObj,
          });
        } else {
          breakdown.add({
            'slotName': slot.name,
            'timing': '${slot.startTime} - ${slot.endTime}',
            'status': 'occupied',
            'memberName': memberData['fullName'] ?? '',
            'memberMobile': memberData['mobile'] ?? '',
            'memberExpiry': memberData['expiryDate'],
            'member': memberObj,
          });
        }
      } else {
        breakdown.add({
          'slotName': slot.name,
          'timing': '${slot.startTime} - ${slot.endTime}',
          'status': baseSeatStatus == 'maintenance' ? 'maintenance' : 'available',
          'memberName': '',
          'memberMobile': '',
          'memberExpiry': null,
          'member': null,
        });
      }
    }

    return breakdown;
  }
}

// ═══════════════════════════════════════════════════════════════
// VIEW TOGGLE
// ═══════════════════════════════════════════════════════════════
class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.icon, required this.selected, required this.onTap, required this.dark});
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: [XColors.primary, Color(0xFF7B5AFF)])
              : null,
          color: selected ? null : (dark ? XColors.darkCardBackground : XColors.white),
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? null
              : Border.all(color: dark ? XColors.darkGrey.withValues(alpha: 0.4) : XColors.borderPrimary),
          boxShadow: selected
              ? [BoxShadow(color: XColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Icon(icon, size: 18, color: selected ? XColors.white : (dark ? XColors.softGrey : XColors.darkGrey)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STAT ITEM (with gradient number)
// ═══════════════════════════════════════════════════════════════
class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label, required this.gradient});
  final String value;
  final String label;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(colors: gradient).createShader(bounds),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: XColors.white),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STAT DIVIDER
// ═══════════════════════════════════════════════════════════════
class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.dark});
  final bool dark;
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              dark ? XColors.darkGrey.withValues(alpha: 0.5) : XColors.softGrey.withValues(alpha: 0.6),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
// LEGEND (with gradient dot)
// ═══════════════════════════════════════════════════════════════
class _Legend extends StatelessWidget {
  const _Legend({required this.gradient, required this.label});
  final List<Color> gradient;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: gradient),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SEAT LIST TILE (for list view)
// ═══════════════════════════════════════════════════════════════
class _SeatListTile extends StatelessWidget {
  const _SeatListTile({required this.seat, required this.dark, this.onTap});
  final SeatModel seat;
  final bool dark;
  final VoidCallback? onTap;

  List<Color> get _statusGradient {
    switch (seat.status) {
      case 'available':
        return [const Color(0xFF05CD99), const Color(0xFF61EFCD)];
      case 'occupied':
        return seat.isExpiringSoon
            ? [const Color(0xFFFFC837), const Color(0xFFFFE08A)]
            : [const Color(0xFFFF4C61), const Color(0xFFFF8F9E)];
      case 'maintenance':
        return [const Color(0xFFFF8A00), const Color(0xFFFFC837)];
      default:
        return [XColors.grey, XColors.softGrey];
    }
  }

  Color get _statusColor => _statusGradient[0];

  @override
  Widget build(BuildContext context) {
    final slotsCubit = context.watch<SlotsCubit>();
    final membersCubit = context.watch<MembersCubit>();
    final allSlots = slotsCubit.state.slots;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: dark ? XColors.darkCardBackground : XColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _statusColor.withValues(alpha: dark ? 0.15 : 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.black.withValues(alpha: 0.2)
                  : _statusColor.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                /// Gradient seat number badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _statusGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    seat.seatNumber,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: XColors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: seat.isAvailable
                      ? Text('Available', style: TextStyle(color: _statusColor, fontWeight: FontWeight.w600, fontSize: 14))
                      : seat.status == 'maintenance'
                          ? Text('Maintenance', style: TextStyle(color: _statusColor, fontWeight: FontWeight.w600, fontSize: 14))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(seat.memberName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(seat.memberMobile, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: dark ? XColors.textSecondary : XColors.darkGrey)),
                              ],
                            ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _statusColor.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    seat.status[0].toUpperCase() + seat.status.substring(1),
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: dark ? XColors.darkGrey.withValues(alpha: 0.3) : XColors.lightGrey),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: allSlots.map((slot) {
                final member = membersCubit.state.allMembers.firstWhereOrNull(
                  (m) => m.seatNumber == seat.seatNumber && m.slotId == slot.id && m.status == 'active'
                );
                final isOccupied = member != null;
                final isMaint = seat.status == 'maintenance';

                Color statusColor = const Color(0xFF05CD99); // available
                String statusLabel = 'Free';
                if (isOccupied) {
                  statusColor = const Color(0xFFFF4C61); // occupied
                  statusLabel = member.fullName;
                } else if (isMaint) {
                  statusColor = const Color(0xFFFF8A00); // maintenance
                  statusLabel = 'Maint.';
                }

                final isCurrentSlot = slot.id == slotsCubit.state.selectedSlotId;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrentSlot 
                          ? statusColor.withValues(alpha: 0.5)
                          : statusColor.withValues(alpha: 0.15),
                      width: isCurrentSlot ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${slot.name}: $statusLabel',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrentSlot ? FontWeight.w800 : FontWeight.w600,
                          color: dark ? XColors.white : XColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
