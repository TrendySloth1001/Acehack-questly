import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

// ── Repository provider ─────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.read(dioProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepository(AuthRemoteDataSource(dio), storage);
});

// ── Auth state ──────────────────────────────────────────────

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final bool isLoading;
  final bool needsOnboarding;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.isLoading = false,
    this.needsOnboarding = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool? isLoading,
    bool? needsOnboarding,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      needsOnboarding: needsOnboarding ?? this.needsOnboarding,
    );
  }
}

// ── Auth notifier ───────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final SecureStorageService _storage;

  AuthNotifier(this._repo, this._storage) : super(const AuthState()) {
    _initSession();
  }

  /// On app launch: show cached user instantly, verify JWT in background.
  Future<void> _initSession() async {
    final hasToken = await _repo.isAuthenticated();
    if (!hasToken) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    // Load cached user immediately
    final cachedJson = await _storage.read(AppConstants.userKey);
    UserModel? cachedUser;
    if (cachedJson != null) {
      try {
        cachedUser = UserModel.fromJson(
          json.decode(cachedJson) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    final needsOnboarding = cachedUser == null || !cachedUser.onboarded;

    if (cachedUser != null) {
      // Sync local key from cached user
      if (cachedUser.onboarded) {
        await _storage.write(AppConstants.onboardingKey, 'true');
      }
      state = AuthState(
        status: AuthStatus.authenticated,
        user: cachedUser,
        needsOnboarding: needsOnboarding,
      );
    }

    // Background verify + refresh user object
    try {
      final freshUser = await _repo.me();
      await _cacheUser(freshUser);
      // Use server's onboarded flag as source of truth
      if (freshUser.onboarded) {
        await _storage.write(AppConstants.onboardingKey, 'true');
      }
      state = AuthState(
        status: AuthStatus.authenticated,
        user: freshUser,
        needsOnboarding: !freshUser.onboarded,
      );
    } catch (_) {
      // Token invalid → if no cached user, force logout
      if (cachedUser == null) {
        await _repo.logout();
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
      // else keep showing cached data (offline-friendly)
    }
  }

  /// Native Google Sign-In → send idToken to backend
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final googleSignIn = GoogleSignIn(
        // serverClientId = Web OAuth client ID — required on Android to get idToken
        serverClientId: AppConstants.googleClientId,
        scopes: ['email', 'profile'],
      );
      final account = await googleSignIn.signIn();
      if (account == null) {
        state = state.copyWith(isLoading: false);
        return; // user cancelled
      }

      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to get Google token',
        );
        return;
      }

      // Send to backend
      final user = await _repo.loginWithGoogle(idToken);
      await _cacheUser(user);

      // Use server's onboarded flag as source of truth
      if (user.onboarded) {
        await _storage.write(AppConstants.onboardingKey, 'true');
      }

      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        needsOnboarding: !user.onboarded,
      );
    } catch (e) {
      final msg = _friendlyError(e);
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  /// Called after OAuth callback with tokens
  Future<void> loginWithOAuthTokens(
    String accessToken,
    String refreshToken,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.loginWithOAuthTokens(accessToken, refreshToken);
      final user = await _repo.me();
      await _cacheUser(user);

      if (user.onboarded) {
        await _storage.write(AppConstants.onboardingKey, 'true');
      }

      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        needsOnboarding: !user.onboarded,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
    }
  }

  /// Save onboarding data to backend, then mark as done locally.
  Future<void> completeOnboarding(Map<String, dynamic> profileData) async {
    try {
      // Include onboarded flag in the payload
      profileData['onboarded'] = true;
      final updatedUser = await _repo.saveOnboardingProfile(profileData);
      await _cacheUser(updatedUser);
      await _storage.write(AppConstants.onboardingKey, 'true');
      state = AuthState(
        status: AuthStatus.authenticated,
        user: updatedUser,
        needsOnboarding: false,
      );
    } catch (e) {
      // Even if backend fails, mark locally so user isn't stuck
      await _storage.write(AppConstants.onboardingKey, 'true');
      state = state.copyWith(needsOnboarding: false, error: _friendlyError(e));
    }
  }

  Future<void> logout() async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {}
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Re-fetch the current user from the server (e.g. after XP changes).
  Future<void> fetchUser() async {
    try {
      final user = await _repo.me();
      await _cacheUser(user);
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<void> _cacheUser(UserModel user) async {
    await _storage.write(AppConstants.userKey, json.encode(user.toJson()));
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    if (s.contains('502') || s.contains('503') || s.contains('bad response')) {
      return 'Server is offline — make sure the backend is running 🛠️';
    }
    if (s.contains('SocketException') ||
        s.contains('network') ||
        s.contains('connection')) {
      return 'No internet connection 📡';
    }
    if (s.contains('sign_in_canceled') || s.contains('sign_in_failed')) {
      return 'Google sign-in cancelled';
    }
    if (s.contains('401') || s.contains('Unauthorized')) {
      return 'Session expired — please sign in again';
    }
    return 'Something went wrong, try again 🤷';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(secureStorageProvider),
  );
});
