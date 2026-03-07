import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/skill_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_widgets.dart';

/// Step 3 — Skills chip selector with search & custom add.
class OnboardingSkillsScreen extends ConsumerStatefulWidget {
  const OnboardingSkillsScreen({super.key});

  @override
  ConsumerState<OnboardingSkillsScreen> createState() =>
      _OnboardingSkillsScreenState();
}

class _OnboardingSkillsScreenState
    extends ConsumerState<OnboardingSkillsScreen> {
  final _searchC = TextEditingController();
  final _customC = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchC.dispose();
    _customC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingProvider);
    final allSkills = [
      ...SkillConstants.skills,
      ...data.skills.where((s) => !SkillConstants.skills.contains(s)),
    ];
    final filtered = _query.isEmpty
        ? allSkills
        : allSkills
              .where((s) => s.toLowerCase().contains(_query.toLowerCase()))
              .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const StepIndicator(current: 3, total: 4),
              const SizedBox(height: 32),
              Text(
                'Pick your skills',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap to select. Can\'t find yours? Add it below.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 18),
              // Search
              TextFormField(
                controller: _searchC,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search skills...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchC.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              // Selected count
              if (data.skills.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${data.skills.length} selected',
                    style: const TextStyle(
                      color: AppColors.neonGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              // Chip list
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: filtered.map((skill) {
                      final isSelected = data.skills.contains(skill);
                      return FilterChip(
                        label: Text(skill),
                        selected: isSelected,
                        onSelected: (_) => ref
                            .read(onboardingProvider.notifier)
                            .toggleSkill(skill),
                        selectedColor: AppColors.chipSelected,
                        backgroundColor: AppColors.chipBackground,
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.chipBorder,
                          width: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Custom skill add
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _customC,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Add a custom skill...',
                        prefixIcon: Icon(
                          Icons.add_circle_outline,
                          color: AppColors.neonGreen,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      final skill = _customC.text.trim();
                      if (skill.isNotEmpty) {
                        ref
                            .read(onboardingProvider.notifier)
                            .addCustomSkill(skill);
                        _customC.clear();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.neonGreenDim,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.neonGreen,
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.neonGreen,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              NeonButton(
                label: 'Continue',
                onPressed: data.skills.isEmpty
                    ? null
                    : () => context.go(AppRoutes.onboardingLocation),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
