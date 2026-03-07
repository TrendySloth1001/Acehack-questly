import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  /// Send Google idToken to backend for verification + JWT exchange.
  Future<Map<String, dynamic>> loginWithGoogleToken(String idToken) async {
    final response = await _dio.post(
      ApiEndpoints.googleAuth,
      data: {'idToken': idToken},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout(String? refreshToken) async {
    await _dio.post(
      ApiEndpoints.logout,
      data: refreshToken != null ? {'refreshToken': refreshToken} : null,
    );
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _dio.get(ApiEndpoints.me);
    return response.data as Map<String, dynamic>;
  }

  /// Save onboarding profile to backend.
  Future<Map<String, dynamic>> saveOnboardingProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch(ApiEndpoints.me, data: data);
    return response.data as Map<String, dynamic>;
  }
}
