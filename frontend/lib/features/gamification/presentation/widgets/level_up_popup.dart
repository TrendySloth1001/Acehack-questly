import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Simple, clean level-up popup — not flashy, just satisfying.
/// Shows: new level number + a cool message.
Future<void> showLevelUpPopup(
  BuildContext context, {
  required int newLevel,
  String? rankTier,
}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Level Up',
    barrierColor: Colors.black87,
    transitionDuration: const Duration(milliseconds: 350),
    transitionBuilder: (ctx, anim, _, child) {
      final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return ScaleTransition(
        scale: curve,
        child: FadeTransition(opacity: anim, child: child),
      );
    },
    pageBuilder: (ctx, anim1, anim2) =>
        _LevelUpDialog(newLevel: newLevel, rankTier: rankTier ?? 'WOOD'),
  );
}

class _LevelUpDialog extends StatefulWidget {
  final int newLevel;
  final String rankTier;

  const _LevelUpDialog({required this.newLevel, required this.rankTier});

  @override
  State<_LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<_LevelUpDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  static const _messages = [
    'keep going.',
    'you\'re on fire.',
    'unstoppable.',
    'the grind pays off.',
    'respect earned.',
    'next level unlocked.',
    'built different.',
    'up only.',
    'no looking back.',
    'legend in the making.',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulse = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat(reverse: true);

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
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
    final msg = _messages[widget.newLevel % _messages.length];

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: _pulse,
          child: Container(
            width: 260,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Level number — big, white
                Text(
                  '${widget.newLevel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'LEVEL UP',
                  style: TextStyle(
                    color: AppColors.neonCyan.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 20),
                Container(width: 40, height: 1, color: const Color(0xFF1A1A1A)),
                const SizedBox(height: 20),
                // Cool message
                Text(
                  msg,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
