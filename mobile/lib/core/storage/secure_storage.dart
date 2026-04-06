import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // In-memory fallback for when Keychain fails (e.g. unsigned macOS debug builds)
  final Map<String, String> _memoryCache = {};

  Future<String?> getAccessToken() => _safeRead(AppConfig.accessTokenKey);
  Future<String?> getRefreshToken() => _safeRead(AppConfig.refreshTokenKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _safeWrite(AppConfig.accessTokenKey, accessToken),
      _safeWrite(AppConfig.refreshTokenKey, refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    _memoryCache.remove(AppConfig.accessTokenKey);
    _memoryCache.remove(AppConfig.refreshTokenKey);
    try {
      await Future.wait([
        _storage.delete(key: AppConfig.accessTokenKey),
        _storage.delete(key: AppConfig.refreshTokenKey),
      ]);
    } catch (_) {}
  }

  Future<String?> _safeRead(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) _memoryCache[key] = value;
      return value ?? _memoryCache[key];
    } catch (e) {
      debugPrint('[Storage] Keychain read failed, using memory: $e');
      return _memoryCache[key];
    }
  }

  Future<void> _safeWrite(String key, String value) async {
    _memoryCache[key] = value;
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('[Storage] Keychain write failed, using memory only: $e');
    }
  }
}
