import 'dart:js' as js;
import 'package:flutter/foundation.dart' show debugPrint;

/// Web-specific implementation for accessing window.__APP_CONFIG__
/// This file is only imported on web platforms (dart.library.html)

/// Get current hostname from window.location
String? getCurrentHostname() {
  try {
    final window = js.context['window'];
    if (window != null) {
      final location = (window as js.JsObject)['location'];
      if (location != null) {
        final hostname = (location as js.JsObject)['hostname'];
        if (hostname != null) {
          return hostname.toString();
        }
      }
    }
  } catch (e) {
    assert(() {
      debugPrint('⚠️ Error getting hostname: $e');
      return true;
    }());
  }
  return null;
}

/// Get API URL from window.__APP_CONFIG__
String? getApiUrlFromWindow() {
  try {
    // Try accessing window.__APP_CONFIG__ via js.context
    try {
      if (js.context.hasProperty('__APP_CONFIG__')) {
        final windowConfig = js.context['__APP_CONFIG__'];
        if (windowConfig != null) {
          try {
            final config = windowConfig as js.JsObject;
            final apiUrl = config['API_BASE_URL'];
            if (apiUrl != null) {
              final url = apiUrl.toString();
              if (url.isNotEmpty) {
                assert(() {
                  debugPrint('✅ Using runtime config API_BASE_URL: $url');
                  return true;
                }());
                return url;
              }
            }
          } catch (e) {
            // Type cast or property access failed
            assert(() {
              debugPrint('⚠️ Error reading API_BASE_URL from config: $e');
              return true;
            }());
          }
        }
      }
    } catch (e) {
      // hasProperty or property access failed
      assert(() {
        debugPrint('⚠️ Error accessing __APP_CONFIG__: $e');
        return true;
      }());
    }
    
    // Try alternative method: access via window object
    try {
      final window = js.context['window'];
      if (window != null) {
        try {
          final appConfig = (window as js.JsObject)['__APP_CONFIG__'];
          if (appConfig != null) {
            try {
              final config = appConfig as js.JsObject;
              final apiUrl = config['API_BASE_URL'];
              if (apiUrl != null) {
                final url = apiUrl.toString();
                if (url.isNotEmpty) {
                  assert(() {
                    debugPrint('✅ Using runtime config API_BASE_URL (via window): $url');
                    return true;
                  }());
                  return url;
                }
              }
            } catch (e) {
              // Type cast or property access failed
              assert(() {
                debugPrint('⚠️ Error reading API_BASE_URL from window config: $e');
                return true;
              }());
            }
          }
        } catch (e) {
          // Type cast failed
          assert(() {
            debugPrint('⚠️ Error accessing window.__APP_CONFIG__: $e');
            return true;
          }());
        }
      }
    } catch (e) {
      // Window access failed
      assert(() {
        debugPrint('⚠️ Error accessing window object: $e');
        return true;
      }());
    }
  } catch (e) {
    // Any other error - completely safe, just return null
    assert(() {
      debugPrint('⚠️ Unexpected error accessing JavaScript context: $e');
      return true;
    }());
  }
  
  return null;
}
