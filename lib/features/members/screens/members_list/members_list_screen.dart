import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/common/widgets/cards/member_card.dart';
import 'package:edox_library/common/widgets/empty_states/empty_state.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/members/screens/member_detail/member_detail_screen.dart';
import 'package:edox_library/features/members/controllers/members_controller.dart';
class MembersListScreen extends StatelessWidget {
  const MembersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MembersController());
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
                  Text('Members', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                  Obx(() {
                    final count = controller.displayList.length;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: XColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$count Members', style: const TextStyle(color: XColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    );
                  }),
                ],
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Search
              _SearchField(controller: controller, dark: dark),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Filters
              SizedBox(
                height: 36,
                child: Obx(() {
                  final selected = controller.selectedFilter.value;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = controller.filters[index];
                      final isSelected = selected == filter;
                      return GestureDetector(
                        onTap: () => controller.selectedFilter.value = filter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? XColors.primary : (dark ? XColors.darkCardBackground : XColors.lightBackground),
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected ? null : Border.all(color: dark ? XColors.darkGrey : XColors.borderPrimary),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? XColors.white : (dark ? XColors.softGrey : XColors.darkGrey),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: XSizes.spaceBtwItems),

              /// --- Members List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final members = controller.displayList;
                  final isSearching = controller.searchQuery.value.isNotEmpty;

                  if (members.isEmpty) {
                    return XEmptyState(
                      title: isSearching ? 'No Results Found' : 'No Members Yet',
                      subtitle: isSearching ? 'Try a different search' : 'Add your first member to get started',
                      icon: Iconsax.people,
                      actionText: isSearching ? null : 'Add Member',
                      onAction: isSearching ? null : () => Get.toNamed('/add-member'),
                    );
                  }

                  return ListView.separated(
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: XSizes.sm + 4),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return XMemberCard(
                        member: member,
                        onTap: () => Get.to(() => MemberDetailScreen(member: member)),
                        onCall: () {},
                        onWhatsApp: () {},
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
        onPressed: () => Get.toNamed('/add-member'),
        backgroundColor: XColors.primary,
        icon: const Icon(Iconsax.user_add, color: XColors.white),
        label: const Text('Add Member', style: TextStyle(color: XColors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/// Extracted search field to avoid nested Obx issues
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.dark});
  final MembersController controller;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.searchController,
      onChanged: (val) => controller.searchQuery.value = val,
      decoration: InputDecoration(
        hintText: 'Search by name or mobile...',
        prefixIcon: const Icon(Iconsax.search_normal, size: 20),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller.searchController,
          builder: (_, value, __) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              onPressed: controller.clearSearch,
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
    );
  }
}
