import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateIndex(context),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.brand.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/explore');
            case 2:
              context.go('/wallet');
            case 3:
              context.go('/profile');
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined, color: AppColors.muted),
            selectedIcon: Icon(Icons.home, color: AppColors.brand,
              shadows: [Shadow(color: AppColors.brand.withValues(alpha: 0.4), blurRadius: 12)]),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined, color: AppColors.muted),
            selectedIcon: Icon(Icons.explore, color: AppColors.brand,
              shadows: [Shadow(color: AppColors.brand.withValues(alpha: 0.4), blurRadius: 12)]),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.muted),
            selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.brand,
              shadows: [Shadow(color: AppColors.brand.withValues(alpha: 0.4), blurRadius: 12)]),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline, color: AppColors.muted),
            selectedIcon: Icon(Icons.person, color: AppColors.brand,
              shadows: [Shadow(color: AppColors.brand.withValues(alpha: 0.4), blurRadius: 12)]),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/wallet')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }
}
