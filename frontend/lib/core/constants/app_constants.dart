/// App-wide constants – single source of truth.
class AppConstants {
  AppConstants._();

  // ── App Identity ──────────────────────────────────────────
  static const String appName = 'Questly';
  static const String packageName = 'com.questly.questly';

  // ── API ───────────────────────────────────────────────────
  static const String baseUrl = 'https://qjhcp0ph-3000.inc1.devtunnels.ms/api/v1';
  static const String prodBaseUrl = 'https://api.questly.app/api/v1';

  // ── OAuth ─────────────────────────────────────────────────
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
  static const String googleCallbackUrl =
      'http://localhost:4000/api/v1/auth/google/callback';
  static const String githubCallbackUrl =
      'http://localhost:4000/api/v1/auth/github/callback';

  // ── Storage Keys ──────────────────────────────────────────
  static const String accessTokenKey = 'questly_access_token';
  static const String refreshTokenKey = 'questly_refresh_token';
  static const String userKey = 'questly_user';
  static const String themeKey = 'questly_theme';
  static const String onboardingKey = 'questly_onboarded';

  // ── Pagination ────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ── Upload ────────────────────────────────────────────────
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
  ];

  // ── Timeouts ──────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ── Animation ─────────────────────────────────────────────
  static const Duration defaultAnimDuration = Duration(milliseconds: 300);
  static const Duration fastAnimDuration = Duration(milliseconds: 150);
}
