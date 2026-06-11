import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/features/members/models/member_model.dart';

/// Premium card displaying member info in a list.
class XMemberCard extends StatelessWidget {
  const XMemberCard({
    super.key,
    required this.member,
    this.onTap,
    this.onCall,
    this.onWhatsApp,
  });

  final MemberModel member;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);
    final hasNoSeat = member.seatId.isEmpty || member.seatNumber == 'Unassigned';
    final computedStatus = hasNoSeat ? 'inactive' : member.status;
    final statusColor = XHelperFunctions.getMemberStatusColor(computedStatus);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: dark ? XColors.darkCardBackground : XColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: dark
                ? statusColor.withValues(alpha: 0.12)
                : statusColor.withValues(alpha: 0.06),
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
          children: [
            /// --- Gradient Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: member.photo.isEmpty
                    ? LinearGradient(
                        colors: [statusColor, statusColor.withValues(alpha: 0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(14),
                image: member.photo.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(member.photo),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: member.photo.isEmpty
                  ? Center(
                      child: Text(
                        member.fullName.isNotEmpty
                            ? member.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: XColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            /// --- Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Name + Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          member.fullName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [statusColor.withValues(alpha: 0.15), statusColor.withValues(alpha: 0.08)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          _capitalize(computedStatus.replaceAll('_', ' ')),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  /// Mobile
                  Row(
                    children: [
                      Icon(Iconsax.call, size: 13, color: dark ? XColors.textSecondary : XColors.darkGrey),
                      const SizedBox(width: 4),
                      Text(
                        member.mobile,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: dark ? XColors.textSecondary : XColors.darkGrey,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  /// Seat + Expiry Info Row
                  Row(
                    children: [
                      if (member.seatNumber.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: XColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Iconsax.grid_2, size: 11, color: XColors.primary),
                              const SizedBox(width: 3),
                              Text(
                                'Seat ${member.seatNumber}',
                                style: TextStyle(
                                  color: XColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: member.isExpired
                              ? XColors.error.withValues(alpha: 0.08)
                              : member.isExpiringSoon
                                  ? XColors.warning.withValues(alpha: 0.08)
                                  : (dark ? XColors.darkGrey.withValues(alpha: 0.3) : XColors.lightGrey),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.calendar,
                              size: 11,
                              color: member.isExpired
                                  ? XColors.error
                                  : member.isExpiringSoon
                                      ? XColors.warning
                                      : (dark ? XColors.textSecondary : XColors.darkGrey),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              member.isExpired
                                  ? 'Expired'
                                  : member.isExpiringSoon
                                      ? '${member.daysRemaining}d left'
                                      : XHelperFunctions.formatDate(member.expiryDate),
                              style: TextStyle(
                                color: member.isExpired
                                    ? XColors.error
                                    : member.isExpiringSoon
                                        ? XColors.warning
                                        : (dark ? XColors.textSecondary : XColors.darkGrey),
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// --- Action buttons
            const SizedBox(width: 4),
            Column(
              children: [
                if (onCall != null)
                  _ActionCircle(
                    icon: Iconsax.call,
                    color: XColors.primary,
                    dark: dark,
                    onTap: onCall!,
                  ),
                if (onWhatsApp != null) ...[
                  const SizedBox(height: 8),
                  _ActionCircle(
                    icon: Iconsax.message,
                    color: const Color(0xFF25D366),
                    dark: dark,
                    onTap: onWhatsApp!,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.icon,
    required this.color,
    required this.dark,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
