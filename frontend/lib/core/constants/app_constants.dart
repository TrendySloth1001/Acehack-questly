/// App-wide constants – single source of truth.
class AppConstants {
  AppConstants._();

  // ── App Identity ──────────────────────────────────────────
  static const String appName = 'Questly';
  static const String packageName = 'com.questly.questly';

  // ── API ───────────────────────────────────────────────────
  static const String baseUrl = 'https://apk.anskservices.com/api/v1';
  static const String prodBaseUrl = 'https://api.questly.app/api/v1';

  // ── OAuth ─────────────────────────────────────────────────
  /// Web client ID — used as serverClientId so the backend can verify idTokens.
  static const String googleClientId =
      '867248310005-de067c6hffq9h12anrj6qsunef2madjr.apps.googleusercontent.com';

  /// Android client ID — registered in google-services.json (native config).
  static const String googleAndroidClientId =
      '867248310005-967lcq56ji1h8jmkr4mmjne0h2tusu1s.apps.googleusercontent.com';
  static const String googleCallbackUrl =
      'https://apk.anskservices.com/api/v1/auth/google/callback';

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
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 90);

  // ── Animation ─────────────────────────────────────────────
  static const Duration defaultAnimDuration = Duration(milliseconds: 300);
  static const Duration fastAnimDuration = Duration(milliseconds: 150);
}
