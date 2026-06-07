import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/cards/seat_card.dart';
import 'package:edox_library/common/widgets/containers/status_badge.dart';
import 'package:edox_library/common/widgets/buttons/primary_button.dart';
import 'package:edox_library/common/widgets/inputs/text_field.dart';
import 'package:edox_library/features/seats/models/seat_model.dart';
import 'package:edox_library/features/seats/controllers/seats_controller.dart';

class SeatsOverviewScreen extends StatelessWidget {
  const SeatsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SeatsController());
    final dark = XHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(XSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Seats', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                  Obx(
                    () => Row(
                      children: [
                        _ViewToggle(icon: Iconsax.grid_2, selected: controller.isGridView.value, onTap: () => controller.isGridView.value = true, dark: dark),
                        const SizedBox(width: 8),
                        _ViewToggle(icon: Iconsax.menu, selected: !controller.isGridView.value, onTap: () => controller.isGridView.value = false, dark: dark),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Stats Bar
              Obx(() {
                final all = controller.allSeats;
                final available = all.where((s) => s.status == 'available').length;
                final occupied = all.where((s) => s.status == 'occupied').length;
                final maintenance = all.where((s) => s.status == 'maintenance').length;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: XSizes.md, vertical: XSizes.sm + 4),
                  decoration: BoxDecoration(
                    color: dark ? XColors.darkCardBackground : XColors.white,
                    borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
                    boxShadow: [BoxShadow(color: XColors.primary.withValues(alpha: 0.04), blurRadius: 12)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(value: '${all.length}', label: 'Total', color: XColors.primary),
                      _StatDivider(dark: dark),
                      _StatItem(value: '$available', label: 'Available', color: XColors.seatAvailable),
                      _StatDivider(dark: dark),
                      _StatItem(value: '$occupied', label: 'Occupied', color: XColors.seatOccupied),
                      _StatDivider(dark: dark),
                      _StatItem(value: '$maintenance', label: 'Maint.', color: XColors.seatMaintenance),
                    ],
                  ),
                );
              }),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Search
              TextField(
                controller: controller.searchController,
                onChanged: (val) => controller.searchQuery.value = val,
                decoration: InputDecoration(
                  hintText: 'Search seat or member...',
                  prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.searchController,
                    builder: (_, value, __) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        onPressed: () {
                          controller.searchController.clear();
                          controller.searchQuery.value = '';
                        },
                        icon: const Icon(Icons.close, size: 20),
                      );
                    },
                  ),
                  filled: true,
                  fillColor: dark ? XColors.darkCardBackground : XColors.lightBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(XSizes.borderRadiusLg), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(XSizes.borderRadiusLg), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(XSizes.borderRadiusLg), borderSide: const BorderSide(color: XColors.primary, width: 1)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: XSizes.md, vertical: XSizes.sm + 4),
                ),
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Legend
              Wrap(
                spacing: 12,
                children: const [
                  _Legend(color: XColors.seatAvailable, label: 'Available'),
                  _Legend(color: XColors.seatOccupied, label: 'Occupied'),
                  _Legend(color: XColors.seatExpiringSoon, label: 'Expiring'),
                  _Legend(color: XColors.seatMaintenance, label: 'Maintenance'),
                ],
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Seats Grid/List
              Expanded(
                child: Obx(() {
                  final filtered = controller.filteredSeats;
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.search_normal, size: 48, color: XColors.softGrey),
                          const SizedBox(height: 12),
                          Text('No seats found', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: XColors.darkGrey)),
                          const SizedBox(height: 4),
                          Text('Try a different search term', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    );
                  }
                  return controller.isGridView.value
                      ? GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: XSizes.gridViewSpacing,
                            crossAxisSpacing: XSizes.gridViewSpacing,
                            childAspectRatio: 0.95,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return XSeatCard(
                              seat: filtered[index], 
                              onTap: () => _showEditSeatSheet(context, controller, filtered[index]),
                              onLongPress: () {},
                            );
                          },
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: XSizes.sm),
                          itemBuilder: (context, index) {
                            return _SeatListTile(
                              seat: filtered[index], 
                              dark: dark,
                              onTap: () => _showEditSeatSheet(context, controller, filtered[index]),
                            );
                          },
                        );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSeatsSheet(context, controller),
        backgroundColor: XColors.primary,
        icon: const Icon(Iconsax.add, color: XColors.white),
        label: const Text('Add Seats', style: TextStyle(color: XColors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showAddSeatsSheet(BuildContext context, SeatsController controller) {
    final prefixCtrl = TextEditingController(text: controller.allSeats.isNotEmpty
        ? controller.allSeats.last.seatNumber.split('-').first
        : 'A');
    final countCtrl = TextEditingController(text: '1');
    final startCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
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

              Obx(() => XPrimaryButton(
                text: 'Add Seats',
                icon: Iconsax.add,
                isLoading: controller.isAddingSeats.value,
                onPressed: () {
                  final prefix = prefixCtrl.text.trim();
                  final count = int.tryParse(countCtrl.text.trim()) ?? 1;
                  final start = int.tryParse(startCtrl.text.trim()) ?? (controller.allSeats.length + 1);

                  if (prefix.isEmpty) {
                    Get.snackbar('Error', 'Please enter a row prefix', snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.error, colorText: XColors.white);
                    return;
                  }
                  if (count < 1 || count > 50) {
                    Get.snackbar('Error', 'Enter between 1–50 seats', snackPosition: SnackPosition.BOTTOM, backgroundColor: XColors.error, colorText: XColors.white);
                    return;
                  }

                  controller.addSeats(prefix, start, count);
                },
              )),
              const SizedBox(height: XSizes.spaceBtwItems),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showEditSeatSheet(BuildContext context, SeatsController controller, SeatModel seat) {
    final seatNumCtrl = TextEditingController(text: seat.seatNumber);
    String status = seat.status;

    Get.bottomSheet(
      Container(
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
                  builder: (context, setState) {
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
                        if (v != null) setState(() => status = v);
                      },
                    );
                  }
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
                          'This seat is currently occupied by ${seat.memberName}. Its status cannot be changed directly.',
                          style: const TextStyle(fontSize: 12, color: XColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: XSizes.spaceBtwSections),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back(); // close sheet
                        controller.deleteSeat(seat);
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
                        
                        controller.updateSeat(updatedSeat);
                        Get.back();
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
      isScrollControlled: true,
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.icon, required this.selected, required this.onTap, required this.dark});
  final IconData icon; final bool selected; final VoidCallback onTap; final bool dark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? XColors.primary : (dark ? XColors.darkCardBackground : XColors.lightBackground),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: selected ? XColors.white : XColors.darkGrey),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label, required this.color});
  final String value; final String label; final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: color)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.dark});
  final bool dark;
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 30, color: dark ? XColors.darkGrey : XColors.softGrey);
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color; final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _SeatListTile extends StatelessWidget {
  const _SeatListTile({required this.seat, required this.dark, this.onTap});
  final SeatModel seat; final bool dark; final VoidCallback? onTap;

  Color get _statusColor {
    switch (seat.status) {
      case 'available': return XColors.seatAvailable;
      case 'occupied': return seat.isExpiringSoon ? XColors.seatExpiringSoon : XColors.seatOccupied;
      case 'maintenance': return XColors.seatMaintenance;
      default: return XColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(XSizes.sm + 4),
        decoration: BoxDecoration(
          color: dark ? XColors.darkCardBackground : XColors.white,
          borderRadius: BorderRadius.circular(XSizes.cardRadiusMd),
          border: Border(left: BorderSide(color: _statusColor, width: 3)),
        ),
        child: Row(
          children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(seat.seatNumber, style: TextStyle(fontWeight: FontWeight.w700, color: _statusColor, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: seat.isAvailable
                ? Text('Available', style: TextStyle(color: _statusColor, fontWeight: FontWeight.w500))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(seat.memberName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(seat.memberMobile, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
          ),
          XStatusBadge(text: seat.status, color: _statusColor),
        ],
      ),
    ),
    );
  }
}
