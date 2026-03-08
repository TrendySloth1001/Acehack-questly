import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bounty/data/models/bounty_model.dart';
import '../../../bounty/presentation/providers/bounty_provider.dart';
import '../../../gamification/presentation/widgets/gamification_widgets.dart';
import '../../../../core/router/app_router.dart';

/// Compute consecutive-day activity streak from bounties + claims.
int _calcStreak(List<BountyModel> bounties, List<BountyClaimModel> claims) {
  final dates = <DateTime>{};
  for (final b in bounties) {
    dates.add(DateTime(b.createdAt.year, b.createdAt.month, b.createdAt.day));
  }
  for (final c in claims) {
    dates.add(DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day));
  }
  if (dates.isEmpty) return 0;
  final sorted = dates.toList()..sort((a, b) => b.compareTo(a));
  int streak = 0;
  var cursor = DateTime.now();
  cursor = DateTime(cursor.year, cursor.month, cursor.day);
  for (final d in sorted) {
    final diff = cursor.difference(d).inDays;
    if (diff <= 1) {
      streak++;
      cursor = d;
    } else {
      break;
    }
  }
  return streak;
}

/// Profile tab — ultra-minimal, premium.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final myBounties = ref.watch(myBountiesProvider);
    final myClaims = ref.watch(myClaimsProvider);

    // Compute real stats
    final completedCount =
        myBounties.bounties.where((b) => b.status == 'COMPLETED').length +
        myClaims.claims.where((c) => c.status == 'APPROVED').length;

    // Streak: count consecutive days with bounty/claim activity (simplified)
    final streak = _calcStreak(myBounties.bounties, myClaims.claims);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            const SizedBox(height: 20),

            // ── Avatar + Rank Badge ───────────────────
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryDim,
                    backgroundImage: user?.avatarUrl != null
                        ? NetworkImage(user!.avatarUrl!)
                        : null,
                    child: user?.avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 36,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: RankBadge(tier: user?.rankTier ?? 'WOOD', size: 30),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Name ──────────────────────────────────
            Center(
              child: Text(
                user?.name ?? 'Anonymous',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // ── Email ─────────────────────────────────
            Center(
              child: Text(
                user?.email ?? '',
                style: const TextStyle(color: AppColors.textHint, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),

            // ── Star Rating ───────────────────────────
            if (user != null && user.avgRating != null)
              Center(
                child: StarRating(
                  rating: user.avgRating!,
                  totalReviews: user.totalReviews,
                  starSize: 18,
                ),
              ),

            const SizedBox(height: 20),

            // ── XP Bar (Minecraft) ────────────────────
            XpBar(
              currentXp: user?.xp ?? 0,
              nextLevelXp: user?.nextLevelXp ?? 25,
              level: user?.level ?? 0,
              rankTier: user?.rankTier ?? 'WOOD',
            ),
            const SizedBox(height: 12),

            // ── How XP Works button ───────────────────
            GestureDetector(
              onTap: () => context.push(AppRoutes.xpRules),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.neonCyan.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'how xp works',
                      style: TextStyle(
                        color: AppColors.neonCyan.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Stats row ─────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    value: '${myBounties.bounties.length}',
                    label: 'Bounties',
                  ),
                ),
                Container(width: 0.5, height: 36, color: AppColors.border),
                Expanded(
                  child: _MiniStat(
                    value: '$completedCount',
                    label: 'Completed',
                  ),
                ),
                Container(width: 0.5, height: 36, color: AppColors.border),
                Expanded(
                  child: _MiniStat(value: '$streak', label: 'Streak'),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // ── Menu items ────────────────────────────
            _MenuItem(
              icon: Icons.emoji_events_rounded,
              label: 'Leaderboard',
              onTap: () => context.push('/home/leaderboard'),
            ),
            _MenuItem(
              icon: Icons.bolt_rounded,
              label: 'My Bounties',
              trailing: '${myBounties.bounties.length}',
              onTap: () => context.push('/profile/bounties'),
            ),
            _MenuItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet',
              onTap: () => context.go('/wallet'),
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => context.push(AppRoutes.settings),
            ),

            const SizedBox(height: 24),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 8),

            _MenuItem(
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              color: AppColors.error,
              onTap: () => ref.read(authProvider.notifier).logout(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Minimal stat ────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;

  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textHint, fontSize: 12),
        ),
      ],
    );
  }
}

// ── Menu item ───────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: c.withValues(alpha: 0.7), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: c,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trailing!,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (color == null)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
