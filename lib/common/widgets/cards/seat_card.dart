import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/features/seats/models/seat_model.dart';

/// Seat card for grid/list view display.
class XSeatCard extends StatelessWidget {
  const XSeatCard({
    super.key,
    required this.seat,
    this.onTap,
    this.onLongPress,
  });

  final SeatModel seat;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  Color get _statusColor {
    switch (seat.status) {
      case 'available':
        return XColors.seatAvailable;
      case 'occupied':
        return seat.isExpiringSoon ? XColors.seatExpiringSoon : XColors.seatOccupied;
      case 'reserved':
        return XColors.seatReserved;
      case 'maintenance':
        return XColors.seatMaintenance;
      default:
        return XColors.grey;
    }
  }

  IconData get _statusIcon {
    switch (seat.status) {
      case 'available':
        return Iconsax.tick_circle;
      case 'occupied':
        return Iconsax.profile_2user;
      case 'reserved':
        return Iconsax.clock;
      case 'maintenance':
        return Iconsax.warning_2;
      default:
        return Iconsax.grid_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: XSizes.seatCardWidth,
        padding: const EdgeInsets.all(XSizes.sm + 4),
        decoration: BoxDecoration(
          color: dark ? XColors.darkCardBackground : XColors.white,
          borderRadius: BorderRadius.circular(XSizes.cardRadiusMd),
          border: Border.all(
            color: _statusColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _statusColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// --- Header: Seat Number + Status Dot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: XSizes.sm + 2,
                    vertical: XSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(XSizes.borderRadiusSm + 2),
                  ),
                  child: Text(
                    seat.seatNumber,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        ),
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor,
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: XSizes.sm + 2),

            /// --- Content
            if (seat.isAvailable) ...[
              Icon(_statusIcon, color: _statusColor, size: 28),
              const SizedBox(height: XSizes.xs),
              Text(
                'Available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ] else if (seat.status == 'maintenance') ...[
              Icon(_statusIcon, color: _statusColor, size: 28),
              const SizedBox(height: XSizes.xs),
              Text(
                'Maintenance',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ] else ...[
              /// Occupied / Reserved — show member info
              Text(
                seat.memberName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                seat.memberMobile,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: XSizes.xs),
              if (seat.memberExpiry != null)
                Row(
                  children: [
                    Icon(
                      Iconsax.calendar,
                      size: 12,
                      color: seat.isExpiringSoon
                          ? XColors.seatExpiringSoon
                          : (dark ? XColors.softGrey : XColors.darkGrey),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        seat.isExpiringSoon
                            ? 'Expires in ${seat.memberExpiry!.difference(DateTime.now()).inDays} days'
                            : XHelperFunctions.formatDate(seat.memberExpiry!),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: seat.isExpiringSoon
                                  ? XColors.seatExpiringSoon
                                  : null,
                              fontWeight: seat.isExpiringSoon
                                  ? FontWeight.w600
                                  : null,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}
