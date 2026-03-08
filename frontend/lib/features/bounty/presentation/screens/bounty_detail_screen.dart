import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/algo_inr.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../algorand/presentation/providers/wallet_provider.dart';
import '../../../gamification/presentation/providers/review_provider.dart';
import '../../../gamification/presentation/widgets/gamification_widgets.dart';
import '../../data/models/bounty_model.dart';
import '../providers/bounty_provider.dart';

class BountyDetailScreen extends ConsumerStatefulWidget {
  final String bountyId;
  const BountyDetailScreen({super.key, required this.bountyId});

  @override
  ConsumerState<BountyDetailScreen> createState() => _BountyDetailScreenState();
}

class _BountyDetailScreenState extends ConsumerState<BountyDetailScreen> {
  BountyModel? _bounty;
  bool _loading = true;
  String? _error;
  bool _claiming = false;
  bool _deleting = false;
  bool _declaiming = false;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(bountyRepositoryProvider);
      final bounty = await repo.getBounty(widget.bountyId);
      if (mounted) setState(() => _bounty = bounty);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _claimBounty() async {
    setState(() => _claiming = true);
    try {
      final repo = ref.read(bountyRepositoryProvider);
      await repo.claimBounty(widget.bountyId);
      ref.read(bountyListProvider.notifier).refresh();
      ref.read(myClaimsProvider.notifier).load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bounty claimed!'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  Future<void> _declaimBounty(String claimId) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(
              Icons.exit_to_app_rounded,
              color: AppColors.warning,
              size: 36,
            ),
            const SizedBox(height: 12),
            const Text(
              'Leave this bounty?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your claim will be removed and the bounty will return to the public pool.',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Leave',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _declaiming = true);
    try {
      final repo = ref.read(bountyRepositoryProvider);
      await repo.declaim(claimId);
      ref.read(bountyListProvider.notifier).refresh();
      ref.read(myClaimsProvider.notifier).load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You left the bounty'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _declaiming = false);
    }
  }

  Future<void> _deleteBounty() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 36,
            ),
            const SizedBox(height: 12),
            const Text(
              'Delete this bounty?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'This cannot be undone.',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      final repo = ref.read(bountyRepositoryProvider);
      await repo.deleteBounty(widget.bountyId);
      ref.read(bountyListProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bounty deleted'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _cancelBounty() async {
    final isFunded = _bounty?.escrowStatus == 'FUNDED';
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              isFunded ? Icons.account_balance_wallet : Icons.cancel_outlined,
              color: AppColors.neonOrange,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              isFunded ? 'Cancel & Withdraw Escrow?' : 'Cancel this bounty?',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isFunded
                  ? 'The escrowed ALGO will be refunded to your wallet. '
                        'All pending claims will be rejected.'
                  : 'This bounty will be marked as cancelled and removed from the public pool.',
              style: const TextStyle(color: AppColors.textHint, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Keep'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonOrange,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(
                      isFunded ? 'Cancel & Refund' : 'Cancel Bounty',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _cancelling = true);
    try {
      final repo = ref.read(bountyRepositoryProvider);
      await repo.cancelBounty(widget.bountyId);
      ref.read(bountyListProvider.notifier).refresh();
      ref.read(myClaimsProvider.notifier).load();
      // Refresh wallet to show updated balance after refund
      ref.read(walletProvider.notifier).load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFunded
                  ? 'Bounty cancelled — escrow refunded to your wallet!'
                  : 'Bounty cancelled',
            ),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Future<void> _resolveClaim(String claimId, String action) async {
    // Guard: block approval if escrow hasn't been funded yet
    if (action == 'APPROVED' &&
        (_bounty?.algoAmount ?? 0) > 0 &&
        _bounty?.escrowStatus != 'FUNDED') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot approve yet — the escrow is not funded. '
              'Scroll up and tap "Fund Escrow" first so the payment '
              'can be released to the claimer.',
            ),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }
    try {
      final repo = ref.read(bountyRepositoryProvider);
      await repo.resolveClaim(claimId, action: action);
      ref.read(bountyListProvider.notifier).refresh();
      ref.read(myClaimsProvider.notifier).load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'APPROVED' ? 'Claim approved!' : 'Claim rejected',
            ),
            backgroundColor: action == 'APPROVED'
                ? AppColors.neonGreen
                : AppColors.error,
          ),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Review bottom sheet ───────────────────────────────────
  Future<void> _showReviewSheet({
    required String bountyId,
    required String revieweeId,
    required String revieweeName,
  }) async {
    int stars = 0;
    final commentCtrl = TextEditingController();

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '⭐ Leave a Review',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Rate your experience with $revieweeName',
                style: const TextStyle(color: AppColors.textHint, fontSize: 13),
              ),
              const SizedBox(height: 20),
              StarPicker(
                selected: stars,
                onChanged: (v) => setSheetState(() => stars = v),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Optional comment...',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: stars == 0
                      ? null
                      : () async {
                          try {
                            final dio = ref.read(dioProvider);
                            await submitReview(
                              dio,
                              bountyId: bountyId,
                              revieweeId: revieweeId,
                              stars: stars,
                              comment: commentCtrl.text.trim().isEmpty
                                  ? null
                                  : commentCtrl.text.trim(),
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop(true);
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(_friendlyError(e)),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  icon: const Icon(Icons.star_rounded, size: 18),
                  label: const Text(
                    'Submit Review',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: AppColors.warning.withValues(
                      alpha: 0.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted! 🌟'),
          backgroundColor: AppColors.neonGreen,
        ),
      );
    }
  }

  // ── Raise dispute ─────────────────────────────────────────
  Future<void> _raiseDisputeSheet(String claimId) async {
    final reasonCtrl = TextEditingController();

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '⚠️ Raise Dispute',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Explain why you disagree with the rejection',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Describe the issue...',
                hintStyle: const TextStyle(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final reason = reasonCtrl.text.trim();
                  if (reason.isEmpty) return;
                  try {
                    final dio = ref.read(dioProvider);
                    await dio.post(
                      ApiEndpoints.raiseDispute(claimId),
                      data: {'reason': reason},
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop(true);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(_friendlyError(e)),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.gavel_rounded, size: 18),
                label: const Text(
                  'Submit Dispute',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dispute raised — the bounty creator will review it'),
          backgroundColor: AppColors.neonOrange,
        ),
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            )
          : _error != null
          ? _buildError()
          : _bounty != null
          ? _buildContent()
          : const SizedBox.shrink(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 40),
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final b = _bounty!;
    final hasCoords = b.latitude != null && b.longitude != null;
    final isExpired = b.deadline.isBefore(DateTime.now());
    final isOpen = b.status == 'OPEN';
    final currentUserId = ref.watch(authProvider).user?.id;
    final isOwner = currentUserId != null && currentUserId == b.creator.id;

    // Find current user's claim on this bounty (if any)
    BountyClaimModel? myClaim;
    if (currentUserId != null && b.claims.isNotEmpty) {
      for (final c in b.claims) {
        if (c.claimer.id == currentUserId) {
          myClaim = c;
          break;
        }
      }
    }

    return CustomScrollView(
      slivers: [
        // ── Minimal AppBar (no cover image) ───────────────────
        SliverAppBar(
          backgroundColor: AppColors.background,
          pinned: true,
          expandedHeight: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            // ── Wallet balance chip ──────────────────────────
            Consumer(
              builder: (context, cRef, _) {
                final wallet = cRef.watch(walletProvider);
                final bal = wallet.balance?.balanceAlgo ?? 0.0;
                final minReserve = wallet.balance?.minBalance ?? 0.1;
                final spendable = (bal - minReserve).clamp(
                  0.0,
                  double.infinity,
                );
                return GestureDetector(
                  onTap: () {
                    if (wallet.address != null) {
                      Clipboard.setData(ClipboardData(text: wallet.address!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address copied')),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/questly_logo.svg',
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${spendable.toStringAsFixed(2)} A',
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
              },
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: const Icon(
                  Icons.share_outlined,
                  color: AppColors.textPrimary,
                  size: 18,
                ),
              ),
              onPressed: () {},
            ),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status + category + reward ─────────────────
                Row(
                  children: [
                    _statusChip(b.status),
                    const SizedBox(width: 8),
                    _chip(Icons.category_outlined, b.category),
                    const Spacer(),
                    if (b.algoAmount > 0)
                      Consumer(
                        builder: (context, cRef, _) {
                          final inrRate = cRef
                              .watch(algoInrRateProvider)
                              .valueOrNull;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neonGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.neonGreen.withValues(
                                  alpha: 0.3,
                                ),
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/questly_logo.svg',
                                      width: 16,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      formatAlgo(b.algoAmount),
                                      style: const TextStyle(
                                        color: AppColors.neonGreen,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                                if (inrRate != null)
                                  Text(
                                    algoToInrString(b.algoAmount, inrRate),
                                    style: TextStyle(
                                      color: AppColors.neonGreen.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
                // ── Escrow Status Badge ────────────────────────
                if (b.algoAmount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _EscrowStatusBadge(bounty: b, isOwner: isOwner),
                  ),
                const SizedBox(height: 16),

                // ── Title ──────────────────────────────────────
                Text(
                  b.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Creator row ────────────────────────────────
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primaryDim,
                      backgroundImage: b.creator.avatarUrl != null
                          ? NetworkImage(b.creator.avatarUrl!)
                          : null,
                      child: b.creator.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 14,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      b.creator.name ?? 'anonymous',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.schedule_outlined,
                      color: isExpired ? AppColors.error : AppColors.textHint,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isExpired ? 'expired' : _timeLeft(b.deadline),
                      style: TextStyle(
                        color: isExpired ? AppColors.error : AppColors.textHint,
                        fontSize: 12,
                      ),
                    ),
                    if (b.claimCount > 0) ...[
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.people_outline,
                        color: AppColors.textHint,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${b.claimCount} claim${b.claimCount == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // ── Description ────────────────────────────────
                const Text(
                  'Description',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  b.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Reference Images Gallery ──────────────────
                if (b.imageUrls.isNotEmpty) ...[
                  _ReferenceImagesGallery(imageUrls: b.imageUrls),
                  const SizedBox(height: 24),
                ],

                // ── Location + Map ────────────────────────────
                if (b.location != null || hasCoords) ...[
                  const Text(
                    'Location',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (b.location != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            b.location!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (hasCoords) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 180,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(b.latitude!, b.longitude!),
                            initialZoom: 15,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.questly.questly',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(b.latitude!, b.longitude!),
                                  width: 32,
                                  height: 32,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],

                // ── Extra fields ──────────────────────────────
                if (b.extraFields != null && b.extraFields!.isNotEmpty) ...[
                  const Text(
                    'Details',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...b.extraFields!.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              e.key,
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              e.value.toString(),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Meta info ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metaItem('Deadline', _formatDate(b.deadline)),
                      Container(
                        width: 0.5,
                        height: 30,
                        color: AppColors.border,
                      ),
                      _metaItem('Claims', '${b.claimCount}'),
                      Container(
                        width: 0.5,
                        height: 30,
                        color: AppColors.border,
                      ),
                      _metaItem('Status', b.status.toLowerCase()),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Your claim status section ─────────────────
                if (myClaim != null) ...[
                  _MyClaimSection(
                    claim: myClaim,
                    bountyId: widget.bountyId,
                    onDeclaim: () => _declaimBounty(myClaim!.id),
                    isDeclaiming: _declaiming,
                    onReload: _load,
                    onDispute: _raiseDisputeSheet,
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Owner: Claims & Submissions ───────────────
                if (isOwner && b.claims.isNotEmpty) ...[
                  _OwnerClaimsSection(
                    claims: b.claims,
                    onResolve: (claimId, action) async {
                      await _resolveClaim(claimId, action);
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Owner banner ──────────────────────────────
                if (isOwner && isOpen) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'This is your bounty',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // ── Fund Escrow (owner, unfunded) ─────────────
                // Show whenever escrow is UNFUNDED — regardless of bounty status
                // (creator may need to fund after someone has already claimed)
                if (isOwner &&
                    b.algoAmount > 0 &&
                    b.escrowStatus == 'UNFUNDED' &&
                    b.status != 'COMPLETED' &&
                    b.status != 'CANCELLED')
                  _FundEscrowButton(bounty: b, onFunded: _load),

                // ── Cancel & Withdraw Escrow (owner, funded, non-terminal) ──
                if (isOwner &&
                    isOpen &&
                    b.algoAmount > 0 &&
                    b.escrowStatus == 'FUNDED')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _cancelling ? null : _cancelBounty,
                        icon: _cancelling
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: AppColors.neonOrange,
                                  strokeWidth: 1.5,
                                ),
                              )
                            : const Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 18,
                              ),
                        label: const Text('Cancel & Withdraw Escrow'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.neonOrange,
                          side: BorderSide(
                            color: AppColors.neonOrange.withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Cancel unfunded bounty (owner, no escrow needed) ──
                if (isOwner &&
                    isOpen &&
                    (b.algoAmount == 0 || b.escrowStatus == 'UNFUNDED'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _cancelling ? null : _cancelBounty,
                        icon: _cancelling
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: AppColors.neonOrange,
                                  strokeWidth: 1.5,
                                ),
                              )
                            : const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Cancel Bounty'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.neonOrange,
                          side: BorderSide(
                            color: AppColors.neonOrange.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Claim button ──────────────────────────────
                if (!isOwner && isOpen && !isExpired && myClaim == null) ...[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonGreen.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _claiming ? null : _claimBounty,
                        icon: _claiming
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.rocket_launch_rounded, size: 18),
                        label: Text(
                          _claiming ? 'Claiming...' : 'Claim this bounty',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonGreen,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: AppColors.neonGreen
                              .withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // ── Delete (owner only) ─────────────────────
                if (isOwner && isOpen)
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _deleting ? null : _deleteBounty,
                      icon: _deleting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: AppColors.error,
                                strokeWidth: 1.5,
                              ),
                            )
                          : const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete bounty'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                // ── Leave Review (completed bounty) ─────────
                if (b.status == 'COMPLETED') ...[
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      // Determine the reviewee (opposite party)
                      String? revieweeId;
                      String revieweeName = 'Unknown';
                      if (isOwner) {
                        // Owner reviews the claimer
                        final approvedClaim = b.claims
                            .cast<BountyClaimModel?>()
                            .firstWhere(
                              (c) => c?.status == 'APPROVED',
                              orElse: () => null,
                            );
                        if (approvedClaim != null) {
                          revieweeId = approvedClaim.claimer.id;
                          revieweeName =
                              approvedClaim.claimer.name ?? 'the hunter';
                        }
                      } else if (myClaim?.status == 'APPROVED') {
                        // Claimer reviews the owner
                        revieweeId = b.creator.id;
                        revieweeName = b.creator.name ?? 'the poster';
                      }
                      if (revieweeId == null) return const SizedBox.shrink();
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.warning.withValues(alpha: 0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _showReviewSheet(
                              bountyId: b.id,
                              revieweeId: revieweeId!,
                              revieweeName: revieweeName,
                            ),
                            icon: const Icon(Icons.star_rounded, size: 18),
                            label: Text(
                              'Review $revieweeName',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warning,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Helper widgets ───────────────────────────────────────

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'OPEN':
        color = AppColors.neonGreen;
      case 'CLAIMED':
        color = AppColors.primary;
      case 'IN_REVIEW':
        color = AppColors.warning;
      case 'COMPLETED':
        color = AppColors.neonGreen;
      case 'CANCELLED':
        color = AppColors.error;
      default:
        color = AppColors.textHint;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        status.toLowerCase().replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textHint),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textHint, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final msg = data['message'] ?? data['error'];
        if (msg != null) return msg.toString();
      }
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Request timed out \u2014 check your connection';
        case DioExceptionType.connectionError:
          return 'Cannot reach the server';
        case DioExceptionType.badResponse:
          final code = e.response?.statusCode;
          if (code == 401) return 'Session expired \u2014 sign in again';
          if (code == 404) return 'Bounty not found';
          if (code != null) return 'Server error $code';
          return 'Bad response from server';
        default:
          return 'Something went wrong, try again';
      }
    }
    return e.toString().replaceAll('Exception: ', '');
  }

  String _timeLeft(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m left';
    return 'soon';
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ═════════════════════════════════════════════════════════════
//  Reference Images Gallery — horizontal scroll + counter
// ═════════════════════════════════════════════════════════════

class _ReferenceImagesGallery extends StatefulWidget {
  final List<String> imageUrls;
  const _ReferenceImagesGallery({required this.imageUrls});

  @override
  State<_ReferenceImagesGallery> createState() =>
      _ReferenceImagesGalleryState();
}

class _ReferenceImagesGalleryState extends State<_ReferenceImagesGallery> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final count = widget.imageUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with count
        Row(
          children: [
            const Icon(
              Icons.photo_library_outlined,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 6),
            const Text(
              'Reference Images',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count image${count == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            if (count > 1)
              Text(
                'swipe to browse \u2192',
                style: TextStyle(
                  color: AppColors.textHint.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Scrollable gallery
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: count,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _showFullScreen(context, i),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.imageUrls[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textHint,
                          size: 40,
                        ),
                      ),
                    ),
                    // Gradient overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Counter badge
                    if (count > 1)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${i + 1} / $count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Dot indicator
        if (count > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              count,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? AppColors.primary
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showFullScreen(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenGallery(
          imageUrls: widget.imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  Full-screen image viewer
// ═════════════════════════════════════════════════════════════

class _FullScreenGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullScreenGallery({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _controller;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.imageUrls.length;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${_currentPage + 1} of $count',
          style: const TextStyle(fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: count,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (_, i) => InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: Image.network(
              widget.imageUrls[i],
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.broken_image_outlined,
                color: AppColors.textHint,
                size: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  My Claim Section — shows claim status + actions
// ═════════════════════════════════════════════════════════════

class _MyClaimSection extends ConsumerWidget {
  final BountyClaimModel claim;
  final String bountyId;
  final VoidCallback onDeclaim;
  final bool isDeclaiming;
  final VoidCallback onReload;
  final void Function(String claimId) onDispute;

  const _MyClaimSection({
    required this.claim,
    required this.bountyId,
    required this.onDeclaim,
    required this.isDeclaiming,
    required this.onReload,
    required this.onDispute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = claim.status == 'ACTIVE';
    final isSubmitted = claim.status == 'SUBMITTED';
    final isApproved = claim.status == 'APPROVED';
    final isRejected = claim.status == 'REJECTED';

    final statusColor = _claimColor(claim.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                isActive
                    ? Icons.assignment_outlined
                    : isSubmitted
                    ? Icons.hourglass_top_rounded
                    : isApproved
                    ? Icons.check_circle_outlined
                    : Icons.cancel_outlined,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isActive
                      ? 'You claimed this bounty'
                      : isSubmitted
                      ? 'Work submitted \u2014 under review'
                      : isApproved
                      ? 'Your work was approved!'
                      : 'Your submission was rejected',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Show submitted proof
          if (isSubmitted || isApproved || isRejected) ...[
            if (claim.proofUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Submitted attachments',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: claim.proofUrls.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final url = claim.proofUrls[i];
                    final isPdf = url.toLowerCase().endsWith('.pdf');
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: isPdf
                          ? Container(
                              width: 80,
                              height: 80,
                              color: AppColors.surface,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf_outlined,
                                    color: AppColors.error,
                                    size: 28,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'PDF',
                                    style: TextStyle(
                                      color: AppColors.textHint,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Image.network(
                              url,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 80,
                                height: 80,
                                color: AppColors.surface,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: AppColors.textHint,
                                  size: 24,
                                ),
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
            if (claim.note != null && claim.note!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  claim.note!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],

          const SizedBox(height: 14),

          // Action buttons
          if (isActive) ...[
            // Submit Work button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await context.push<bool>(
                      '/home/bounty/$bountyId/submit-proof?claimId=${claim.id}',
                    );
                    if (result == true) onReload();
                  },
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text(
                    'Submit Work',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Leave bounty button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: isDeclaiming ? null : onDeclaim,
                icon: isDeclaiming
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: AppColors.warning,
                          strokeWidth: 1.5,
                        ),
                      )
                    : const Icon(Icons.exit_to_app_rounded, size: 16),
                label: const Text('Leave bounty'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: BorderSide(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],

          // Rejected — allow resubmission + dispute
          if (isRejected) ...[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonOrange.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await context.push<bool>(
                      '/home/bounty/$bountyId/submit-proof?claimId=${claim.id}',
                    );
                    if (result == true) onReload();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Resubmit Work',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonOrange,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Raise dispute button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => onDispute(claim.id),
                icon: const Icon(Icons.gavel_rounded, size: 16),
                label: const Text(
                  'Raise Dispute',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _claimColor(String status) {
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
}

// ═════════════════════════════════════════════════════════════
//  Owner Claims Section — see all claims + approve / reject
// ═════════════════════════════════════════════════════════════

class _OwnerClaimsSection extends StatefulWidget {
  final List<BountyClaimModel> claims;
  final Future<void> Function(String claimId, String action) onResolve;

  const _OwnerClaimsSection({required this.claims, required this.onResolve});

  @override
  State<_OwnerClaimsSection> createState() => _OwnerClaimsSectionState();
}

class _OwnerClaimsSectionState extends State<_OwnerClaimsSection> {
  String? _resolvingClaimId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            const Icon(
              Icons.group_outlined,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'Claims & Submissions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${widget.claims.length}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Claim cards
        ...widget.claims.map((claim) => _buildClaimCard(claim)),
      ],
    );
  }

  Widget _buildClaimCard(BountyClaimModel claim) {
    final statusColor = _statusColor(claim.status);
    final isSubmitted = claim.status == 'SUBMITTED';
    final isApproved = claim.status == 'APPROVED';
    final isRejected = claim.status == 'REJECTED';
    final hasProof = isSubmitted || isApproved || isRejected;
    final isResolving = _resolvingClaimId == claim.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Claimer row ─────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryDim,
                backgroundImage: claim.claimer.avatarUrl != null
                    ? NetworkImage(claim.claimer.avatarUrl!)
                    : null,
                child: claim.claimer.avatarUrl == null
                    ? const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim.claimer.name ?? 'anonymous',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'claimed ${_timeAgo(claim.createdAt)}',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isApproved
                          ? Icons.check_circle_outline_rounded
                          : isSubmitted
                          ? Icons.hourglass_top_rounded
                          : isRejected
                          ? Icons.cancel_outlined
                          : Icons.assignment_outlined,
                      color: statusColor,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      claim.status.toLowerCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Proof thumbnails ────────────────────────
          if (hasProof && claim.proofUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Submitted work',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: claim.proofUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final url = claim.proofUrls[i];
                  final isPdf = url.toLowerCase().endsWith('.pdf');
                  return GestureDetector(
                    onTap: () =>
                        _showFullScreenProof(context, claim.proofUrls, i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: isPdf
                          ? Container(
                              width: 80,
                              height: 80,
                              color: AppColors.card,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf_outlined,
                                    color: AppColors.error,
                                    size: 28,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'PDF',
                                    style: TextStyle(
                                      color: AppColors.textHint,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Image.network(
                              url,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, e, s) => Container(
                                width: 80,
                                height: 80,
                                color: AppColors.card,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: AppColors.textHint,
                                  size: 24,
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],

          // ── Note ────────────────────────────────────
          if (hasProof && claim.note != null && claim.note!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                claim.note!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],

          // ── Submitted at ────────────────────────────
          if (hasProof && claim.submittedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'submitted ${_timeAgo(claim.submittedAt!)}',
              style: const TextStyle(color: AppColors.textHint, fontSize: 11),
            ),
          ],

          // ── Approve / Reject buttons ────────────────
          if (isSubmitted) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: isResolving
                          ? null
                          : () => _resolve(claim.id, 'REJECTED'),
                      icon: isResolving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: AppColors.error,
                                strokeWidth: 1.5,
                              ),
                            )
                          : const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: isResolving
                          ? null
                          : () => _resolve(claim.id, 'APPROVED'),
                      icon: isResolving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 1.5,
                              ),
                            )
                          : const Icon(Icons.check_rounded, size: 18),
                      label: const Text(
                        'Approve',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonGreen,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: AppColors.neonGreen.withValues(
                          alpha: 0.3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _resolve(String claimId, String action) async {
    setState(() => _resolvingClaimId = claimId);
    try {
      await widget.onResolve(claimId, action);
    } finally {
      if (mounted) setState(() => _resolvingClaimId = null);
    }
  }

  void _showFullScreenProof(
    BuildContext context,
    List<String> urls,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _FullScreenGallery(imageUrls: urls, initialIndex: initialIndex),
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

// ═════════════════════════════════════════════════════════════
//  FUND ESCROW BUTTON
// ═════════════════════════════════════════════════════════════

class _FundEscrowButton extends ConsumerStatefulWidget {
  final BountyModel bounty;
  final VoidCallback onFunded;

  const _FundEscrowButton({required this.bounty, required this.onFunded});

  @override
  ConsumerState<_FundEscrowButton> createState() => _FundEscrowButtonState();
}

class _FundEscrowButtonState extends ConsumerState<_FundEscrowButton> {
  bool _loading = false;
  String? _step; // tracks current step for UX

  Future<void> _startFunding() async {
    final walletNotifier = ref.read(walletProvider.notifier);
    final walletState = ref.read(walletProvider);

    if (walletState.address == null || walletState.address!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect your wallet in Profile first!')),
      );
      return;
    }

    // Balance guard — check spendable balance before even creating the unsigned txn
    // Algorand reserves a minimum balance (0.1 ALGO by default) that cannot be spent;
    // spending total balance causes algod to reject the transaction.
    final totalBalance = walletState.balance?.balanceAlgo ?? 0.0;
    final minReserve = walletState.balance?.minBalance ?? 0.1;
    final spendable = totalBalance - minReserve - 0.001; // 0.001 fee headroom
    if (spendable < widget.bounty.algoAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance: you have ${spendable.toStringAsFixed(4)} ALGO spendable '
            '(total ${totalBalance.toStringAsFixed(4)} minus ${minReserve.toStringAsFixed(4)} min-balance reserve) '
            'but this bounty requires ${widget.bounty.algoAmount} ALGO. '
            'Dispense more ALGO from the Wallet tab.',
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _step = 'Creating transaction...';
    });

    try {
      // Step 1: Create unsigned funding txn
      final fundTxn = await walletNotifier.fundBounty(
        bountyId: widget.bounty.id,
        senderAddress: walletState.address!,
      );

      if (fundTxn == null) {
        if (mounted) {
          setState(() {
            _loading = false;
            _step = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create transaction')),
          );
        }
        return;
      }

      if (!mounted) return;

      // Step 2: Show confirmation dialog with escrow details
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Fund Escrow',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send ${fundTxn.amountAlgo} ALGO to the escrow account?',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Consumer(
                builder: (context, cRef, _) {
                  final inrRate = cRef.watch(algoInrRateProvider).valueOrNull;
                  if (inrRate == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '~${algoToInrString(fundTxn.amountAlgo, inrRate)}',
                      style: TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Escrow Address:',
                      style: TextStyle(color: AppColors.textHint, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${fundTxn.escrowAddress.substring(0, 12)}...${fundTxn.escrowAddress.substring(fundTxn.escrowAddress.length - 8)}',
                      style: const TextStyle(
                        color: AppColors.neonCyan,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Transaction ID:',
                      style: TextStyle(color: AppColors.textHint, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${fundTxn.txnId.substring(0, 12)}...',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Note: In a production app, this would open Pera Wallet for signing. For the hackathon demo, we simulate the funding.',
                style: TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'Confirm & Fund',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        if (mounted)
          setState(() {
            _loading = false;
            _step = null;
          });
        return;
      }

      // Step 3: For demo — submit the transaction
      // In production, this would use Pera Wallet WalletConnect
      if (mounted) setState(() => _step = 'Submitting to blockchain...');

      final result = await walletNotifier.submitTransaction(
        signedTxn: fundTxn.unsignedTxn, // In demo, server handles it
        bountyId: widget.bounty.id,
      );

      if (mounted) {
        setState(() {
          _loading = false;
          _step = null;
        });
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Escrow funded! TX: ${result.txId.substring(0, 12)}...',
              ),
              backgroundColor: AppColors.neonGreen.withValues(alpha: 0.9),
            ),
          );
          widget.onFunded();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction failed. Check wallet balance.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _step = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonOrange.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _startFunding,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.account_balance_wallet, size: 18),
            label: Consumer(
              builder: (context, cRef, _) {
                final inrRate = cRef.watch(algoInrRateProvider).valueOrNull;
                final algoStr = formatAlgo(widget.bounty.algoAmount);
                final label =
                    _step ??
                    (inrRate != null
                        ? 'Fund Escrow ($algoStr · ${algoToInrString(widget.bounty.algoAmount, inrRate)})'
                        : 'Fund Escrow ($algoStr)');
                return Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonOrange,
              foregroundColor: Colors.black,
              disabledBackgroundColor: AppColors.neonOrange.withValues(
                alpha: 0.4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  ESCROW STATUS BADGE
// ═════════════════════════════════════════════════════════════

class _EscrowStatusBadge extends StatelessWidget {
  final BountyModel bounty;
  final bool isOwner;

  const _EscrowStatusBadge({required this.bounty, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final status = bounty.escrowStatus;
    final Color color;
    final IconData icon;
    final String label;

    switch (status) {
      case 'FUNDED':
        color = AppColors.neonGreen;
        icon = Icons.lock;
        label = 'Escrow Funded';
        break;
      case 'RELEASED':
        color = AppColors.neonCyan;
        icon = Icons.check_circle;
        label = 'Payment Released';
        break;
      case 'REFUNDED':
        color = AppColors.neonOrange;
        icon = Icons.replay;
        label = 'Escrow Refunded';
        break;
      default: // UNFUNDED
        color = AppColors.textHint;
        icon = Icons.lock_open;
        label = isOwner ? 'Not Funded — Fund This Bounty' : 'Not Funded Yet';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (bounty.escrowTxId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'TX: ${bounty.escrowTxId!.substring(0, 8)}...',
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
