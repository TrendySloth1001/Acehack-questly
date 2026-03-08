import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/gamification_provider.dart';
import '../widgets/gamification_widgets.dart';

/// Global XP leaderboard — Minecraft-themed.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🏆', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text(
              'LEADERBOARD',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : state.error != null
          ? Center(
              child: Text(
                'Failed to load leaderboard',
                style: TextStyle(color: AppColors.error),
              ),
            )
          : state.entries.isEmpty
          ? const Center(
              child: Text(
                'No rankings yet — go complete some bounties!',
                style: TextStyle(color: AppColors.textHint),
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () => ref.read(leaderboardProvider.notifier).refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: state.entries.length,
                itemBuilder: (context, index) {
                  final entry = state.entries[index];
                  return _LeaderboardTile(entry: entry, index: index);
                },
              ),
            ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final int index;

  const _LeaderboardTile({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    final isTop3 = index < 3;
    final rankColor = MinecraftRank.color(entry.tier);
    final medals = ['🥇', '🥈', '🥉'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTop3 ? rankColor.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTop3 ? rankColor.withValues(alpha: 0.3) : AppColors.border,
        ),
        boxShadow: isTop3
            ? [
                BoxShadow(
                  color: rankColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 36,
            child: Center(
              child: isTop3
                  ? Text(medals[index], style: const TextStyle(fontSize: 20))
                  : Text(
                      '#${entry.rank}',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: rankColor.withValues(alpha: 0.2),
            backgroundImage: entry.avatarUrl != null
                ? NetworkImage(entry.avatarUrl!)
                : null,
            child: entry.avatarUrl == null
                ? Icon(Icons.person, color: rankColor, size: 20)
                : null,
          ),
          const SizedBox(width: 12),

          // Name + rank tier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name ?? 'Anonymous',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    RankBadge(tier: entry.tier, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'LVL ${entry.level}',
                      style: TextStyle(
                        color: rankColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (entry.avgRating != null) ...[
                      const SizedBox(width: 8),
                      StarRating(
                        rating: entry.avgRating!,
                        totalReviews: entry.totalReviews,
                        starSize: 12,
                        showCount: true,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.xp}',
                style: TextStyle(
                  color: rankColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'XP',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
