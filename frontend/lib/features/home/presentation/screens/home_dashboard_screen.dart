import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bounty/data/models/bounty_model.dart';
import '../../../bounty/presentation/providers/bounty_provider.dart';

// ─────────────────────────────────────────────────────────────
// Gen-Z minimalist home — informative, clean, zero clutter.
// Every card answers: what · who · when · how much
// ─────────────────────────────────────────────────────────────

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final allBounties = ref.watch(bountyListProvider);
    final myClaims = ref.watch(myClaimsProvider);

    final firstName = user?.name?.split(' ').first ?? 'explorer';
    final greeting = _genZGreeting(firstName);

    // Filter out bounties the current user already claimed
    final claimedBountyIds = myClaims.claims
        .where((c) => c.bounty != null)
        .map((c) => c.bounty!.id)
        .toSet();
    final latestDrops = allBounties.bounties
        .where((b) => !claimedBountyIds.contains(b.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            await Future.wait([
              ref.read(bountyListProvider.notifier).refresh(),
              ref.read(myClaimsProvider.notifier).load(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── HEADER ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _Header(greeting: greeting, user: user),
                ),
              ),

              // ── POST CTA ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _PostCTA(
                    onTap: () => context.push(AppRoutes.createBounty),
                  ),
                ),
              ),

              // ── JOINED BOUNTIES ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
                  child: Row(
                    children: [
                      const Text(
                        'joined bounties',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      if (myClaims.claims.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${myClaims.claims.length}',
                            style: const TextStyle(
                              color: AppColors.neonGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (myClaims.isLoading)
                const SliverToBoxAdapter(child: _LoadingIndicator())
              else if (myClaims.error != null)
                SliverToBoxAdapter(
                  child: _InlineError(
                    onRetry: () => ref.read(myClaimsProvider.notifier).load(),
                  ),
                )
              else if (myClaims.claims.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Text(
                      'no joined bounties yet — claim one below ↓',
                      style: TextStyle(color: AppColors.textHint, fontSize: 13),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final claim = myClaims.claims[i];
                      return _ClaimCard(
                        claim: claim,
                        onTap: claim.bounty != null
                            ? () => context.push(
                                '/home/bounty/${claim.bounty!.id}',
                              )
                            : null,
                      );
                    }, childCount: myClaims.claims.length.clamp(0, 5)),
                  ),
                ),

              // ── LATEST BOUNTIES ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
                  child: Row(
                    children: [
                      const Text(
                        'latest drops',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.explore),
                        child: const Text(
                          'see all →',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Latest bounties list
              if (allBounties.isLoading)
                const SliverToBoxAdapter(child: _LoadingIndicator())
              else if (allBounties.error != null)
                SliverToBoxAdapter(
                  child: _InlineError(
                    onRetry: () =>
                        ref.read(bountyListProvider.notifier).refresh(),
                  ),
                )
              else if (allBounties.bounties.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Center(
                      child: Text(
                        'nothing here yet — go post something 🚀',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final b = latestDrops[index];
                      return _BountyCard(
                        bounty: b,
                        onTap: () => context.push('/home/bounty/${b.id}'),
                      );
                    }, childCount: latestDrops.length.clamp(0, 10)),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  String _genZGreeting(String name) {
    final hour = DateTime.now().hour;
    final greetings = hour < 12
        ? ['yo $name ☀️', 'rise & grind, $name', 'gm $name 👋']
        : hour < 17
        ? ['yo $name 🔥', 'what\'s good, $name', 'hey $name ⚡']
        : ['yo $name 🌙', 'evening vibes, $name', 'sup $name ✨'];
    // Rotate based on day-of-year so it feels varied but deterministic
    final dayIndex = DateTime.now()
        .difference(DateTime(DateTime.now().year))
        .inDays;
    return greetings[dayIndex % greetings.length];
  }
}

// ═════════════════════════════════════════════════════════════
//  COMPONENTS
// ═════════════════════════════════════════════════════════════

/// Header — avatar + gen-z greeting + notification bell
class _Header extends StatelessWidget {
  final String greeting;
  final dynamic user;

  const _Header({required this.greeting, this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar with subtle glow
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryDim,
            backgroundImage: user?.avatarUrl != null
                ? NetworkImage(user!.avatarUrl!)
                : null,
            child: user?.avatarUrl == null
                ? const Icon(Icons.person, color: AppColors.primary, size: 20)
                : null,
          ),
        ),
        const SizedBox(width: 14),
        // Greeting
        Expanded(
          child: Text(
            greeting,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        // Bell
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textSecondary,
            size: 18,
          ),
        ),
      ],
    );
  }
}

/// Minimal "Post a Bounty" CTA
class _PostCTA extends StatelessWidget {
  final VoidCallback onTap;

  const _PostCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'post a bounty',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textHint.withValues(alpha: 0.4),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header + content block
class _SectionBlock extends StatelessWidget {
  final String title;
  final Color accent;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final Widget child;

  const _SectionBlock({
    required this.title,
    required this.accent,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Text(
            title,
            style: TextStyle(
              color: accent.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          if (isLoading)
            const _LoadingIndicator()
          else if (error != null)
            _InlineError(onRetry: onRetry)
          else
            child,
        ],
      ),
    );
  }
}

/// Joined bounty feed card — mirrors _BountyCard layout.
class _ClaimCard extends StatelessWidget {
  final BountyClaimModel claim;
  final VoidCallback? onTap;

  const _ClaimCard({required this.claim, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bounty = claim.bounty;
    final claimStatusColor = _claimStatusColor(claim.status);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Creator avatar + name + joined time + claim status ──
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryDim,
                  backgroundImage: bounty?.creator?.avatarUrl != null
                      ? NetworkImage(bounty!.creator!.avatarUrl!)
                      : null,
                  child: bounty?.creator?.avatarUrl == null
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
                    bounty?.creator?.name ?? 'anonymous',
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
                  _timeAgo(claim.createdAt),
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Row 2: Bounty title ───────────────────────────
            Text(
              bounty?.title ?? 'Bounty',
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
            const SizedBox(height: 10),

            // ── Row 3: Claim status + reward ──────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: claimStatusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: claimStatusColor.withValues(alpha: 0.25),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        claim.status == 'APPROVED'
                            ? Icons.check_circle_outline_rounded
                            : claim.status == 'SUBMITTED'
                            ? Icons.hourglass_top_rounded
                            : claim.status == 'REJECTED'
                            ? Icons.cancel_outlined
                            : Icons.assignment_outlined,
                        color: claimStatusColor,
                        size: 11,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        claim.status.toLowerCase(),
                        style: TextStyle(
                          color: claimStatusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (bounty != null && bounty.algoAmount > 0)
                  _RewardBadge(amount: bounty.algoAmount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The main latest bounty card — the hero element.
/// Shows: avatar + name · title · description snippet · category ·
///        deadline · reward · claim count
class _BountyCard extends StatelessWidget {
  final BountyModel bounty;
  final VoidCallback? onTap;

  const _BountyCard({required this.bounty, this.onTap});

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
            // ── Row 1: Avatar + name + time + reward ─────────
            Row(
              children: [
                // Creator avatar
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
                // Name
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
                // Time ago
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

            // ── Row 2: Title ─────────────────────────────────
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

            // ── Row 3: Description snippet ───────────────────
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

            // ── Row 4: Image if exists ───────────────────────
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

            // ── Row 5: Meta tags — category · deadline · claims · reward
            Row(
              children: [
                // Category chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text(
                    bounty.category.toLowerCase(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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

// ═════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═════════════════════════════════════════════════════════════

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

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
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
    );
  }
}

class _InlineError extends StatelessWidget {
  final VoidCallback onRetry;

  const _InlineError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
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
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
          GestureDetector(
            onTap: onRetry,
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
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  HELPERS
// ═════════════════════════════════════════════════════════════

Widget _dot() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        color: AppColors.textHint,
        shape: BoxShape.circle,
      ),
    ),
  );
}

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

Color _claimStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'ACTIVE':
      return AppColors.primary;
    case 'SUBMITTED':
      return AppColors.warning;
    case 'APPROVED':
      return AppColors.neonGreen;
    case 'REJECTED':
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
