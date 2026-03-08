import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'gamification_widgets.dart';
import 'level_up_popup.dart';

/// Shows a Minecraft-themed XP reward popup overlay.
/// If [previousLevel] is provided and [newLevel] is higher,
/// a clean level-up popup will follow automatically.
///
/// Call [showXpRewardPopup] to display it.
Future<void> showXpRewardPopup(
  BuildContext context, {
  required int xpGained,
  required String reason,
  int? newTotalXp,
  int? newLevel,
  int? previousLevel,
  String? rankTier,
}) async {
  if (xpGained == 0) return;
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'XP Reward',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (ctx, anim, _, child) {
      final curve = CurvedAnimation(parent: anim, curve: Curves.elasticOut);
      return ScaleTransition(
        scale: curve,
        child: FadeTransition(opacity: anim, child: child),
      );
    },
    pageBuilder: (ctx, _, __) => _XpRewardDialog(
      xpGained: xpGained,
      reason: reason,
      newTotalXp: newTotalXp,
      newLevel: newLevel,
      rankTier: rankTier ?? 'WOOD',
    ),
  );

  // Show level-up popup if level increased
  if (previousLevel != null &&
      newLevel != null &&
      newLevel > previousLevel &&
      context.mounted) {
    await showLevelUpPopup(context, newLevel: newLevel, rankTier: rankTier);
  }
}

class _XpRewardDialog extends StatefulWidget {
  final int xpGained;
  final String reason;
  final int? newTotalXp;
  final int? newLevel;
  final String rankTier;

  const _XpRewardDialog({
    required this.xpGained,
    required this.reason,
    this.newTotalXp,
    this.newLevel,
    required this.rankTier,
  });

  @override
  State<_XpRewardDialog> createState() => _XpRewardDialogState();
}

class _XpRewardDialogState extends State<_XpRewardDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _countAnim = Tween<double>(
      begin: 0,
      end: widget.xpGained.toDouble(),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();

    // Auto-dismiss after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.xpGained > 0;
    final rankColor = MinecraftRank.color(widget.rankTier);
    final emoji = isPositive ? '⚡' : '💀';
    final sign = isPositive ? '+' : '';

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: rankColor.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: rankColor.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: (isPositive ? AppColors.neonGreen : AppColors.error)
                    .withValues(alpha: 0.15),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),

              // XP amount (animated count-up)
              AnimatedBuilder(
                animation: _countAnim,
                builder: (_, __) => Text(
                  '$sign${_countAnim.value.toInt()} XP',
                  style: TextStyle(
                    color: isPositive ? AppColors.neonGreen : AppColors.error,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color:
                            (isPositive ? AppColors.neonGreen : AppColors.error)
                                .withValues(alpha: 0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Reason
              Text(
                widget.reason,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              // Level + rank info
              if (widget.newLevel != null && widget.newTotalXp != null) ...[
                const SizedBox(height: 16),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RankBadge(tier: widget.rankTier, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Level ${widget.newLevel}',
                      style: TextStyle(
                        color: rankColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('•', style: TextStyle(color: AppColors.textHint)),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.newTotalXp} XP total',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
