import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  AuthRepository(this._remote, this._storage);

  /// Native Google sign-in: send idToken to backend, get JWT pair back.
  Future<UserModel> loginWithGoogle(String idToken) async {
    final response = await _remote.loginWithGoogleToken(idToken);
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
    } catch (_) {}
    await _storage.deleteAll();
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(AppConstants.accessTokenKey);
    return token != null;
  }

  Future<void> _persistTokens(AuthTokensModel tokens) async {
    await _storage.write(AppConstants.accessTokenKey, tokens.accessToken);
    await _storage.write(AppConstants.refreshTokenKey, tokens.refreshToken);
  }
}
