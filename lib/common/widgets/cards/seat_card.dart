import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/features/seats/models/seat_model.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/features/slots/models/slot_model.dart';
import 'package:edox_library/features/members/controllers/members_cubit.dart';

/// Premium seat card for grid view display.
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

  List<Color> get _statusGradient {
    switch (seat.status) {
      case 'available':
        return [const Color(0xFF05CD99), const Color(0xFF61EFCD)];
      case 'occupied':
        return seat.isExpiringSoon
            ? [const Color(0xFFFFC837), const Color(0xFFFFE08A)]
            : [const Color(0xFFFF4C61), const Color(0xFFFF8F9E)];
      case 'reserved':
        return [const Color(0xFF868CFF), const Color(0xFFA78BFA)];
      case 'maintenance':
        return [const Color(0xFFFF8A00), const Color(0xFFFFC837)];
      default:
        return [XColors.grey, XColors.softGrey];
    }
  }

  Color get _statusColor => _statusGradient[0];

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: dark ? XColors.darkCardBackground : XColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _statusColor.withValues(alpha: dark ? 0.2 : 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.black.withValues(alpha: 0.25)
                  : _statusColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// --- Header: Seat Number Badge + Glowing Status Dot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    seat.seatNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: XColors.white,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Pulsing dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_statusColor, _statusColor.withValues(alpha: 0.4)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// --- Content
            if (seat.isAvailable) ...[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_statusIcon, color: _statusColor, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                'Available',
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ] else if (seat.status == 'maintenance') ...[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_statusIcon, color: _statusColor, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                'Maintenance',
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ] else ...[
              /// Occupied — show member info
              ...() {
                final displayName = seat.memberName;
                final displayMobile = seat.memberMobile;
                final displayExpiry = seat.memberExpiry;
                final bool showSingleDetails = displayName.isNotEmpty;

                return [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          fontSize: 13,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (showSingleDetails) ...[
                    Row(
                      children: [
                        Icon(Iconsax.call, size: 10, color: dark ? XColors.textSecondary : XColors.darkGrey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            displayMobile,
                            style: TextStyle(
                              fontSize: 11,
                              color: dark ? XColors.textSecondary : XColors.darkGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (displayExpiry != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: seat.isExpiringSoon
                              ? XColors.warning.withValues(alpha: 0.1)
                              : (dark ? XColors.darkGrey.withValues(alpha: 0.3) : XColors.lightGrey),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.calendar,
                              size: 9,
                              color: seat.isExpiringSoon ? XColors.warning : (dark ? XColors.textSecondary : XColors.darkGrey),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                seat.isExpiringSoon
                                    ? '${displayExpiry.difference(DateTime.now()).inDays}d left'
                                    : XHelperFunctions.formatDate(displayExpiry),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: seat.isExpiringSoon ? XColors.warning : (dark ? XColors.textSecondary : XColors.darkGrey),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ];
              }(),
            ],

            const SizedBox(height: 10),
            Divider(height: 1, color: dark ? XColors.darkGrey.withValues(alpha: 0.3) : XColors.lightGrey),
            const SizedBox(height: 8),

            /// Slot-wise breakdown on the card container
            ...() {
              final slotCubit = context.read<SlotsCubit>();
              final membersCubit = context.read<MembersCubit>();
              
              final slotMap = <String, SlotModel>{};
              for (final s in slotCubit.state.slots) {
                slotMap[s.id] = s;
              }
              if (!slotMap.containsKey('default')) {
                slotMap['default'] = SlotModel(
                  id: 'default',
                  name: 'Complete Shift',
                  startTime: '12:00 AM',
                  endTime: '11:59 PM',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
              }

              final allSlots = slotCubit.state.slots;

              return allSlots.map((slot) {
                final seatMembers = membersCubit.state.allMembers.where(
                  (m) => m.seatNumber == seat.seatNumber && m.status == 'active'
                ).toList();

                // Resolve which member occupies this slot (exact match first, then overlapping slot)
                var member = seatMembers.firstWhereOrNull((m) => m.slotId == slot.id);
                final isExact = member != null;
                
                member ??= seatMembers.firstWhereOrNull((m) {
                  final memberSlot = slotMap[m.slotId];
                  if (memberSlot == null) return false;
                  return slotCubit.doSlotsOverlap(
                    slot.name, slot.startTime, slot.endTime,
                    memberSlot.name, memberSlot.startTime, memberSlot.endTime,
                  );
                });

                final isOccupied = member != null;
                final isMaint = seat.status == 'maintenance';

                Color statusColor = const Color(0xFF05CD99); // available
                String statusLabel = 'Free';
                if (isOccupied) {
                  statusColor = const Color(0xFFFF4C61); // occupied
                  if (!isExact) {
                    statusLabel = 'Unavail.';
                  } else {
                    statusLabel = member.fullName;
                  }
                } else if (isMaint) {
                  statusColor = const Color(0xFFFF8A00); // maintenance
                  statusLabel = 'Maint.';
                }

                final isCurrentSlot = slot.id == slotCubit.state.selectedSlotId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
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
                      Expanded(
                        child: Text(
                          slot.name,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isCurrentSlot ? FontWeight.w800 : FontWeight.w500,
                            color: isCurrentSlot 
                                ? (dark ? XColors.white : XColors.textPrimary)
                                : (dark ? XColors.textSecondary : XColors.darkGrey),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isOccupied 
                                ? (dark ? XColors.white : XColors.textPrimary) 
                                : statusColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              });
            }(),
          ],
        ),
      ),
    );
  }
}
