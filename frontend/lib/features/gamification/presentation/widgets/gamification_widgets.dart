import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Minecraft-style rank tiers with themed colors.
class MinecraftRank {
  static const Map<String, _RankData> _ranks = {
    'WOOD': _RankData('Wood', Color(0xFF8B6914), '🪓', Color(0xFF6B4F0A)),
    'STONE': _RankData('Stone', Color(0xFF8E8E8E), '⛏️', Color(0xFF6E6E6E)),
    'IRON': _RankData('Iron', Color(0xFFC8C8C8), '⚔️', Color(0xFFA0A0A0)),
    'GOLD': _RankData('Gold', Color(0xFFFFD700), '👑', Color(0xFFCCAA00)),
    'DIAMOND': _RankData('Diamond', Color(0xFF00D4FF), '💎', Color(0xFF00A0CC)),
    'NETHERITE': _RankData('Netherite', Color(0xFF4A3728), '🔱', Color(0xFF352619)),
  };

  static String label(String tier) => _ranks[tier]?.label ?? 'Wood';
  static Color color(String tier) => _ranks[tier]?.color ?? const Color(0xFF8B6914);
  static String emoji(String tier) => _ranks[tier]?.emoji ?? '🪓';
  static Color dimColor(String tier) => _ranks[tier]?.dimColor ?? const Color(0xFF6B4F0A);
}

class _RankData {
  final String label;
  final Color color;
  final String emoji;
  final Color dimColor;

  const _RankData(this.label, this.color, this.emoji, this.dimColor);
}

/// Minecraft-themed XP progress bar.
class XpBar extends StatelessWidget {
  final int currentXp;
  final int nextLevelXp;
  final int level;
  final String rankTier;

  const XpBar({
    super.key,
    required this.currentXp,
    required this.nextLevelXp,
    required this.level,
    required this.rankTier,
  });

  @override
  Widget build(BuildContext context) {
    final prevLevelXp = level * level * 25;
    final xpInLevel = currentXp - prevLevelXp;
    final xpNeeded = nextLevelXp - prevLevelXp;
    final progress = xpNeeded > 0 ? (xpInLevel / xpNeeded).clamp(0.0, 1.0) : 1.0;
    final rankColor = MinecraftRank.color(rankTier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level label + XP count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'LVL $level',
                  style: TextStyle(
                    color: rankColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: rankColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: rankColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    MinecraftRank.label(rankTier),
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '$currentXp / $nextLevelXp XP',
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Minecraft-style pixelated XP bar
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: rankColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: [
                // Background segments (Minecraft-style pixel blocks)
                Row(
                  children: List.generate(20, (i) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(0.5),
                        color: AppColors.surfaceLight,
                      ),
                    );
                  }),
                ),
                // Progress fill
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          rankColor.withValues(alpha: 0.8),
                          rankColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: rankColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: List.generate(
                        (progress * 20).round().clamp(0, 20),
                        (i) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(0.5),
                            color: rankColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact rank badge for lists / leaderboard.
class RankBadge extends StatelessWidget {
  final String tier;
  final double size;

  const RankBadge({super.key, required this.tier, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final rankColor = MinecraftRank.color(tier);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: rankColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: rankColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: rankColor.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          MinecraftRank.emoji(tier),
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}

/// Star rating display widget.
class StarRating extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double starSize;
  final bool showCount;

  const StarRating({
    super.key,
    required this.rating,
    this.totalReviews = 0,
    this.starSize = 16,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final fill = (rating - i).clamp(0.0, 1.0);
          return Icon(
            fill >= 0.75
                ? Icons.star_rounded
                : fill >= 0.25
                    ? Icons.star_half_rounded
                    : Icons.star_border_rounded,
            color: AppColors.warning,
            size: starSize,
          );
        }),
        if (showCount) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: starSize * 0.75,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (totalReviews > 0) ...[
            const SizedBox(width: 2),
            Text(
              '($totalReviews)',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: starSize * 0.65,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Interactive star picker for submitting reviews.
class StarPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  final double starSize;

  const StarPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.starSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final starNum = i + 1;
        return GestureDetector(
          onTap: () => onChanged(starNum),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starNum <= selected
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: starNum <= selected
                  ? AppColors.warning
                  : AppColors.textHint,
              size: starSize,
            ),
          ),
        );
      }),
    );
  }
}
