import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';

/// Auth interceptor – attaches JWT and handles 401 with token refresh.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorageService _storage;
  bool _isRefreshing = false;

  AuthInterceptor(this._dio, this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken =
            await _storage.read(AppConstants.refreshTokenKey);
        if (refreshToken == null) {
          _isRefreshing = false;
          return handler.next(err);
        }

        final response = await Dio(BaseOptions(
          baseUrl: AppConstants.baseUrl,
        )).post('/auth/refresh', data: {'refreshToken': refreshToken});

        final newAccess = response.data['data']['accessToken'] as String;
        final newRefresh = response.data['data']['refreshToken'] as String;

        await _storage.write(AppConstants.accessTokenKey, newAccess);
        await _storage.write(AppConstants.refreshTokenKey, newRefresh);

        // Retry original request
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccess';
        final retryResponse = await _dio.fetch(opts);
        _isRefreshing = false;
        return handler.resolve(retryResponse);
      } catch (_) {
        _isRefreshing = false;
        await _storage.deleteAll();
      }
    }
    handler.next(err);
  }
}

/// Singleton Dio provider.
final dioProvider = Provider<Dio>((ref) {
  final storage = ref.read(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(dio, storage),
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ),
  ]);

  return dio;
});
