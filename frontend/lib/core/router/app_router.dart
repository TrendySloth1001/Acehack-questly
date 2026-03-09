import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
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
import '../../features/algorand/presentation/screens/wallet_screen.dart';
import '../../features/quest/presentation/screens/quest_list_screen.dart';
import '../../features/quest/presentation/screens/quest_detail_screen.dart';
import '../../features/quest/presentation/screens/create_quest_screen.dart';
import '../../features/bounty/presentation/screens/create_bounty_screen.dart';
import '../../features/bounty/presentation/screens/bounty_detail_screen.dart';
import '../../features/bounty/presentation/screens/submit_proof_screen.dart';
import '../../features/profile/presentation/screens/my_bounties_screen.dart';
import '../../features/gamification/presentation/screens/leaderboard_screen.dart';
import '../../features/gamification/presentation/screens/xp_rules_screen.dart';
import '../../features/admin/presentation/screens/upload_apk_screen.dart';

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
  static const String wallet = '/wallet';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String myBounties = '/profile/bounties';

  // Leaderboard
  static const String leaderboard = '/home/leaderboard';
  static const String xpRules = '/home/xp-rules';

  // Admin
  static const String uploadApk = '/home/upload-apk';

  // Quests
  static const String quests = '/home/quests';
  static const String questDetail = '/home/quests/:id';
  static const String createQuest = '/home/quests/new';

  // Bounties
  static const String createBounty = '/home/bounty/new';
  static const String bountyDetail = '/home/bounty/:id';
  static const String submitProof = '/home/bounty/:id/submit-proof';
}

/// Bridges Riverpod auth state changes into GoRouter.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(authProvider, (prev, next) => notifyListeners());
  }
}

final _routerNotifierProvider = Provider((ref) => _RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final status = authState.status;
      final loc = state.matchedLocation;

      // Still initialising — don't redirect yet
      if (status == AuthStatus.unknown) return null;

      final isOnAuthRoute =
          loc == AppRoutes.login ||
          loc == AppRoutes.authCallback ||
          loc.startsWith('/onboarding');

      if (status == AuthStatus.unauthenticated) {
        return isOnAuthRoute ? null : AppRoutes.login;
      }

      // Authenticated — redirect away from login
      if (status == AuthStatus.authenticated) {
        if (authState.needsOnboarding) {
          // Already on an onboarding screen → stay
          if (loc.startsWith('/onboarding')) return null;
          // On login or anywhere else → go to onboarding
          return AppRoutes.onboardingName;
        }
        // Fully onboarded — bounce off login & onboarding screens
        if (loc == AppRoutes.login || loc.startsWith('/onboarding')) {
          return AppRoutes.home;
        }
        return null;
      }

      return null;
    },
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
              GoRoute(
                path: 'bounty/new',
                name: 'createBounty',
                builder: (context, state) => const CreateBountyScreen(),
              ),
              GoRoute(
                path: 'bounty/:id',
                name: 'bountyDetail',
                builder: (context, state) =>
                    BountyDetailScreen(bountyId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'submit-proof',
                    name: 'submitProof',
                    builder: (context, state) => SubmitProofScreen(
                      bountyId: state.pathParameters['id']!,
                      claimId: state.uri.queryParameters['claimId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'leaderboard',
                name: 'leaderboard',
                builder: (context, state) => const LeaderboardScreen(),
              ),
              GoRoute(
                path: 'xp-rules',
                name: 'xpRules',
                builder: (context, state) => const XpRulesScreen(),
              ),
              GoRoute(
                path: 'upload-apk',
                name: 'uploadApk',
                builder: (context, state) => const UploadApkScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.explore,
            name: 'Explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: AppRoutes.wallet,
            name: 'wallet',
            builder: (context, state) => const WalletScreen(),
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
            routes: [
              GoRoute(
                path: 'bounties',
                name: 'myBounties',
                builder: (context, state) => const MyBountiesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          '404 — page not found 💀',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
      ),
    ),
  );
});
