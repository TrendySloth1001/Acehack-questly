import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../algorand/data/wallet_mode_provider.dart';
import '../../../algorand/presentation/widgets/pera_onboarding_sheet.dart';

/// Settings tab — upload APK, wallet mode, logout, app info.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletMode = ref.watch(walletModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: AppColors.fore,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // ── Wallet Mode Toggle ────────────────────────
              _WalletModeToggle(
                mode: walletMode,
                onChanged: (mode) {
                  ref.read(walletModeProvider.notifier).setMode(mode);
                },
              ),

              const SizedBox(height: 10),

              // ── Upload APK ────────────────────────────────
              _SettingsTile(
                icon: Icons.cloud_upload_outlined,
                title: 'Upload APK',
                subtitle: 'Upload app release to MinIO',
                accentColor: AppColors.brand,
                onTap: () => context.push(AppRoutes.uploadApk),
              ),

              const SizedBox(height: 10),

              // ── Logout ────────────────────────────────────
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                accentColor: AppColors.error,
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                },
              ),

              const Spacer(),

              Center(
                child: Text(
                  'Questly v1.0.0',
                  style: TextStyle(
                    color: AppColors.muted.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Wallet Mode Toggle
// ═══════════════════════════════════════════════════════════════

class _WalletModeToggle extends StatelessWidget {
  final WalletMode mode;
  final ValueChanged<WalletMode> onChanged;

  const _WalletModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isCustodial = mode == WalletMode.custodial;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.muted.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.neonCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wallet Mode',
                      style: TextStyle(
                        color: AppColors.fore,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isCustodial ? 'Custodial (In-App)' : 'Pera Wallet',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: !isCustodial,
                activeTrackColor: AppColors.neonCyan,
                onChanged: (val) {
                  final newMode = val ? WalletMode.pera : WalletMode.custodial;
                  onChanged(newMode);
                  if (newMode == WalletMode.pera) {
                    PeraOnboardingSheet.show(context);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Mode selector chips
          Row(
            children: [
              Expanded(
                child: _ModeChip(
                  icon: Icons.security_rounded,
                  label: 'Custodial',
                  subtitle: 'App manages keys',
                  selected: isCustodial,
                  onTap: () => onChanged(WalletMode.custodial),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeChip(
                  icon: Icons.launch_rounded,
                  label: 'Pera Wallet',
                  subtitle: 'You own the keys',
                  selected: !isCustodial,
                  onTap: () {
                    onChanged(WalletMode.pera);
                    PeraOnboardingSheet.show(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.neonCyan.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.neonCyan.withValues(alpha: 0.4)
                : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? AppColors.neonCyan : AppColors.muted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? AppColors.neonCyan : AppColors.fore,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.muted.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.fore,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.muted.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
