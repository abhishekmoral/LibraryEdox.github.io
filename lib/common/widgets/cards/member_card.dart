import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/containers/status_badge.dart';
import 'package:edox_library/features/members/models/member_model.dart';

/// Card displaying member info in a list.
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(XSizes.md),
        decoration: BoxDecoration(
          color: dark ? XColors.darkCardBackground : XColors.white,
          borderRadius: BorderRadius.circular(XSizes.cardRadiusMd),
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
        child: Row(
          children: [
            /// --- Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: XColors.primary.withValues(alpha: 0.1),
              backgroundImage:
                  member.photo.isNotEmpty ? NetworkImage(member.photo) : null,
              child: member.photo.isEmpty
                  ? Text(
                      member.fullName.isNotEmpty
                          ? member.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: XColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: XSizes.sm + 4),

            /// --- Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          member.fullName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      XStatusBadge(
                        text: member.status.replaceAll('_', ' '),
                        color:
                            XHelperFunctions.getMemberStatusColor(member.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.mobile,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (member.seatNumber.isNotEmpty) ...[
                        Icon(Iconsax.grid_2,
                            size: 14, color: XColors.primary.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text(
                          'Seat ${member.seatNumber}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: XColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(width: XSizes.sm),
                      ],
                      Icon(Iconsax.calendar,
                          size: 14,
                          color: dark ? XColors.softGrey : XColors.darkGrey),
                      const SizedBox(width: 4),
                      Text(
                        'Expires: ${XHelperFunctions.formatDate(member.expiryDate)}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// --- Actions
            Column(
              children: [
                if (onCall != null)
                  IconButton(
                    onPressed: onCall,
                    icon: const Icon(Iconsax.call, size: 20),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (onWhatsApp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: IconButton(
                      onPressed: onWhatsApp,
                      icon: const Icon(Iconsax.message, size: 20,
                          color: Color(0xFF25D366)),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
