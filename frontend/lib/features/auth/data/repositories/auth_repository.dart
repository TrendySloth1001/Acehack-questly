import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  AuthRepository(this._remote, this._storage);

  Future<UserModel> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _remote.register(
      email: email,
      password: password,
      name: name,
    );
    final tokens = AuthTokensModel.fromJson(response['data']);
    await _persistTokens(tokens);
    return me();
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _remote.login(email: email, password: password);
    final tokens = AuthTokensModel.fromJson(response['data']);
    await _persistTokens(tokens);
    return me();
  }

  Future<void> loginWithOAuthTokens(
    String accessToken,
    String refreshToken,
  ) async {
    await _storage.write(AppConstants.accessTokenKey, accessToken);
    await _storage.write(AppConstants.refreshTokenKey, refreshToken);
  }

  Future<UserModel> me() async {
    final response = await _remote.me();
    return UserModel.fromJson(response['data']);
  }

  Future<void> logout() async {
    final refreshToken = await _storage.read(AppConstants.refreshTokenKey);
    try {
      await _remote.logout(refreshToken);
    } catch (_) {
      // Best-effort server logout
    }
    await _storage.deleteAll();
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(AppConstants.accessTokenKey);
    return token != null;
  }

  // ── Private ──────────────────────────────────────────────

  Future<void> _persistTokens(AuthTokensModel tokens) async {
    await _storage.write(AppConstants.accessTokenKey, tokens.accessToken);
    await _storage.write(AppConstants.refreshTokenKey, tokens.refreshToken);
  }
}
