import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:questly/features/algorand/data/algorand_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/algo_inr.dart';
import '../../../bounty/presentation/providers/bounty_provider.dart';
import '../../data/wallet_mode_provider.dart';
import '../../data/pera_wallet_service.dart';
import '../providers/wallet_provider.dart';
import '../widgets/pera_onboarding_sheet.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _dispensing = false;
  bool _generating = false;
  bool _connectingPera = false;
  // Prevents repeated auto-loads in build(); only triggers once per lifecycle.
  bool _didInit = false;
  final _peraAddressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initial load is deferred to the first frame so providers are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoad());
  }

  void _initialLoad() {
    if (!mounted || _didInit) return;
    _didInit = true;
    final isPera = ref.read(walletModeProvider) == WalletMode.pera;
    isPera
        ? ref.read(walletProvider.notifier).loadPera()
        : ref.read(walletProvider.notifier).load();
  }

  @override
  void dispose() {
    _peraAddressCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _connectPera() async {
    final address = _peraAddressCtrl.text.trim();
    if (!PeraWalletService.instance.isValidAlgorandAddress(address)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Algorand address — must be 58 characters'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _connectingPera = true);
    await PeraWalletService.instance.saveAddress(address);
    await ref.read(walletProvider.notifier).setWallet(address);
    if (mounted) {
      setState(() => _connectingPera = false);
      _peraAddressCtrl.clear();
    }
  }

  Future<void> _disconnectPera() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Disconnect Wallet?',
          style: TextStyle(
            color: AppColors.fore,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'This removes the saved address from this device. Your funds stay safe — you can always reconnect with the same address.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Disconnect',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await PeraWalletService.instance.disconnect();
    // Reset wallet state. Do NOT trigger a reload — we are intentionally
    // disconnected. The connect screen will show via the hasWallet == false path.
    ref.read(walletProvider.notifier).reset();
    // Clear the text field so they start fresh.
    if (mounted) {
      _peraAddressCtrl.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final walletMode = ref.watch(walletModeProvider);
    final myBounties = ref.watch(myBountiesProvider);
    final rateAsync = ref.watch(algoInrRateProvider);
    final inrRate = rateAsync.valueOrNull ?? 15.0;
    final isPera = walletMode == WalletMode.pera;

    // When mode changes, reset init flag and reload for the new mode.
    ref.listen<WalletMode>(walletModeProvider, (prev, next) {
      if (prev == next) return;
      ref.read(walletProvider.notifier).reset();
      setState(() => _didInit = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _didInit = true;
        final isPera = next == WalletMode.pera;
        isPera
            ? ref.read(walletProvider.notifier).loadPera()
            : ref.read(walletProvider.notifier).load();
      });
    });

    final hasWallet = wallet.address != null && wallet.address!.isNotEmpty;
    final balance = wallet.balance?.balanceAlgo ?? 0.0;

    double totalEscrowed = 0;
    double totalEarnings = 0;
    for (final b in myBounties.bounties) {
      if (b.escrowStatus == 'FUNDED') totalEscrowed += b.algoAmount;
      if (b.status == 'COMPLETED') totalEarnings += b.algoAmount;
    }

    Widget body;
    if (wallet.isLoading || _generating || _connectingPera) {
      body = const Center(
        child: CircularProgressIndicator(color: AppColors.neonCyan, strokeWidth: 1.5),
      );
    } else if (!hasWallet) {
      body = isPera ? _buildPeraConnect() : _buildNoWallet();
    } else {
      body = _buildDashboard(
        wallet: wallet,
        balance: balance,
        totalEscrowed: totalEscrowed,
        totalEarnings: totalEarnings,
        inrRate: inrRate,
        isPera: isPera,
      );
    }

    // Wrap scrollable bodies in RefreshIndicator; non-scrollable ones (loading,
    // empty custodial) are plain.
    final canRefresh = hasWallet && !wallet.isLoading;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: canRefresh
            ? RefreshIndicator(
                color: AppColors.neonCyan,
                backgroundColor: AppColors.surface,
                onRefresh: () async {
                  await ref.read(walletProvider.notifier).refreshBalance();
                  await ref.read(walletProvider.notifier).loadTransactions();
                },
                child: body,
              )
            : body,
      ),
    );
  }

  // ── Pera Wallet connect screen ─────────────────────────────

  Widget _buildPeraConnect() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.neonCyan,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect Pera Wallet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Your keys, your crypto',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Setup guide banner
          GestureDetector(
            onTap: () => PeraOnboardingSheet.show(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.brand.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.rocket_launch_rounded,
                    color: AppColors.brand,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'New to Pera? Follow the setup guide →',
                      style: TextStyle(
                        color: AppColors.brand,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Address input label
          const Text(
            'Paste or scan your Algorand address',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Address field row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _peraAddressCtrl,
                  style: const TextStyle(
                    color: AppColors.fore,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'XXXXX...XXXXX (58 characters)',
                    hintStyle: TextStyle(
                      color: AppColors.textHint.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.neonCyan,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.paste_rounded, size: 18),
                      color: AppColors.textHint,
                      tooltip: 'Paste',
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        if (data?.text != null) {
                          setState(() {
                            _peraAddressCtrl.text = data!.text!.trim();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // QR Scan button
              GestureDetector(
                onTap: _scanQrAddress,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.neonCyan,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Connect button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _connectPera,
              icon: const Icon(Icons.link_rounded, size: 18),
              label: const Text('Connect Wallet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonCyan,
                foregroundColor: AppColors.fore,
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

          const SizedBox(height: 12),

          // Open Pera button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: PeraWalletService.instance.openPeraWallet,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Open Pera Wallet App'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanQrAddress() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (result != null && mounted) {
      setState(() => _peraAddressCtrl.text = result);
    }
  }

  // ── No wallet placeholder (custodial) ──────────────────────

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
                  foregroundColor: AppColors.fore,
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
    required bool isPera,
  }) {
    final minReserve = wallet.balance?.minBalance ?? 0.1;
    final spendable = (balance - minReserve).clamp(0.0, double.infinity);
    final address = wallet.address!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // ── Header ──────────────────────────────────
        Row(
          children: [
            const Expanded(
              child: Text(
                'Wallet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (isPera)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.launch_rounded,
                      size: 12,
                      color: AppColors.neonCyan,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Pera',
                      style: TextStyle(
                        color: AppColors.neonCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
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

        // ── Faucet (custodial only) / Pera actions ──
        if (isPera)
          _PeraActionsRow(
            address: address,
            onDisconnect: _disconnectPera,
          )
        else
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
// Pera Actions Row (replaces faucet when in Pera mode)
// ═══════════════════════════════════════════════════════════════

class _PeraActionsRow extends StatelessWidget {
  final String address;
  final VoidCallback onDisconnect;

  const _PeraActionsRow({
    required this.address,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Open in Pera
        GestureDetector(
          onTap: () => PeraWalletService.instance.openPeraWallet(),
          child: Row(
            children: [
              Icon(
                Icons.open_in_new_rounded,
                color: AppColors.neonCyan.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 10),
              const Text(
                'Open Pera Wallet',
                style: TextStyle(
                  color: AppColors.neonCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // View on Explorer
        GestureDetector(
          onTap: () => PeraWalletService.instance.openAddress(address),
          child: Row(
            children: [
              Icon(
                Icons.explore_outlined,
                color: AppColors.neonGreen.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 10),
              const Text(
                'View On Explorer',
                style: TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Disconnect
        GestureDetector(
          onTap: onDisconnect,
          child: Row(
            children: [
              Icon(
                Icons.link_off_rounded,
                color: AppColors.error.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 10),
              const Text(
                'Disconnect Wallet',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
        const SizedBox(height: 12),
        // Hackathon Proof Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.neonCyan.withValues(alpha: 0.1),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.neonCyan,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hackathon Proof',
                      style: TextStyle(
                        color: AppColors.neonCyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'The logs below are real on-chain transfers on the Algorand Testnet. Raw TxIDs are exposed to verify blockchain integration.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

          // Description + time + raw tx id
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
                const SizedBox(height: 4),
                // Raw transaction ID for hackathon proof
                GestureDetector(
                  onTap: () {
                    if (txn.txId == null) return;
                    Clipboard.setData(ClipboardData(text: txn.txId!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction ID copied!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.code_rounded,
                        size: 12,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          txn.txId ?? 'Pending...',
                          style: TextStyle(
                            color: txn.txId != null
                                ? AppColors.neonCyan
                                : AppColors.textHint,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
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
