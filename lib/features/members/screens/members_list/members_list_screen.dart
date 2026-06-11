import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/cards/member_card.dart';
import 'package:edox_library/common/widgets/empty_states/empty_state.dart';
import 'package:edox_library/features/members/screens/member_detail/member_detail_screen.dart';
import 'package:edox_library/features/members/controllers/members_cubit.dart';
import 'package:edox_library/data/services/whatsapp_service.dart';

class MembersListScreen extends StatelessWidget {
  const MembersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);
    final membersCubit = context.watch<MembersCubit>();
    final state = membersCubit.state;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: XSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: XSizes.defaultSpace),

              /// --- Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [XColors.primary, Color(0xFF868CFF)],
                    ).createShader(bounds),
                    child: Text(
                      'Members',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: XColors.white,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          XColors.primary.withValues(alpha: 0.12),
                          XColors.primary.withValues(alpha: 0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: XColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Iconsax.people, size: 14, color: XColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${state.displayMembersList.length}',
                          style: const TextStyle(
                            color: XColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Everything below scrolls together
              Expanded(
                child: () {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final members = state.displayMembersList;
                  final isSearching = state.searchQuery.isNotEmpty;

                  return CustomScrollView(
                    slivers: [
                      /// --- Search (scrolls up)
                      SliverToBoxAdapter(
                        child: _SearchField(membersCubit: membersCubit, dark: dark),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: XSizes.spaceBtwItems)),

                      /// --- Filters (scrolls up)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: membersCubit.filters.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final filter = membersCubit.filters[index];
                              final isSelected = state.selectedFilter == filter;

                              // Pick a gradient for each filter
                              List<Color> chipGradient;
                              switch (filter.toLowerCase()) {
                                case 'active':
                                  chipGradient = [const Color(0xFF05CD99), const Color(0xFF61EFCD)];
                                  break;
                                case 'expired':
                                  chipGradient = [const Color(0xFFFF4C61), const Color(0xFFFF8F9E)];
                                  break;
                                case 'expiring soon':
                                  chipGradient = [const Color(0xFFFFC837), const Color(0xFFFFE08A)];
                                  break;
                                case 'inactive':
                                  chipGradient = [const Color(0xFF707E94), const Color(0xFFA0AEC0)];
                                  break;
                                default:
                                  chipGradient = [XColors.primary, const Color(0xFF868CFF)];
                              }

                              return GestureDetector(
                                onTap: () => membersCubit.setSelectedFilter(filter),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: chipGradient,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : (dark ? XColors.darkCardBackground : XColors.white),
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? null
                                        : Border.all(
                                            color: dark ? XColors.darkGrey.withValues(alpha: 0.4) : XColors.borderPrimary,
                                          ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: chipGradient[0].withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    filter,
                                    style: TextStyle(
                                      color: isSelected
                                          ? XColors.white
                                          : (dark ? XColors.softGrey : XColors.darkGrey),
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: XSizes.spaceBtwItems)),

                      /// --- Members list or empty state
                      if (members.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: XEmptyState(
                            title: isSearching ? 'No Results Found' : 'No Members Yet',
                            subtitle: isSearching ? 'Try a different search' : 'Add your first member to get started',
                            icon: Iconsax.people,
                            actionText: isSearching ? null : 'Add Member',
                            onAction: isSearching ? null : () => Navigator.pushNamed(context, '/add-member'),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final member = members[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: XSizes.sm + 4),
                                        child: XMemberCard(
                                  member: member,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => MemberDetailScreen(member: member)),
                                    );
                                  },
                                  onCall: () => WhatsAppService.callMember(member.mobile),
                                  onWhatsApp: () => WhatsAppService.sendMessage(member.mobile, 'Hi ${member.fullName}, this is a message from EdoxLibrary.'),
                                ),
                              );
                            },
                            childCount: members.length,
                          ),
                        ),

                      /// Bottom padding
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  );
                }(),
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
            onTap: () => Navigator.pushNamed(context, '/add-member'),
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.user_add, color: XColors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Add Member',
                    style: TextStyle(
                      color: XColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Extracted search field
class _SearchField extends StatelessWidget {
  const _SearchField({required this.membersCubit, required this.dark});
  final MembersCubit membersCubit;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        controller: membersCubit.searchController,
        onChanged: (val) => membersCubit.setSearchQuery(val),
        decoration: InputDecoration(
          hintText: 'Search by name or mobile...',
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
            valueListenable: membersCubit.searchController,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: membersCubit.clearSearch,
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: XColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.close, size: 14, color: XColors.error),
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
    );
  }
}
