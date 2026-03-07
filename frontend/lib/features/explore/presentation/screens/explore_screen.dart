import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final bountyState = ref.watch(bountyListProvider);

    final bounties = _selectedCategory == 'All'
        ? bountyState.bounties
        : bountyState.bounties
              .where((b) => b.category == _selectedCategory)
              .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
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
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'find bounties and earn rewards',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),

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
                                      ? AppColors.primary.withValues(
                                          alpha: 0.15,
                                        )
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: selected ? 1.5 : 0.5,
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
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
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.surfaceLight,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.textHint,
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${bounty.algoAmount.toStringAsFixed(bounty.algoAmount == bounty.algoAmount.roundToDouble() ? 0 : 1)} ALGO',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.neonGreen.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '${bounty.algoAmount.toStringAsFixed(bounty.algoAmount == bounty.algoAmount.roundToDouble() ? 0 : 1)} ALGO',
                        style: const TextStyle(
                          color: AppColors.neonGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Title
                  Text(
                    bounty.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Description preview
                  Text(
                    bounty.description,
                    style: const TextStyle(
                      color: AppColors.textHint,
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
                            color: AppColors.textHint,
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
                          color: _categoryColor(
                            bounty.category,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bounty.category,
                          style: TextStyle(
                            color: _categoryColor(bounty.category),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Time
                      Icon(
                        Icons.schedule_outlined,
                        size: 12,
                        color: isExpired ? AppColors.error : AppColors.textHint,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isExpired ? 'expired' : timeLeft,
                        style: TextStyle(
                          color: isExpired
                              ? AppColors.error
                              : AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  // Location (if available)
                  if (bounty.location != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.textHint,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            bounty.location!,
                            style: const TextStyle(
                              color: AppColors.textHint,
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
