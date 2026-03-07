import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bounty/data/models/bounty_model.dart';
import '../../../bounty/presentation/providers/bounty_provider.dart';

/// Profile tab — user info, skills, stats, your bounties.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final myBounties = ref.watch(myBountiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            await ref.read(myBountiesProvider.notifier).refresh();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Profile header ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primaryDim,
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? const Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 40,
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'Anonymous',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ProfileStat(
                            label: 'Bounties',
                            value: '${myBounties.bounties.length}',
                            color: AppColors.neonCyan,
                          ),
                          _ProfileStat(
                            label: 'Skills',
                            value: '0',
                            color: AppColors.neonGreen,
                          ),
                          _ProfileStat(
                            label: 'Streak',
                            value: '0',
                            color: AppColors.neonCyan,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Bio section placeholder
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'about',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'tap to add a bio and let people know what you\'re about',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Skills section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'skills',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'your skills will show up here after onboarding',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── YOUR BOUNTIES section header ──────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 4),
                  child: Row(
                    children: [
                      const Text(
                        'your bounties',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      if (myBounties.bounties.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${myBounties.bounties.length}',
                            style: const TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── YOUR BOUNTIES list ────────────────────────
              if (myBounties.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 1.5,
                        ),
                      ),
                    ),
                  ),
                )
              else if (myBounties.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error.withValues(alpha: 0.6),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'couldn\'t load — ',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              ref.read(myBountiesProvider.notifier).refresh(),
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
              else if (myBounties.bounties.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Text(
                      'you haven\'t posted any bounties yet',
                      style: TextStyle(color: AppColors.textHint, fontSize: 13),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final bounty = myBounties.bounties[i];
                      return _MyBountyCard(
                        bounty: bounty,
                        onTap: () => context.push('/home/bounty/${bounty.id}'),
                      );
                    }, childCount: myBounties.bounties.length),
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ProfileStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

/// Feed-style bounty card matching _BountyCard from home.
class _MyBountyCard extends StatelessWidget {
  final BountyModel bounty;
  final VoidCallback? onTap;

  const _MyBountyCard({required this.bounty, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpired = bounty.deadline.isBefore(DateTime.now());
    final timeLeft = _timeLeft(bounty.deadline);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Avatar + name + time ─────────
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryDim,
                  backgroundImage: bounty.creator.avatarUrl != null
                      ? NetworkImage(bounty.creator.avatarUrl!)
                      : null,
                  child: bounty.creator.avatarUrl == null
                      ? const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 14,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    bounty.creator.name ?? 'anonymous',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _timeAgo(bounty.createdAt),
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Title ────────────────────────────────────
            Text(
              bounty.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.3,
                letterSpacing: -0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // ── Description snippet ──────────────────────
            if (bounty.description.isNotEmpty) ...[
              const SizedBox(height: 4),
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
            ],

            // ── Image ────────────────────────────────────
            if (bounty.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  bounty.imageUrls.first,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, e, s) => const SizedBox.shrink(),
                ),
              ),
            ],

            const SizedBox(height: 10),

            // ── Meta: status · category · deadline · claims · reward
            Row(
              children: [
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _bountyStatusColor(
                      bounty.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _bountyStatusColor(
                        bounty.status,
                      ).withValues(alpha: 0.25),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    bounty.status.toLowerCase(),
                    style: TextStyle(
                      color: _bountyStatusColor(bounty.status),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Deadline
                Icon(
                  Icons.schedule_rounded,
                  size: 12,
                  color: isExpired ? AppColors.error : AppColors.textHint,
                ),
                const SizedBox(width: 3),
                Text(
                  isExpired ? 'expired' : timeLeft,
                  style: TextStyle(
                    color: isExpired ? AppColors.error : AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 10),
                // Claim count
                const Icon(
                  Icons.people_alt_outlined,
                  size: 12,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 3),
                Text(
                  '${bounty.claimCount}',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                // Reward
                if (bounty.algoAmount > 0)
                  _RewardBadge(amount: bounty.algoAmount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  final double amount;

  const _RewardBadge({required this.amount});

  @override
  Widget build(BuildContext context) {
    final display = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$display A',
        style: const TextStyle(
          color: AppColors.neonGreen,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  HELPERS
// ═════════════════════════════════════════════════════════════

Color _bountyStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'OPEN':
      return AppColors.neonGreen;
    case 'CLAIMED':
      return AppColors.neonCyan;
    case 'COMPLETED':
      return AppColors.primary;
    case 'EXPIRED':
      return AppColors.error;
    default:
      return AppColors.textHint;
  }
}

String _timeLeft(DateTime deadline) {
  final diff = deadline.difference(DateTime.now());
  if (diff.isNegative) return 'expired';
  if (diff.inDays > 0) return '${diff.inDays}d left';
  if (diff.inHours > 0) return '${diff.inHours}h left';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m left';
  return 'ending soon';
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'just now';
}
