import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_widgets.dart';

/// Step 1 — Full name & phone number.
class OnboardingNameScreen extends ConsumerStatefulWidget {
  const OnboardingNameScreen({super.key});

  @override
  ConsumerState<OnboardingNameScreen> createState() =>
      _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends ConsumerState<OnboardingNameScreen> {
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const StepIndicator(current: 1, total: 4),
                      const SizedBox(height: 32),
                      Text(
                        'What should we\ncall you?',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your name and number so your crew can find you.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 28),
                      NeonTextField(
                        controller: _nameC,
                        label: 'Full Name',
                        hint: 'e.g. Arjun Mehra',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      NeonTextField(
                        controller: _phoneC,
                        label: 'Phone Number',
                        hint: '+91 98765 43210',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const Spacer(),
                      NeonButton(
                        label: 'Continue',
                        onPressed: () {
                          if (_nameC.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Name cannot be empty'),
                              ),
                            );
                            return;
                          }
                          ref
                              .read(onboardingProvider.notifier)
                              .setFullName(_nameC.text.trim());
                          ref
                              .read(onboardingProvider.notifier)
                              .setPhone(_phoneC.text.trim());
                          context.go(AppRoutes.onboardingReason);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Step 2 — Why are you here?
class OnboardingReasonScreen extends ConsumerStatefulWidget {
  const OnboardingReasonScreen({super.key});

  @override
  ConsumerState<OnboardingReasonScreen> createState() =>
      _OnboardingReasonScreenState();
}

class _OnboardingReasonScreenState
    extends ConsumerState<OnboardingReasonScreen> {
  final _reasonC = TextEditingController();

  static const _reasons = [
    'Build side projects',
    'Find a co-founder',
    'Learn new skills',
    'Hackathons & events',
    'Internships & gigs',
    'Just exploring',
  ];

  String? _selected;

  @override
  void dispose() {
    _reasonC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const StepIndicator(current: 2, total: 4),
                      const SizedBox(height: 32),
                      Text(
                        'What brings\nyou here?',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pick one or type your own reason.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _reasons.map((r) {
                          final isSelected = _selected == r;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selected = r;
                              _reasonC.clear();
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryDim
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 1.2 : 0.5,
                                ),
                              ),
                              child: Text(
                                r,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      NeonTextField(
                        controller: _reasonC,
                        label: 'Or type your reason',
                        hint: 'I want to...',
                        icon: Icons.edit_outlined,
                        onChanged: (_) => setState(() => _selected = null),
                      ),
                      const Spacer(),
                      NeonButton(
                        label: 'Continue',
                        onPressed: () {
                          final reason = _selected ?? _reasonC.text.trim();
                          if (reason.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pick a reason or type one'),
                              ),
                            );
                            return;
                          }
                          ref
                              .read(onboardingProvider.notifier)
                              .setReason(reason);
                          context.go(AppRoutes.onboardingSkills);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
