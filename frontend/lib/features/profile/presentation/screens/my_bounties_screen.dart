import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/algo_inr.dart';
import '../../../bounty/data/models/bounty_model.dart';
import '../../../bounty/presentation/providers/bounty_provider.dart';

class MyBountiesScreen extends ConsumerWidget {
  const MyBountiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myBountiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'My Bounties',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (!state.isLoading)
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () => ref.read(myBountiesProvider.notifier).refresh(),
            ),
        ],
      ),
      body: _body(context, state),
    );
  }

  Widget _body(BuildContext context, MyBountiesState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Failed to load bounties',
            style: TextStyle(color: AppColors.textHint, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.bounties.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt_rounded,
              size: 52,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'No bounties yet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Bounties you create will appear here.',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: state.bounties.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _BountyTile(bounty: state.bounties[i]),
    );
  }
}

class _BountyTile extends StatelessWidget {
  final BountyModel bounty;
  const _BountyTile({required this.bounty});

  @override
  Widget build(BuildContext context) {
    final isExpired =
        bounty.deadline.isBefore(DateTime.now()) && bounty.status == 'OPEN';

    return GestureDetector(
      onTap: () => context.push('/home/bounty/${bounty.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status row
            Row(
              children: [
                Expanded(
                  child: Text(
                    bounty.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: bounty.status, isExpired: isExpired),
              ],
            ),
            const SizedBox(height: 6),
            // Category + deadline
            Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 12,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  bounty.category,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.schedule_outlined,
                  size: 12,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  _deadlineLabel(bounty.deadline),
                  style: TextStyle(
                    color: isExpired ? AppColors.error : AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Bottom row: reward + claims + escrow
            Row(
              children: [
                if (bounty.algoAmount > 0) ...[
                  AlgoRewardChip(amount: bounty.algoAmount),
                  const SizedBox(width: 8),
                ],
                _EscrowBadge(status: bounty.escrowStatus),
                const Spacer(),
                Icon(Icons.group_outlined, size: 13, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  '${bounty.claimCount} claim${bounty.claimCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _deadlineLabel(DateTime d) {
    final diff = d.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays < 7) return '${diff.inDays}d left';
    return '${(diff.inDays / 7).floor()}w left';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool isExpired;
  const _StatusChip({required this.status, required this.isExpired});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'OPEN' when isExpired => ('Expired', AppColors.error),
      'OPEN' => ('Open', AppColors.neonGreen),
      'IN_PROGRESS' => ('In Progress', AppColors.neonCyan),
      'COMPLETED' => ('Completed', AppColors.primary),
      'CANCELLED' => ('Cancelled', AppColors.textHint),
      _ => (status, AppColors.textHint),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EscrowBadge extends StatelessWidget {
  final String status;
  const _EscrowBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'FUNDED' => ('Funded', AppColors.neonGreen),
      'RELEASED' => ('Released', AppColors.primary),
      'REFUNDED' => ('Refunded', AppColors.textSecondary),
      _ => ('Unfunded', AppColors.neonOrange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
