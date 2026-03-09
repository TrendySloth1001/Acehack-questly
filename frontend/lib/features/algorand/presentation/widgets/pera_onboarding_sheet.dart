import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/pera_wallet_service.dart';

// ═══════════════════════════════════════════════════════════════
// QR Scanner Screen — scans Algorand address QR codes
// ═══════════════════════════════════════════════════════════════

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _ctrl = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  bool _scanned = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null) return;

    // Strip 'algorand://' prefix if present
    String address = value;
    if (address.startsWith('algorand://')) {
      address = address.replaceFirst('algorand://', '');
    }
    if (address.length != 58) return;

    _scanned = true;
    _ctrl.stop();
    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Scan Algorand Address',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: _ctrl.toggleTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _ctrl, onDetect: _onDetect),
          // Target overlay
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neonCyan, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Point at your Pera Wallet QR code',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Pera Onboarding Sheet — 4-step frictionless setup walkthrough
// ═══════════════════════════════════════════════════════════════

class PeraOnboardingSheet extends StatefulWidget {
  const PeraOnboardingSheet._();

  /// Show the walkthrough from any screen.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PeraOnboardingSheet._(),
    );
  }

  @override
  State<PeraOnboardingSheet> createState() => _PeraOnboardingSheetState();
}

class _PeraOnboardingSheetState extends State<PeraOnboardingSheet> {
  int _step = 0;
  final _addrCtrl = TextEditingController();

  @override
  void dispose() {
    _addrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepInstall(onNext: _next),
      _StepCreateWallet(onNext: _next),
      _StepCopyAddress(
        controller: _addrCtrl,
        onScan: _scanQr,
        onNext: _connect,
      ),
      _StepDone(address: _addrCtrl.text, onDone: () => Navigator.pop(context)),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Progress dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _step ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _step
                          ? AppColors.neonCyan
                          : i < _step
                          ? AppColors.neonCyan.withValues(alpha: 0.4)
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            // Step content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.3, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(parent: anim, curve: Curves.easeOut),
                        ),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: steps[_step],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() => setState(() => _step = (_step + 1).clamp(0, 3));

  Future<void> _scanQr() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (result != null && mounted) {
      setState(() => _addrCtrl.text = result);
    }
  }

  Future<void> _connect() async {
    final addr = _addrCtrl.text.trim();
    if (addr.length != 58 || !RegExp(r'^[A-Z2-7]+$').hasMatch(addr)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Algorand address — check and try again'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await PeraWalletService.instance.saveAddress(addr);
    _next();
  }
}

// ── Step screens ──────────────────────────────────────────────

class _StepInstall extends StatelessWidget {
  final VoidCallback onNext;
  const _StepInstall({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      icon: Icons.download_rounded,
      iconColor: AppColors.neonGreen,
      stepLabel: 'Step 1 of 4',
      title: 'Install Pera Wallet',
      body:
          'Pera Wallet is the official Algorand wallet app. It lets you '
          'create a secure non-custodial wallet — meaning only you hold the private keys.',
      children: [
        _InfoTile(
          icon: Icons.security_rounded,
          text: 'Your keys, stored only on your device',
        ),
        _InfoTile(
          icon: Icons.public_rounded,
          text: 'Works on Algorand mainnet & testnet',
        ),
        _InfoTile(icon: Icons.qr_code_rounded, text: 'Easy QR address sharing'),
        const SizedBox(height: 24),
        _PrimaryButton(
          label: 'Open Pera on Play Store',
          icon: Icons.open_in_new_rounded,
          onTap: PeraWalletService.instance.openPeraWallet,
        ),
        const SizedBox(height: 12),
        _SecondaryButton(label: 'I already have Pera →', onTap: onNext),
      ],
    );
  }
}

class _StepCreateWallet extends StatelessWidget {
  final VoidCallback onNext;
  const _StepCreateWallet({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      icon: Icons.add_circle_outline_rounded,
      iconColor: AppColors.neonCyan,
      stepLabel: 'Step 2 of 4',
      title: 'Create Your Wallet',
      body:
          'Inside Pera Wallet, create a new account or import an existing one '
          'using your recovery phrase.',
      children: [
        _NumberedStep(number: '1', text: 'Open Pera Wallet on your device'),
        _NumberedStep(
          number: '2',
          text: 'Tap "Create Account" or "Import Account"',
        ),
        _NumberedStep(
          number: '3',
          text: 'Write down and securely store your recovery phrase',
        ),
        _NumberedStep(number: '4', text: 'Complete the setup inside Pera'),
        const SizedBox(height: 24),
        _PrimaryButton(
          label: 'Open Pera Wallet',
          icon: Icons.launch_rounded,
          onTap: PeraWalletService.instance.openPeraWallet,
        ),
        const SizedBox(height: 12),
        _SecondaryButton(label: 'My wallet is ready →', onTap: onNext),
      ],
    );
  }
}

class _StepCopyAddress extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onScan;
  final VoidCallback onNext;

  const _StepCopyAddress({
    required this.controller,
    required this.onScan,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      icon: Icons.link_rounded,
      iconColor: AppColors.neonCyan,
      stepLabel: 'Step 3 of 4',
      title: 'Connect Your Address',
      body:
          'Open Pera Wallet, tap your account, then copy your Algorand address '
          'and paste it below — or scan the QR code directly.',
      children: [
        _NumberedStep(number: '1', text: 'Open Pera → tap your account name'),
        _NumberedStep(number: '2', text: 'Tap "Copy Address" or show QR'),
        _NumberedStep(number: '3', text: 'Paste or scan below'),
        const SizedBox(height: 20),

        // Address field + QR scan
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  color: AppColors.fore,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  hintText: 'Paste Algorand address...',
                  hintStyle: const TextStyle(
                    color: AppColors.textHint,
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
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null)
                        controller.text = data!.text!.trim();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onScan,
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
        _PrimaryButton(
          label: 'Connect Wallet',
          icon: Icons.check_circle_outline_rounded,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _StepDone extends StatelessWidget {
  final String address;
  final VoidCallback onDone;
  const _StepDone({required this.address, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final short = address.length >= 12
        ? '${address.substring(0, 6)}...${address.substring(address.length - 4)}'
        : address;

    return _StepWrapper(
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.neonGreen,
      stepLabel: 'Done!',
      title: 'Wallet Connected',
      body:
          'Your Pera Wallet is now linked to Questly. '
          'Your balance will load on the Wallet tab.',
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.neonGreen.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.neonGreen.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.account_circle_rounded,
                color: AppColors.neonGreen,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  short,
                  style: const TextStyle(
                    color: AppColors.fore,
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
                child: const Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _PrimaryButton(
          label: 'Go to Wallet',
          icon: Icons.wallet_rounded,
          onTap: onDone,
        ),
      ],
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────

class _StepWrapper extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String stepLabel;
  final String title;
  final String body;
  final List<Widget> children;

  const _StepWrapper({
    required this.icon,
    required this.iconColor,
    required this.stepLabel,
    required this.title,
    required this.body,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          stepLabel,
          style: TextStyle(
            color: AppColors.muted.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.fore,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.neonCyan),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  final String number;
  final String text;
  const _NumberedStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCyan,
          foregroundColor: AppColors.fore,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
