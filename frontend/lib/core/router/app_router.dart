import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/auth_callback_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/quest/presentation/screens/quest_list_screen.dart';
import '../../features/quest/presentation/screens/quest_detail_screen.dart';
import '../../features/quest/presentation/screens/create_quest_screen.dart';

/// Route name constants.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String authCallback = '/auth/callback';
  static const String home = '/home';
  static const String quests = '/quests';
  static const String questDetail = '/quests/:id';
  static const String createQuest = '/quests/new';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.authCallback,
        name: 'authCallback',
        builder: (context, state) => AuthCallbackScreen(
          accessToken: state.uri.queryParameters['access_token'],
          refreshToken: state.uri.queryParameters['refresh_token'],
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const QuestListScreen(),
          ),
          GoRoute(
            path: AppRoutes.quests,
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
                builder: (context, state) => QuestDetailScreen(
                  questId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
