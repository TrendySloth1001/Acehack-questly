import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/gamification_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaderboardProvider);
    final currentUserId = ref.watch(authProvider).user?.id;

    // Find current user's entry
    LeaderboardEntry? myEntry;
    int? myIndex;
    if (currentUserId != null && state.entries.isNotEmpty) {
      for (int i = 0; i < state.entries.length; i++) {
        if (state.entries[i].id == currentUserId) {
          myEntry = state.entries[i];
          myIndex = i;
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'LEADERBOARD',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => context.push('/home/xp-rules'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.25),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 13,
                    color: AppColors.neonCyan.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Rules',
                    style: TextStyle(
                      color: AppColors.neonCyan.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.neonCyan,
                strokeWidth: 1.5,
              ),
            )
          : state.error != null
          ? const Center(
              child: Text(
                'Failed to load',
                style: TextStyle(color: Color(0xFF555555), fontSize: 13),
              ),
            )
          : state.entries.isEmpty
          ? const Center(
              child: Text(
                'No rankings yet',
                style: TextStyle(color: Color(0xFF555555), fontSize: 13),
              ),
            )
          : Column(
              children: [
                // ── List ──────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.neonCyan,
                    backgroundColor: Colors.black,
                    onRefresh: () =>
                        ref.read(leaderboardProvider.notifier).refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      itemCount: state.entries.length,
                      separatorBuilder: (context, index) =>
                          Container(height: 1, color: const Color(0xFF1A1A1A)),
                      itemBuilder: (context, i) {
                        return _Row(
                          entry: state.entries[i],
                          index: i,
                          isCurrentUser: state.entries[i].id == currentUserId,
                        );
                      },
                    ),
                  ),
                ),

                // ── Current user footer ──────────────
                if (myEntry != null)
                  _CurrentUserFooter(entry: myEntry, rank: myIndex! + 1),
              ],
            ),
    );
  }
}

// ─── Row ──────────────────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  final LeaderboardEntry entry;
  final int index;
  final bool isCurrentUser;

  const _Row({
    required this.entry,
    required this.index,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTop3 = index < 3;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          // ── Main row ────────────────────────────────
          Row(
            children: [
              // Rank
              SizedBox(
                width: 28,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isTop3
                        ? AppColors.neonCyan
                        : const Color(0xFF555555),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrentUser
                        ? AppColors.neonGreen.withValues(alpha: 0.5)
                        : isTop3
                        ? AppColors.neonCyan.withValues(alpha: 0.3)
                        : const Color(0xFF222222),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: entry.avatarUrl != null
                      ? Image.network(
                          entry.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, st) => _buildInitial(),
                        )
                      : _buildInitial(),
                ),
              ),
              const SizedBox(width: 14),

              // Name + tier
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.name ?? 'Anonymous',
                            style: TextStyle(
                              color: isCurrentUser
                                  ? AppColors.neonGreen
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.neonGreen.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'YOU',
                              style: TextStyle(
                                color: AppColors.neonGreen.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lvl ${entry.level} · ${_tierLabel(entry.tier)}',
                      style: TextStyle(
                        color: isTop3
                            ? AppColors.neonCyan.withValues(alpha: 0.5)
                            : const Color(0xFF444444),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // XP + arrows
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _fmtXp(entry.xp),
                        style: TextStyle(
                          color: isTop3 ? AppColors.neonGreen : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'xp',
                        style: TextStyle(
                          color: isTop3
                              ? AppColors.neonGreen.withValues(alpha: 0.5)
                              : const Color(0xFF444444),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Day arrows (level progression indicator)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_drop_up_rounded,
                        size: 16,
                        color: entry.xp > 0
                            ? AppColors.neonGreen
                            : const Color(0xFF333333),
                      ),
                      Text(
                        '+${entry.level}',
                        style: TextStyle(
                          color: entry.xp > 0
                              ? AppColors.neonGreen.withValues(alpha: 0.6)
                              : const Color(0xFF333333),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 16,
                        color: Color(0xFF333333),
                      ),
                      const Text(
                        '0',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Rating stars ────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 78, top: 6),
            child: Row(
              children: [
                ..._buildStars(entry.avgRating ?? 0),
                const SizedBox(width: 4),
                Text(
                  entry.avgRating != null
                      ? entry.avgRating!.toStringAsFixed(1)
                      : '—',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (entry.totalReviews > 0) ...[
                  const SizedBox(width: 3),
                  Text(
                    '(${entry.totalReviews})',
                    style: const TextStyle(
                      color: Color(0xFF444444),
                      fontSize: 9,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitial() {
    final ch = (entry.name ?? '?').isNotEmpty
        ? entry.name![0].toUpperCase()
        : '?';
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Text(
          ch,
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  static List<Widget> _buildStars(double rating) {
    return List.generate(5, (i) {
      final filled = i < rating.round();
      return Padding(
        padding: const EdgeInsets.only(right: 1),
        child: Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 12,
          color: filled ? AppColors.neonCyan : const Color(0xFF2A2A2A),
        ),
      );
    });
  }

  static String _fmtXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return '$xp';
  }

  static String _tierLabel(String tier) =>
      tier[0].toUpperCase() + tier.substring(1).toLowerCase();
}

// ─── Current User Footer ──────────────────────────────────────────────────────

class _CurrentUserFooter extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const _CurrentUserFooter({required this.entry, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Color(0xFF1A1A1A), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Row(
        children: [
          // Your rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.neonGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + tier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Ranking',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      entry.name ?? 'You',
                      style: const TextStyle(
                        color: AppColors.neonGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ..._buildStars(entry.avgRating ?? 0),
                  ],
                ),
              ],
            ),
          ),

          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _fmtXp(entry.xp),
                    style: const TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'xp',
                    style: TextStyle(
                      color: AppColors.neonGreen.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                'Lvl ${entry.level}',
                style: const TextStyle(
                  color: Color(0xFF444444),
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

  static List<Widget> _buildStars(double rating) {
    return List.generate(5, (i) {
      final filled = i < rating.round();
      return Padding(
        padding: const EdgeInsets.only(right: 1),
        child: Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 11,
          color: filled ? AppColors.neonCyan : const Color(0xFF2A2A2A),
        ),
      );
    });
  }

  static String _fmtXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return '$xp';
  }
}
