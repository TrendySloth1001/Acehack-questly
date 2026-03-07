import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/auth_callback_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_name_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_skills_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_location_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/quest/presentation/screens/quest_list_screen.dart';
import '../../features/quest/presentation/screens/quest_detail_screen.dart';
import '../../features/quest/presentation/screens/create_quest_screen.dart';

/// Route name constants.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String authCallback = '/auth/callback';

  // Onboarding
  static const String onboardingName = '/onboarding/name';
  static const String onboardingReason = '/onboarding/reason';
  static const String onboardingSkills = '/onboarding/skills';
  static const String onboardingLocation = '/onboarding/location';

  // Main tabs
  static const String home = '/home';
  static const String explore = '/explore';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // Quests
  static const String quests = '/home/quests';
  static const String questDetail = '/home/quests/:id';
  static const String createQuest = '/home/quests/new';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      // ── Auth ────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.authCallback,
        name: 'authCallback',
        builder: (context, state) => AuthCallbackScreen(
          accessToken: state.uri.queryParameters['access_token'],
          refreshToken: state.uri.queryParameters['refresh_token'],
        ),
      ),

      // ── Onboarding ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboardingName,
        name: 'onboardingName',
        builder: (context, state) => const OnboardingNameScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingReason,
        name: 'onboardingReason',
        builder: (context, state) => const OnboardingReasonScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingSkills,
        name: 'onboardingSkills',
        builder: (context, state) => const OnboardingSkillsScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingLocation,
        name: 'onboardingLocation',
        builder: (context, state) => const OnboardingLocationScreen(),
      ),

      // ── Main Shell ──────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeDashboardScreen(),
            routes: [
              GoRoute(
                path: 'quests',
                name: 'quests',
                builder: (context, state) => const QuestListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'createQuest',
                    builder: (context, state) => const CreateQuestScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'questDetail',
                    builder: (context, state) =>
                        QuestDetailScreen(questId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.explore,
            name: 'explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          '404 — page not found 💀',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    ),
  );
});
