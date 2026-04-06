import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<(RequestOptions, ErrorInterceptorHandler)> _queue = [];

  AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Don't retry auth endpoints to avoid loops
    if (err.requestOptions.path.contains('/auth/')) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _queue.add((err.requestOptions, handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        await _storage.clearTokens();
        handler.next(err);
        return;
      }

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      final newAccessToken = response.data['access_token'] as String;
      final newRefreshToken = response.data['refresh_token'] as String;

      await _storage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // Retry queued requests
      for (final (options, queuedHandler) in _queue) {
        options.headers['Authorization'] = 'Bearer $newAccessToken';
        try {
          final retried = await _dio.fetch(options);
          queuedHandler.resolve(retried);
        } catch (e) {
          queuedHandler.next(err);
        }
      }
      _queue.clear();

      // Retry the original request
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retried = await _dio.fetch(err.requestOptions);
      handler.resolve(retried);
    } catch (_) {
      await _storage.clearTokens();
      for (final (_, queuedHandler) in _queue) {
        queuedHandler.next(err);
      }
      _queue.clear();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
