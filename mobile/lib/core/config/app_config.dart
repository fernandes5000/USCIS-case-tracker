class AppConfig {
  // Backend base URL — update for production
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.50.51:8080',
  );

  static const String apiVersion = '/api';

  static String get apiBaseUrl => '$baseUrl$apiVersion';

  // Token storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // Cache TTL for UI
  static const Duration statusCacheDuration = Duration(minutes: 5);
}
