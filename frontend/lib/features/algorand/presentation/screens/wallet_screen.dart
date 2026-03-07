import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/algo_inr.dart';
import '../../../bounty/presentation/providers/bounty_provider.dart';
import '../providers/wallet_provider.dart';

/// Full wallet / banking dashboard — balance, escrow, earnings, faucet.
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _dispensing = false;
  bool _generating = false;

  Future<void> _generate() async {
    setState(() => _generating = true);
    await ref.read(walletProvider.notifier).generateWallet();
    if (mounted) setState(() => _generating = false);
  }

  Future<void> _dispense() async {
    setState(() => _dispensing = true);
    final ok = await ref.read(walletProvider.notifier).dispense();
    if (mounted) {
      setState(() => _dispensing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(ok ? '10 ALGO dispensed!' : 'Dispense failed — is algod running?'),
          backgroundColor: ok ? AppColors.neonGreen : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final myBounties = ref.watch(myBountiesProvider);
    final rateAsync = ref.watch(algoInrRateProvider);
    final inrRate = rateAsync.valueOrNull ?? 15.0;

    // Load wallet on first build
    if (!wallet.isLoading && wallet.address == null && wallet.error == null) {
      Future.microtask(() => ref.read(walletProvider.notifier).load());
    }

    final hasWallet = wallet.address != null && wallet.address!.isNotEmpty;
    final balance = wallet.balance?.balanceAlgo ?? 0.0;
    final escrowBalance = wallet.escrowInfo?.balanceAlgo ?? 0.0;

    // Calculate total escrowed in user's bounties
    double totalEscrowed = 0;
    double totalEarnings = 0;
    for (final b in myBounties.bounties) {
      if (b.escrowStatus == 'FUNDED') {
        totalEscrowed += b.algoAmount;
      }
      if (b.status == 'COMPLETED') {
        totalEarnings += b.algoAmount;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.neonCyan,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            await ref.read(walletProvider.notifier).refreshBalance();
          },
          child: wallet.isLoading || _generating
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.neonCyan,
                    strokeWidth: 1.5,
                  ),
                )
              : !hasWallet
                  ? _buildNoWallet()
                  : _buildDashboard(
                      wallet: wallet,
                      balance: balance,
                      escrowBalance: escrowBalance,
                      totalEscrowed: totalEscrowed,
                      totalEarnings: totalEarnings,
                      inrRate: inrRate,
                    ),
        ),
      ),
    );
  }

  Widget _buildNoWallet() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.neonCyan.withValues(alpha: 0.3),
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Wallet Yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a wallet to start sending\nand receiving ALGO',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                child: const Text('Generate Wallet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard({
    required WalletState wallet,
    required double balance,
    required double escrowBalance,
    required double totalEscrowed,
    required double totalEarnings,
    required double inrRate,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        // ── Title row ─────────────────────────────────
        Row(
          children: [
            const Text(
              'Wallet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => ref.read(walletProvider.notifier).refreshBalance(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // ── Main balance card ─────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.neonCyan.withValues(alpha: 0.08),
                AppColors.card,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AVAILABLE BALANCE',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    balance.toStringAsFixed(2),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      'ALGO',
                      style: TextStyle(
                        color: AppColors.neonCyan,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '~${algoToInrString(balance, inrRate)}',
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              // Address
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: wallet.address!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Address copied'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${wallet.address!.substring(0, 6)}...${wallet.address!.substring(wallet.address!.length - 4)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.copy_rounded,
                      color: AppColors.textHint,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Quick stats row ───────────────────────────
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Escrowed',
                value: totalEscrowed.toStringAsFixed(1),
                unit: 'ALGO',
                inrHint: '~${algoToInrString(totalEscrowed, inrRate)}',
                color: AppColors.neonOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                label: 'Earnings',
                value: totalEarnings.toStringAsFixed(1),
                unit: 'ALGO',
                inrHint: '~${algoToInrString(totalEarnings, inrRate)}',
                color: AppColors.neonGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Escrow pool ───────────────────────────────
        _StatTile(
          label: 'Escrow Pool Balance',
          value: escrowBalance.toStringAsFixed(2),
          unit: 'ALGO',
          inrHint: '~${algoToInrString(escrowBalance, inrRate)}',
          color: AppColors.neonCyan,
        ),
        const SizedBox(height: 12),

        // ── Network badge ─────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonGreen,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Devnet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  wallet.escrowInfo?.network.toUpperCase() ?? 'DEVNET',
                  style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ── Faucet button ─────────────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _dispensing ? null : _dispense,
            icon: _dispensing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.water_drop_rounded, size: 18),
            label: Text(_dispensing ? 'Dispensing...' : 'Get 10 Test ALGO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ── Stat tile ───────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String? inrHint;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
    this.inrHint,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (inrHint != null) ...[
            const SizedBox(height: 4),
            Text(
              inrHint!,
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
