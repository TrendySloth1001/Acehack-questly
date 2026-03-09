import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Detailed XP & leveling rules — minimal black + neon accents.
class XpRulesScreen extends StatelessWidget {
  const XpRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.fore,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'HOW IT WORKS',
          style: TextStyle(
            color: AppColors.fore,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
        children: [
          // ── Intro ─────────────────────────────────────
          const Text(
            'Earn XP. Level up.\nClimb the ranks.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Every action earns or costs XP. Your level and rank '
            'update automatically as you grow.',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // ── Earn XP ───────────────────────────────────
          _SectionHeader(title: 'EARN XP', color: AppColors.neonGreen),
          const SizedBox(height: 14),
          _XpRuleRow(
            icon: Icons.check_circle_outline_rounded,
            label: 'Complete a bounty',
            xp: '+100',
            color: AppColors.neonGreen,
          ),
          _XpRuleRow(
            icon: Icons.star_rounded,
            label: '5-star review received',
            xp: '+50',
            color: AppColors.neonGreen,
          ),
          _XpRuleRow(
            icon: Icons.star_half_rounded,
            label: '4-star review received',
            xp: '+25',
            color: AppColors.neonGreen,
          ),
          _XpRuleRow(
            icon: Icons.add_circle_outline_rounded,
            label: 'Post a bounty',
            xp: '+20',
            color: AppColors.neonGreen,
          ),
          _XpRuleRow(
            icon: Icons.upload_file_rounded,
            label: 'Submit proof',
            xp: '+10',
            color: AppColors.neonGreen,
          ),
          _XpRuleRow(
            icon: Icons.local_fire_department_outlined,
            label: 'Daily streak bonus',
            xp: '+5',
            color: AppColors.neonGreen,
          ),

          const SizedBox(height: 28),

          // ── Lose XP ───────────────────────────────────
          _SectionHeader(title: 'LOSE XP', color: AppColors.error),
          const SizedBox(height: 14),
          _XpRuleRow(
            icon: Icons.star_border_rounded,
            label: '1-star review received',
            xp: '−30',
            color: AppColors.error,
          ),
          _XpRuleRow(
            icon: Icons.star_border_rounded,
            label: '2-star review received',
            xp: '−15',
            color: AppColors.error,
          ),
          _XpRuleRow(
            icon: Icons.cancel_outlined,
            label: 'Cancel after someone claimed',
            xp: '−20',
            color: AppColors.error,
          ),
          _XpRuleRow(
            icon: Icons.bedtime_outlined,
            label: 'Inactive for 3+ days',
            xp: '−10/day',
            color: AppColors.error,
          ),

          const SizedBox(height: 36),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 36),

          // ── Level Formula ─────────────────────────────
          _SectionHeader(title: 'LEVELING', color: AppColors.neonCyan),
          const SizedBox(height: 14),
          Text(
            'Your level is calculated from total XP:',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'level = floor( √(xp / 25) )',
              style: TextStyle(
                color: AppColors.neonCyan,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _LevelExample(level: 1, xp: 25),
          _LevelExample(level: 5, xp: 625),
          _LevelExample(level: 10, xp: 2500),
          _LevelExample(level: 20, xp: 10000),
          _LevelExample(level: 35, xp: 30625),
          _LevelExample(level: 50, xp: 62500),

          const SizedBox(height: 36),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 36),

          // ── Rank Tiers ────────────────────────────────
          _SectionHeader(title: 'RANK TIERS', color: AppColors.neonCyan),
          const SizedBox(height: 8),
          Text(
            'Your rank upgrades automatically as you hit XP thresholds.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          _TierRow(tier: 'WOOD', minXp: '0', color: const Color(0xFF8B6914)),
          _TierRow(tier: 'STONE', minXp: '500', color: const Color(0xFF8E8E8E)),
          _TierRow(
            tier: 'IRON',
            minXp: '1,500',
            color: const Color(0xFFC8C8C8),
          ),
          _TierRow(
            tier: 'GOLD',
            minXp: '4,000',
            color: const Color(0xFFFFD700),
          ),
          _TierRow(
            tier: 'DIAMOND',
            minXp: '10,000',
            color: const Color(0xFF00D4FF),
          ),
          _TierRow(
            tier: 'NETHERITE',
            minXp: '25,000',
            color: const Color(0xFF4A3728),
          ),

          const SizedBox(height: 36),

          // ── Footer tip ────────────────────────────────
          Center(
            child: Text(
              'Stay active · Complete bounties · Collect 5-star reviews',
              style: TextStyle(
                color: AppColors.neonCyan.withValues(alpha: 0.4),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

class _XpRuleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String xp;
  final Color color;

  const _XpRuleRow({
    required this.icon,
    required this.label,
    required this.xp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.withValues(alpha: 0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            xp,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelExample extends StatelessWidget {
  final int level;
  final int xp;
  const _LevelExample({required this.level, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              'Lvl $level',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Text(
            '→',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Text(
            '${_fmtNum(xp)} XP',
            style: TextStyle(
              color: AppColors.neonCyan.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtNum(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return '$n';
  }
}

class _TierRow extends StatelessWidget {
  final String tier;
  final String minXp;
  final Color color;

  const _TierRow({
    required this.tier,
    required this.minXp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Tier icon dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              tier,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Text(
            '$minXp+ XP',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
