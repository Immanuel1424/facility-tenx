import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/data/dto/token_response_dto.dart';

/// Manages token refresh operations to prevent concurrent refresh attempts
class TokenRefreshManager {
  TokenRefreshManager({
    required FlutterSecureStorage storage,
    required Dio dio,
  })  : _storage = storage,
        _dio = dio;

  final FlutterSecureStorage _storage;
  final Dio _dio;

  static const String _refreshTokenKey = 'refresh_token';
  static const String _companyIdKey = 'company_id';
  static const String _accessTokenKey = 'access_token';

  /// Active refresh operation future
  Future<String?>? _refreshFuture;

  /// Attempts to refresh the access token
  /// Returns the new access token if successful, null otherwise
  /// Prevents concurrent refresh attempts by reusing the same future
  Future<String?> refreshToken() async {
    // If a refresh is already in progress, wait for it
    if (_refreshFuture != null) {
      try {
        return await _refreshFuture;
      } catch (_) {
        // If the previous refresh failed, try again
        _refreshFuture = null;
      }
    }

    // Check if we have a refresh token
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final companyId = await _storage.read(key: _companyIdKey);
    
    if (refreshToken == null || companyId == null) {
      return null;
    }

    // Create a new refresh future
    _refreshFuture = _performRefresh(refreshToken, companyId);
    try {
      final newToken = await _refreshFuture;
      return newToken;
    } finally {
      // Clear the future after completion (success or failure)
      _refreshFuture = null;
    }
  }

  /// Performs the actual token refresh
  /// Uses a separate Dio instance without interceptors to avoid infinite loops
  Future<String?> _performRefresh(String refreshToken, String companyId) async {
    try {
      // Create a temporary Dio instance without interceptors for refresh call
      // This prevents the refresh call itself from triggering another refresh
      final refreshDio = Dio(_dio.options);
      
      // Add company-id header manually
      refreshDio.options.headers['x-company-id'] = companyId;
      refreshDio.options.headers['Content-Type'] = 'application/json';
      refreshDio.options.headers['Accept'] = 'application/json';

      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.data == null) {
        await _clearTokens();
        return null;
      }

      // Handle wrapped response format
      dynamic data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        data = data['data'];
      }

      // Normalize response (handle both camelCase and snake_case)
      final normalizedData = <String, dynamic>{
        'accessToken':
            data['accessToken'] ?? data['access_token'] ?? data['token'],
        'refreshToken': data['refreshToken'] ?? data['refresh_token'],
        'expiresIn': data['expiresIn'] ?? data['expires_in'] ?? 900,
        'tokenType': data['tokenType'] ?? data['token_type'] ?? 'Bearer',
      };

      if (normalizedData['accessToken'] == null ||
          normalizedData['refreshToken'] == null) {
        await _clearTokens();
        return null;
      }

      final tokenResponse = TokenResponseDto.fromJson(normalizedData);

      // Store new tokens
      await _storage.write(key: _accessTokenKey, value: tokenResponse.accessToken);
      await _storage.write(
        key: _refreshTokenKey,
        value: tokenResponse.refreshToken,
      );

      return tokenResponse.accessToken;
    } catch (e) {
      // Refresh failed - clear tokens
      await _clearTokens();
      return null;
    }
  }

  /// Clears all stored tokens
  Future<void> _clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    // Note: We don't clear company_id as it's needed for re-login
  }

  /// Checks if a refresh is currently in progress
  bool get isRefreshing => _refreshFuture != null;

  /// Resets the refresh manager (useful for testing or logout)
  void reset() {
    _refreshFuture = null;
  }
}

