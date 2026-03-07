import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/bounty_model.dart';

/// Minimal bounty row — no card/box, just clean text layout.
class BountyTile extends StatelessWidget {
  final BountyModel bounty;
  final VoidCallback? onTap;

  const BountyTile({super.key, required this.bounty, this.onTap});

  @override
  Widget build(BuildContext context) {
    final deadline = bounty.deadline;
    final isExpired = deadline.isBefore(DateTime.now());
    final timeLeft = _timeLeft(deadline);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail or category dot
            if (bounty.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  bounty.imageUrls.first,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, e, s) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.textHint,
                      size: 18,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _categoryColor(bounty.category),
                ),
              ),
            const SizedBox(width: 12),

            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bounty.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Creator
                      Text(
                        bounty.creator.name ?? 'anonymous',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.textHint,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Time
                      Text(
                        isExpired ? 'expired' : timeLeft,
                        style: TextStyle(
                          color: isExpired
                              ? AppColors.error
                              : AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                      if (bounty.location != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.textHint,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            bounty.location!,
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Reward badge
            if (bounty.algoAmount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.neonGreen.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '${bounty.algoAmount.toStringAsFixed(bounty.algoAmount == bounty.algoAmount.roundToDouble() ? 0 : 1)} A',
                  style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
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

  String _timeLeft(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m left';
    return 'soon';
  }
}

/// Small claim row for the home screen.
class ClaimTile extends StatelessWidget {
  final BountyClaimModel claim;
  final VoidCallback? onTap;

  const ClaimTile({super.key, required this.claim, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bounty = claim.bounty;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _statusColor(claim.status).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _statusIcon(claim.status),
                size: 14,
                color: _statusColor(claim.status),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bounty?.title ?? 'Bounty',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    claim.status.toLowerCase(),
                    style: TextStyle(
                      color: _statusColor(claim.status),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (bounty != null && bounty.algoAmount > 0)
              Text(
                '${bounty.algoAmount.toStringAsFixed(0)} A',
                style: const TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
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

  IconData _statusIcon(String status) {
    switch (status) {
      case 'ACTIVE':
        return Icons.play_arrow_rounded;
      case 'SUBMITTED':
        return Icons.hourglass_top_rounded;
      case 'APPROVED':
        return Icons.check_rounded;
      case 'REJECTED':
        return Icons.close_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
}
