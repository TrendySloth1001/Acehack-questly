import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:questly/features/algorand/data/algorand_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/algo_inr.dart';
import '../../../bounty/presentation/providers/bounty_provider.dart';
import '../providers/wallet_provider.dart';

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
          content: Text(
            ok ? '10 ALGO dispensed!' : 'Dispense failed — is algod running?',
          ),
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

    if (!wallet.isLoading && wallet.address == null && wallet.error == null) {
      Future.microtask(() => ref.read(walletProvider.notifier).load());
    }

    final hasWallet = wallet.address != null && wallet.address!.isNotEmpty;
    final balance = wallet.balance?.balanceAlgo ?? 0.0;

    // User's own escrowed & earnings from their bounties
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
            await ref.read(walletProvider.notifier).loadTransactions();
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
                  totalEscrowed: totalEscrowed,
                  totalEarnings: totalEarnings,
                  inrRate: inrRate,
                ),
        ),
      ),
    );
  }

  // ── No wallet placeholder ──────────────────────────────────

  Widget _buildNoWallet() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.textHint.withValues(alpha: 0.3),
              size: 56,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Wallet Yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a wallet to start sending\nand receiving ALGO',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: const Text('Generate Wallet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main dashboard ─────────────────────────────────────────

  Widget _buildDashboard({
    required WalletState wallet,
    required double balance,
    required double totalEscrowed,
    required double totalEarnings,
    required double inrRate,
  }) {
    final minReserve = wallet.balance?.minBalance ?? 0.1;
    final spendable = (balance - minReserve).clamp(0.0, double.infinity);
    final address = wallet.address!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // ── Header ──────────────────────────────────
        const Text(
          'Wallet',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),

        // ── Balance section ─────────────────────────
        _BalanceSection(
          balance: balance,
          spendable: spendable,
          minReserve: minReserve,
          inrRate: inrRate,
          address: address,
        ),

        const SizedBox(height: 24),
        _divider(),
        const SizedBox(height: 16),

        // ── Stats ───────────────────────────────────
        _StatRow(
          icon: Icons.lock_outline_rounded,
          label: 'Locked in escrow',
          amount: totalEscrowed,
          inrRate: inrRate,
          color: AppColors.neonOrange,
        ),
        const SizedBox(height: 12),
        _StatRow(
          icon: Icons.trending_up_rounded,
          label: 'Total earned',
          amount: totalEarnings,
          inrRate: inrRate,
          color: AppColors.neonGreen,
        ),

        const SizedBox(height: 16),
        _divider(),
        const SizedBox(height: 16),

        // ── Faucet ──────────────────────────────────
        _FaucetRow(dispensing: _dispensing, onTap: _dispense),

        const SizedBox(height: 16),
        _divider(),
        const SizedBox(height: 20),

        // ── Transactions ────────────────────────────
        _TransactionList(
          txns: wallet.transactions,
          isLoading: wallet.txnsLoading,
          inrRate: inrRate,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  static Widget _divider() {
    return Divider(
      color: AppColors.border.withValues(alpha: 0.4),
      height: 1,
      thickness: 0.5,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Balance Section
// ═══════════════════════════════════════════════════════════════

class _BalanceSection extends StatelessWidget {
  final double balance;
  final double spendable;
  final double minReserve;
  final double inrRate;
  final String address;

  const _BalanceSection({
    required this.balance,
    required this.spendable,
    required this.minReserve,
    required this.inrRate,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main balance row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/questly_logo.svg',
              width: 36,
              height: 36,
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      balance.toStringAsFixed(2),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'ALGO',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '~${algoToInrString(balance, inrRate)}',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Spendable info
        Row(
          children: [
            Text(
              'Spendable  ${spendable.toStringAsFixed(4)} ALGO',
              style: const TextStyle(
                color: AppColors.neonGreen,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${minReserve.toStringAsFixed(4)} reserved)',
              style: const TextStyle(color: AppColors.textHint, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Copyable address
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: address));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Address copied'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Row(
            children: [
              Text(
                '${address.substring(0, 6)}...${address.substring(address.length - 4)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.copy_rounded,
                color: AppColors.textHint,
                size: 13,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Stat Row (escrowed / earned)
// ═══════════════════════════════════════════════════════════════

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final double inrRate;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.inrRate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const Spacer(),
        SvgPicture.asset('assets/svg/questly_logo.svg', width: 14, height: 14),
        const SizedBox(width: 5),
        Text(
          amount.toStringAsFixed(1),
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '~${algoToInrString(amount, inrRate)}',
          style: const TextStyle(color: AppColors.textHint, fontSize: 11),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Faucet Row
// ═══════════════════════════════════════════════════════════════

class _FaucetRow extends StatelessWidget {
  final bool dispensing;
  final VoidCallback onTap;

  const _FaucetRow({required this.dispensing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dispensing ? null : onTap,
      child: Row(
        children: [
          Icon(
            Icons.water_drop_outlined,
            color: AppColors.neonCyan.withValues(alpha: 0.7),
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            dispensing ? 'Dispensing...' : 'Get 10 test ALGO',
            style: TextStyle(
              color: dispensing ? AppColors.textHint : AppColors.neonCyan,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (dispensing) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.neonCyan,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Transaction List
// ═══════════════════════════════════════════════════════════════

class _TransactionList extends StatelessWidget {
  final List<WalletTxn> txns;
  final bool isLoading;
  final double inrRate;

  const _TransactionList({
    required this.txns,
    required this.isLoading,
    required this.inrRate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Transactions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (isLoading)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.textHint,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (!isLoading && txns.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No transactions yet',
                style: TextStyle(
                  color: AppColors.textHint.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ...List.generate(txns.length, (i) {
            return Column(
              children: [
                if (i > 0)
                  Divider(
                    color: AppColors.border.withValues(alpha: 0.3),
                    height: 1,
                    thickness: 0.5,
                  ),
                _TxnRow(txn: txns[i], inrRate: inrRate),
              ],
            );
          }),
      ],
    );
  }
}

class _TxnRow extends StatelessWidget {
  final WalletTxn txn;
  final double inrRate;
  const _TxnRow({required this.txn, required this.inrRate});

  @override
  Widget build(BuildContext context) {
    final isDebit = txn.isDebit;
    final color = isDebit ? AppColors.error : AppColors.neonGreen;
    final sign = isDebit ? '-' : '+';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Direction icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDebit
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),

          // Description + time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description,
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
                  _timeAgo(txn.createdAt),
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Amount column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svg/questly_logo.svg',
                    width: 12,
                    height: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$sign${txn.amountAlgo.toStringAsFixed(txn.amountAlgo == txn.amountAlgo.roundToDouble() ? 0 : 2)}',
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '~${algoToInrString(txn.amountAlgo, inrRate)}',
                style: const TextStyle(color: AppColors.textHint, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day}/${d.month}/${d.year}';
  }
}
