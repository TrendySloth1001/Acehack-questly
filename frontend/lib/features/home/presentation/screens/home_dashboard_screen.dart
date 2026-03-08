import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bounty/data/models/bounty_model.dart';
import '../../../bounty/presentation/providers/bounty_provider.dart';
import '../../../algorand/presentation/providers/wallet_provider.dart';
import '../../../../core/utils/algo_inr.dart';

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
    final wallet = ref.watch(walletProvider);

    // Load wallet on first build
    if (!wallet.isLoading && wallet.address == null && wallet.error == null) {
      Future.microtask(() => ref.read(walletProvider.notifier).load());
    }

    final firstName = user?.name?.split(' ').first ?? 'explorer';
    final greeting = _genZGreeting(firstName);

    // Filter out bounties the current user already claimed
    final claimedBountyIds = myClaims.claims
        .where((c) => c.bounty != null)
        .map((c) => c.bounty!.id)
        .toSet();
    final latestDrops = allBounties.bounties
        .where((b) => b.status == 'OPEN' && !claimedBountyIds.contains(b.id))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.neonCyan,
          backgroundColor: const Color(0xFF0D0D0D),
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

              // ── BALANCE BANNER ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _BalanceBanner(
                    wallet: wallet,
                    onTap: () => context.go('/wallet'),
                  ),
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
                        'Joined Bounties',
                        style: TextStyle(
                          color: Color(0xFF444444),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
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
                            color: AppColors.neonGreen.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.neonGreen.withValues(alpha: 0.2),
                            ),
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
                      style: TextStyle(color: Color(0xFF363636), fontSize: 13),
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
                        'Latest Drops',
                        style: TextStyle(
                          color: Color(0xFF444444),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.explore),
                        child: const Text(
                          'see all →',
                          style: TextStyle(
                            color: AppColors.neonCyan,
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
                          color: Color(0xFF363636),
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
        ? ['Yo $name ☀️', 'rise & grind, $name', 'gm $name 👋']
        : hour < 17
        ? ['Yo $name 🔥', 'what\'s good, $name', 'hey $name ⚡']
        : ['Yo $name 🌙', 'evening vibes, $name', 'sup $name ✨'];
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
        // Avatar
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF0D0D0D),
          backgroundImage: user?.avatarUrl != null
              ? NetworkImage(user!.avatarUrl!)
              : null,
          child: user?.avatarUrl == null
              ? const Icon(Icons.person, color: Color(0xFF333333), size: 20)
              : null,
        ),
        const SizedBox(width: 14),
        // Greeting
        Expanded(
          child: Text(
            greeting,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        // Questly logo
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: SvgPicture.asset(
              'assets/svg/questly_logo.svg',
              width: 38,
              height: 38,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Leaderboard
        GestureDetector(
          onTap: () => context.push('/home/leaderboard'),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: AppColors.neonCyan.withValues(alpha: 0.5),
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Bell
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF404040),
            size: 18,
          ),
        ),
      ],
    );
  }
}

/// Compact balance banner for the home screen.
class _BalanceBanner extends ConsumerWidget {
  final WalletState wallet;
  final VoidCallback onTap;

  const _BalanceBanner({required this.wallet, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasWallet = wallet.address != null && wallet.address!.isNotEmpty;
    final balance = wallet.balance?.balanceAlgo ?? 0.0;
    final rateAsync = ref.watch(algoInrRateProvider);
    final inrRate = rateAsync.valueOrNull ?? 15.0;

    // User's own locked escrow from their bounties
    final myBounties = ref.watch(myBountiesProvider);
    double lockedEscrow = 0;
    for (final b in myBounties.bounties) {
      if (b.escrowStatus == 'FUNDED') lockedEscrow += b.algoAmount;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasWallet
                ? AppColors.neonCyan.withValues(alpha: 0.15)
                : const Color(0xFF1A1A1A),
            width: 1,
          ),
        ),
        child: hasWallet
            ? Row(
                children: [
                  // Balance
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BALANCE',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            balance.toStringAsFixed(2),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: SvgPicture.asset(
                              'assets/svg/questly_logo.svg',
                              width: 14,
                              height: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '~${algoToInrString(balance, inrRate)}',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Locked escrow (user's own)
                  if (lockedEscrow > 0) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color: AppColors.neonOrange,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        SvgPicture.asset(
                          'assets/svg/questly_logo.svg',
                          width: 12,
                          height: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          lockedEscrow.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.neonOrange,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                  ],
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                ],
              )
            : Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.textHint,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Set up your wallet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                ],
              ),
      ),
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
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.neonCyan.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.neonCyan,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Post a bounty',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF1E1E1E),
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

/// Joined bounty card — explore-style with image, description, time remaining.
class _ClaimCard extends StatelessWidget {
  final BountyClaimModel claim;
  final VoidCallback? onTap;

  const _ClaimCard({required this.claim, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bounty = claim.bounty;
    final hasImage = bounty != null && bounty.imageUrls.isNotEmpty;
    final isExpired =
        bounty != null && bounty.deadline.isBefore(DateTime.now());
    final timeLeft = bounty != null ? _timeLeft(bounty.deadline) : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image header ──────────────────────────────────
            if (hasImage)
              SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      bounty!.imageUrls.first,
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

            // ── Content ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // No-image reward badge
                  if (!hasImage && bounty != null && bounty.algoAmount > 0) ...[
                    AlgoRewardChip(amount: bounty.algoAmount),
                    const SizedBox(height: 8),
                  ],

                  // Title
                  Text(
                    bounty?.title ?? 'Bounty',
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

                  // Description
                  if (bounty != null && bounty.description.isNotEmpty)
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

                  // ── Meta row ────────────────────────────────
                  Row(
                    children: [
                      // Creator avatar
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.primaryDim,
                        backgroundImage: bounty?.creator?.avatarUrl != null
                            ? NetworkImage(bounty!.creator!.avatarUrl!)
                            : null,
                        child: bounty?.creator?.avatarUrl == null
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
                          bounty?.creator?.name ?? 'anonymous',
                          style: const TextStyle(
                            color: Color(0xFF3A3A3A),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Category badge
                      if (bounty != null)
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

                      // Time remaining
                      if (bounty != null) ...[
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

                  // Location
                  if (bounty?.location != null) ...[
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
                            bounty!.location!,
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
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFF222222)),
                  ),
                  child: Text(
                    bounty.category.toLowerCase(),
                    style: const TextStyle(
                      color: Color(0xFF404040),
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
                  color: isExpired ? AppColors.error : const Color(0xFF333333),
                ),
                const SizedBox(width: 3),
                Text(
                  isExpired ? 'expired' : timeLeft,
                  style: TextStyle(
                    color: isExpired
                        ? AppColors.error
                        : const Color(0xFF444444),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 10),
                // Claim count
                const Icon(
                  Icons.people_alt_outlined,
                  size: 12,
                  color: Color(0xFF333333),
                ),
                const SizedBox(width: 3),
                Text(
                  '${bounty.claimCount}',
                  style: const TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                // Reward
                if (bounty.algoAmount > 0)
                  AlgoRewardChip(amount: bounty.algoAmount),
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
