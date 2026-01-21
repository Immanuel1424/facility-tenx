import 'dart:convert';

/// Utility class for JWT token operations
class JwtUtils {
  /// Decodes a JWT token and returns the payload as a Map
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      // Decode the payload (second part)
      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Checks if a JWT token is expired
  static bool isTokenExpired(String token) {
    final payload = decodeToken(token);
    if (payload == null) return true;

    final exp = payload['exp'] as int?;
    if (exp == null) return true;

    final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expirationDate);
  }

  /// Gets the expiration date of a JWT token
  static DateTime? getTokenExpiration(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    final exp = payload['exp'] as int?;
    if (exp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }

  /// Extracts user ID from JWT token
  static String? getUserId(String token) {
    final payload = decodeToken(token);
    return payload?['sub'] as String? ?? payload?['userId'] as String?;
  }

  /// Extracts company ID from JWT token
  static String? getCompanyId(String token) {
    final payload = decodeToken(token);
    return payload?['companyId'] as String?;
  }

  /// Extracts company name from JWT token
  static String? getCompanyName(String token) {
    final payload = decodeToken(token);
    return payload?['companyName'] as String?;
  }

  /// Extracts site ID from JWT token
  static String? getSiteId(String token) {
    final payload = decodeToken(token);
    return payload?['siteId'] as String?;
  }

  /// Extracts site code from JWT token
  static String? getSiteCode(String token) {
    final payload = decodeToken(token);
    return payload?['siteCode'] as String?;
  }

  /// Extracts roles from JWT token
  static List<String> getRoles(String token) {
    final payload = decodeToken(token);
    if (payload == null) return [];

    final roles = payload['roles'];
    if (roles is List) {
      return roles.map((e) => e.toString()).toList();
    } else if (roles is String) {
      return [roles];
    }
    return [];
  }

  /// Extracts permissions from JWT token
  static List<String> getPermissions(String token) {
    final payload = decodeToken(token);
    if (payload == null) return [];

    final permissions = payload['permissions'];
    if (permissions is List) {
      return permissions.map((e) => e.toString()).toList();
    } else if (permissions is String) {
      return permissions.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  /// Gets all user information from JWT token
  static Map<String, dynamic>? getUserInfo(String token) {
    return decodeToken(token);
  }
}

