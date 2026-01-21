import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Conditional import for web-only JavaScript access
// On web: imports app_config_web.dart with dart:js
// On non-web: imports app_config_stub.dart (empty implementation)
import 'app_config_stub.dart' if (dart.library.html) 'app_config_web.dart'
    as web_config;

class AppConfig {
  // Cache the API base URL to avoid repeated JavaScript access
  static String? _cachedApiBaseUrl;

  /// Safely get API URL from window.__APP_CONFIG__ without throwing
  /// Only works on web platform
  static String? _getApiUrlFromWindow() {
    if (!kIsWeb) {
      return null;
    }

    try {
      // Use platform-specific implementation
      return web_config.getApiUrlFromWindow();
    } catch (e) {
      // Any error - completely safe, just return null
      assert(() {
        debugPrint('⚠️ Error accessing JavaScript context: $e');
        return true;
      }());
      return null;
    }
  }

  /// Validate that URL is properly formatted
  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static String get apiBaseUrl {
    // Return cached value if available
    if (_cachedApiBaseUrl != null) {
      return _cachedApiBaseUrl!;
    }

    String? url;

    // Priority 1: For web - Try runtime config from window object (production)
    if (kIsWeb) {
      url = _getApiUrlFromWindow();
      if (url != null && url.isNotEmpty && _isValidUrl(url)) {
        _cachedApiBaseUrl = url;
        assert(() {
          debugPrint('✅ Using runtime config API_BASE_URL: $url');
          return true;
        }());
        return url;
      }
    }

    // Priority 2: Try compile-time environment variable (build-time config)
    try {
      final envVar = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: '',
      );
      if (envVar.isNotEmpty && _isValidUrl(envVar)) {
        _cachedApiBaseUrl = envVar;
        assert(() {
          debugPrint('✅ Using build-time config API_BASE_URL: $envVar');
          return true;
        }());
        return envVar;
      }
    } catch (e) {
      // Silently continue
    }

    // Priority 3: Try .env file (development)
    try {
      final dotenvUrl = dotenv.env['API_BASE_URL'];
      if (dotenvUrl != null && dotenvUrl.isNotEmpty && _isValidUrl(dotenvUrl)) {
        _cachedApiBaseUrl = dotenvUrl;
        assert(() {
          debugPrint('✅ Using .env file API_BASE_URL: $dotenvUrl');
          return true;
        }());
        return dotenvUrl;
      }
    } catch (e) {
      // Silently continue
    }

    // Priority 4: Smart fallback based on current hostname (web only)
    String fallbackUrl;
    if (kIsWeb) {
      // Try to auto-detect production URL from current hostname
      try {
        // Access window.location.hostname via JavaScript interop
        final hostname = web_config.getCurrentHostname();
        if (hostname != null &&
            hostname.isNotEmpty &&
            hostname != 'localhost' &&
            hostname != '127.0.0.1') {
          // Production domain detected - use same domain for API
          // Assume API is at same domain with /api/v1 path
          final protocol = hostname.contains('localhost') ? 'http' : 'https';
          fallbackUrl = '$protocol://$hostname/api/v1';
          assert(() {
            debugPrint(
                '✅ Auto-detected production API URL from hostname: $fallbackUrl');
            return true;
          }());
        } else {
          // Development - use Docker service name or localhost
          fallbackUrl = 'http://backend:3000/api/v1';
        }
      } catch (e) {
        // Fallback to Docker service name if hostname detection fails
        fallbackUrl = 'http://backend:3000/api/v1';
        assert(() {
          debugPrint(
              '⚠️ Could not detect hostname, using Docker service fallback: $e');
          return true;
        }());
      }
    } else {
      // Mobile: Use localhost (for development) or require explicit config
      // In production, mobile apps should use compile-time or .env config
      fallbackUrl = 'http://localhost:3000/api/v1';
    }

    _cachedApiBaseUrl = fallbackUrl;
    assert(() {
      debugPrint('⚠️ Using fallback API_BASE_URL: $fallbackUrl');
      if (kIsWeb) {
        debugPrint(
            '⚠️ config.js was not loaded - check docker-entrypoint.sh and API_BASE_URL env var');
        debugPrint(
            '⚠️ For production, set API_BASE_URL in docker-compose.yml or .env file');
      } else {
        debugPrint(
            '⚠️ Mobile: Set API_BASE_URL via --dart-define or .env file');
      }
      return true;
    }());
    return fallbackUrl;
  }

  static const String appName = 'TENX';

  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration syncInterval = Duration(minutes: 5);
}
