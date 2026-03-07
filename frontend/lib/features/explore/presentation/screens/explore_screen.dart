import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Explore tab — discover quests, people, and projects.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'explore 🔍',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    TextFormField(
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'search quests, people, skills...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.neonCyan,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Category chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _CategoryChip(
                          label: '🔥 Trending',
                          color: AppColors.neonOrange,
                        ),
                        _CategoryChip(
                          label: '🆕 New',
                          color: AppColors.neonGreen,
                        ),
                        _CategoryChip(
                          label: '👥 People',
                          color: AppColors.neonCyan,
                        ),
                        _CategoryChip(
                          label: '🏆 Top Rated',
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.explore_outlined,
                      size: 48,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'explore page coming soon — stay tuned 🤫',
                      style: TextStyle(color: AppColors.textHint, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
