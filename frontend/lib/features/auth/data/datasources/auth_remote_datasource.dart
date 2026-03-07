import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {'email': email, 'password': password, 'name': name},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
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
}
