import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../storage/company_id_storage.dart';
import '../token_refresh_manager.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._storage,
    this._tokenRefreshManager,
    this._dio,
  );

  final FlutterSecureStorage _storage;
  final TokenRefreshManager _tokenRefreshManager;
  final Dio _dio;
  static const String _accessTokenKey = 'access_token';
  static const String _companyIdKey = 'company_id';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _storage.read(key: _accessTokenKey);

    // Check if this is a public endpoint (auth endpoints or public lookup endpoints)
    // Public endpoints don't require authentication
    final isPublicEndpoint = options.path.contains('/auth/') || 
                             options.path.contains('/public/') ||
                             options.path.contains('/health');

    // Check if this is a protected endpoint (not a public endpoint)
    final isProtectedEndpoint = !isPublicEndpoint;

    // Add authorization header if token exists
    // Backend will extract companyId and siteId from JWT token
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      debugPrint('🔐 AuthInterceptor: Added Authorization header for ${options.path}');
    } else {
      debugPrint('⚠️ AuthInterceptor: No access token found in storage for ${options.path}');
      
      // If this is a protected endpoint and we have no token, fail immediately
      // This prevents unnecessary API calls and helps sync AuthBloc state
      if (isProtectedEndpoint) {
        debugPrint('❌ AuthInterceptor: Blocking request to protected endpoint without token');
        handler.reject(
          DioException(
            requestOptions: options,
            error: 'No access token found. Please log in again.',
            type: DioExceptionType.unknown,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              statusMessage: 'Authentication required',
              data: {
                'success': false,
                'message': 'Authentication required',
                'error_code': 'Unauthorized',
              },
            ),
          ),
        );
        return;
      }
      
      // For public endpoints, allow the request to proceed without token
      debugPrint('✅ AuthInterceptor: Allowing public endpoint request without token');
    }

    // Note: x-company-id and x-site-id headers are no longer needed
    // The backend extracts tenant context from JWT token
    // Headers are only used for SYSTEM/SUPER_ADMIN operations

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only attempt refresh on 401 errors
    // Skip refresh for auth endpoints to prevent infinite loops
    if (err.response?.statusCode == 401) {
      final requestPath = err.requestOptions.path;
      
      // Don't attempt refresh for auth endpoints or public endpoints
      // This prevents infinite refresh loops
      if (requestPath.contains('/auth/login') ||
          requestPath.contains('/auth/refresh') ||
          requestPath.contains('/auth/logout') ||
          requestPath.contains('/public/') ||
          requestPath.contains('/health')) {
        // Clear tokens and pass through the error
        await _clearTokens();
        handler.next(err);
        return;
      }

      // Attempt to refresh the token
      debugPrint('🔄 AuthInterceptor: Attempting to refresh token for ${requestPath}');
      final newAccessToken = await _tokenRefreshManager.refreshToken();

      if (newAccessToken != null) {
        debugPrint('✅ AuthInterceptor: Token refresh successful, retrying request');
        // Token refresh successful - retry the original request
        try {
          // Update the authorization header with the new token
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          // Retry the request using the same Dio instance
          // This ensures all interceptors are applied correctly
          final response = await _dio.fetch<dynamic>(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Retry failed - if it's another 401, the refresh token is invalid
          // Clear tokens and pass through the original error
          debugPrint('❌ AuthInterceptor: Retry failed after token refresh: $e');
          if (e is DioException && e.response?.statusCode == 401) {
            await _clearTokens();
            debugPrint('🗑️ AuthInterceptor: Cleared tokens due to invalid refresh token');
          }
          handler.next(err);
          return;
        }
      } else {
        // Token refresh failed - clear tokens and pass through the error
        debugPrint('❌ AuthInterceptor: Token refresh failed - no refresh token or refresh failed');
        debugPrint('🗑️ AuthInterceptor: Clearing tokens and redirecting to login');
        await _clearTokens();
        handler.next(err);
        return;
      }
    }

    // For non-401 errors, pass through
    handler.next(err);
  }

  /// Clears all stored tokens
  Future<void> _clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    // Note: We don't clear company_id as it's needed for re-login
    // Also don't clear refresh_token here - let the refresh manager handle it
  }
}

