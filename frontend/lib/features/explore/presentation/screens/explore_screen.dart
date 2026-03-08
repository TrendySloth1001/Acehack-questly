import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/algo_inr.dart';
import '../../../bounty/data/models/bounty_model.dart';
import '../../../bounty/presentation/providers/bounty_provider.dart';

const _filterCategories = [
  'All',
  'Delivery',
  'Tutoring',
  'Design',
  'Coding',
  'Writing',
  'Research',
  'Errands',
  'Photography',
  'Other',
];

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bountyState = ref.watch(bountyListProvider);

    var bounties = _selectedCategory == 'All'
        ? bountyState.bounties
        : bountyState.bounties
              .where((b) => b.category == _selectedCategory)
              .toList();

    // Apply text search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      bounties = bounties
          .where(
            (b) =>
                b.title.toLowerCase().contains(q) ||
                b.description.toLowerCase().contains(q) ||
                (b.location?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.neonCyan,
          backgroundColor: const Color(0xFF0D0D0D),
          onRefresh: () => ref.read(bountyListProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'explore',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'find bounties and earn rewards',
                        style: TextStyle(
                          color: Color(0xFF3A3A3A),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Search bar
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF222222),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search bounties...',
                            hintStyle: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.textHint,
                              size: 18,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: AppColors.textHint,
                                      size: 16,
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Category filter
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filterCategories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final cat = _filterCategories[i];
                            final selected = _selectedCategory == cat;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.neonCyan.withValues(
                                          alpha: 0.1,
                                        )
                                      : Colors.black,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.neonCyan
                                        : const Color(0xFF222222),
                                    width: selected ? 1 : 1,
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: selected
                                        ? AppColors.neonCyan
                                        : const Color(0xFF555555),
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Loading
              if (bountyState.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              // Error
              else if (bountyState.error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 40,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'failed to load bounties',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () =>
                              ref.read(bountyListProvider.notifier).refresh(),
                          child: const Text(
                            'tap to retry',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // Empty
              else if (bounties.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_outlined,
                          size: 40,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _selectedCategory == 'All'
                              ? 'no bounties yet'
                              : 'no $_selectedCategory bounties',
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // Bounty cards
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final b = bounties[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _BountyCard(
                          bounty: b,
                          onTap: () => context.push('/home/bounty/${b.id}'),
                        ),
                      );
                    }, childCount: bounties.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rich bounty card for the explore grid.
class _BountyCard extends StatelessWidget {
  final BountyModel bounty;
  final VoidCallback? onTap;

  const _BountyCard({required this.bounty, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = bounty.imageUrls.isNotEmpty;
    final isExpired = bounty.deadline.isBefore(DateTime.now());
    final timeLeft = _timeLeft(bounty.deadline);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            if (hasImage)
              SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      bounty.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, s) => Container(
                        color: const Color(0xFF0D0D0D),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF2A2A2A),
                          size: 32,
                        ),
                      ),
                    ),
                    // Image count badge
                    if (bounty.imageUrls.length > 1)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.photo_library_outlined,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${bounty.imageUrls.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Reward overlay
                    if (bounty.algoAmount > 0)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: AlgoRewardChip(amount: bounty.algoAmount),
                      ),
                  ],
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // No-image reward badge
                  if (!hasImage && bounty.algoAmount > 0) ...[
                    AlgoRewardChip(amount: bounty.algoAmount),
                    const SizedBox(height: 8),
                  ],

                  // Title
                  Text(
                    bounty.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Description preview
                  Text(
                    bounty.description,
                    style: const TextStyle(
                      color: Color(0xFF505050),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Meta row
                  Row(
                    children: [
                      // Creator
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.primaryDim,
                        backgroundImage: bounty.creator.avatarUrl != null
                            ? NetworkImage(bounty.creator.avatarUrl!)
                            : null,
                        child: bounty.creator.avatarUrl == null
                            ? const Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 10,
                              )
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          bounty.creator.name ?? 'anonymous',
                          style: const TextStyle(
                            color: Color(0xFF3A3A3A),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _categoryColor(
                              bounty.category,
                            ).withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          bounty.category.toLowerCase(),
                          style: TextStyle(
                            color: _categoryColor(bounty.category),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Requested count
                      if (bounty.claimCount > 0) ...[
                        Icon(
                          Icons.people_outline_rounded,
                          size: 13,
                          color: AppColors.neonCyan.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${bounty.claimCount} requested',
                          style: TextStyle(
                            color: AppColors.neonCyan.withValues(alpha: 0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.schedule_outlined,
                          size: 12,
                          color: isExpired
                              ? AppColors.error
                              : const Color(0xFF333333),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isExpired ? 'expired' : timeLeft,
                          style: TextStyle(
                            color: isExpired
                                ? AppColors.error
                                : const Color(0xFF333333),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Location (if available)
                  if (bounty.location != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF333333),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            bounty.location!,
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 12,
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
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'delivery':
        return AppColors.neonOrange;
      case 'tutoring':
        return AppColors.neonCyan;
      case 'design':
        return const Color(0xFFE040FB);
      case 'coding':
        return AppColors.neonGreen;
      case 'writing':
        return const Color(0xFFFFD600);
      case 'research':
        return const Color(0xFF448AFF);
      case 'errands':
        return AppColors.neonOrange;
      case 'photography':
        return const Color(0xFFFF80AB);
      default:
        return AppColors.textHint;
    }
  }

  String _timeLeft(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m left';
    return 'soon';
  }
}
