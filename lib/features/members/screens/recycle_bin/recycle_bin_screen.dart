import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/common/widgets/empty_states/empty_state.dart';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isProcessing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _calculateDaysRemaining(DateTime? deletedAt) {
    if (deletedAt == null) return 50;
    final difference = DateTime.now().difference(deletedAt).inDays;
    final remaining = 50 - difference;
    return remaining < 0 ? 0 : remaining;
  }

  void _restoreMember(BuildContext context, MemberModel member) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isProcessing = true);
    try {
      await MemberRepository.instance.restoreMember(member);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${member.fullName} restored successfully!'),
          backgroundColor: XColors.success,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to restore member: $e'),
          backgroundColor: XColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _confirmPermanentDelete(BuildContext context, MemberModel member) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Permanent Delete'),
          content: Text('Are you sure you want to permanently delete ${member.fullName}? This action cannot be undone and all data will be deleted from the backend.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog
                final messenger = ScaffoldMessenger.of(context);
                setState(() => _isProcessing = true);
                try {
                  await MemberRepository.instance.permanentlyDeleteMember(member.id);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('${member.fullName} deleted permanently.'),
                      backgroundColor: XColors.error,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete member: $e'),
                      backgroundColor: XColors.error,
                    ),
                  );
                } finally {
                  if (mounted) setState(() => _isProcessing = false);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: XColors.error),
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recycle Bin',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: XSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: XSizes.spaceBtwItems),

                /// --- Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: dark ? XColors.darkCardBackground : XColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: dark ? XColors.primary.withValues(alpha: 0.08) : XColors.primary.withValues(alpha: 0.04),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: dark ? Colors.black.withValues(alpha: 0.15) : XColors.primary.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
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
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              icon: Icon(Icons.clear, color: dark ? XColors.textSecondary : XColors.darkGrey),
                            ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: XSizes.md, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: XSizes.spaceBtwItems + 4),

                /// --- Subtitle / Warning Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: XColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: XColors.warning.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.info_circle, color: XColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Members in the bin will be deleted permanently after 50 days of deletion.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: dark ? XColors.white : XColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: XSizes.spaceBtwItems),

                /// --- Bin List
                Expanded(
                  child: StreamBuilder<List<MemberModel>>(
                    stream: MemberRepository.instance.getBinMembersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading bin members: ${snapshot.error}'));
                      }

                      final allBinMembers = snapshot.data ?? [];

                      // Apply search filter
                      final binMembers = allBinMembers.where((m) {
                        return m.fullName.toLowerCase().contains(_searchQuery) ||
                            m.mobile.contains(_searchQuery);
                      }).toList();

                      if (binMembers.isEmpty) {
                        return XEmptyState(
                          title: _searchQuery.isNotEmpty ? 'No Results Found' : 'Bin is Empty',
                          subtitle: _searchQuery.isNotEmpty
                              ? 'Try a different search query'
                              : 'Deleted members will appear here',
                          icon: Iconsax.trash,
                        );
                      }

                      return ListView.separated(
                        itemCount: binMembers.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(height: XSizes.spaceBtwItems),
                        itemBuilder: (context, index) {
                          final member = binMembers[index];
                          final daysRemaining = _calculateDaysRemaining(member.deletedAt);
                          final initials = member.fullName.isNotEmpty
                              ? member.fullName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
                              : 'M';

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: dark ? XColors.darkCardBackground : XColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: dark ? XColors.darkGrey.withValues(alpha: 0.3) : XColors.borderPrimary,
                              ),
                            ),
                            child: Row(
                              children: [
                                /// Avatar with initials
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        XColors.primary.withValues(alpha: 0.15),
                                        XColors.primary.withValues(alpha: 0.05),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: XColors.primary.withValues(alpha: 0.15)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        color: XColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                /// Member Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Iconsax.call,
                                            size: 11,
                                            color: dark ? XColors.textSecondary : XColors.darkGrey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            member.mobile,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: dark ? XColors.textSecondary : XColors.darkGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),

                                      /// Timer Badge
                                      Row(
                                        children: [
                                          Icon(
                                            Iconsax.clock,
                                            size: 11,
                                            color: daysRemaining <= 7 ? XColors.error : XColors.warning,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Permanently deletes in $daysRemaining days',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: daysRemaining <= 7 ? XColors.error : XColors.warning,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                /// Action Buttons
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Restore Member',
                                      icon: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: XColors.success.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Iconsax.rotate_left, color: XColors.success, size: 16),
                                      ),
                                      onPressed: () => _restoreMember(context, member),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete Permanently',
                                      icon: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: XColors.error.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Iconsax.trash, color: XColors.error, size: 16),
                                      ),
                                      onPressed: () => _confirmPermanentDelete(context, member),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: XSizes.defaultSpace),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
