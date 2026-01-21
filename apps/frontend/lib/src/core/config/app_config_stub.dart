/// Stub implementation for non-web platforms
/// This file is used when dart.library.html is not available (mobile/desktop)
/// Returns null since JavaScript context is not available on these platforms

/// Stub function that returns null (non-web platforms don't have window.__APP_CONFIG__)
String? getApiUrlFromWindow() {
  // Not available on non-web platforms
  return null;
}

/// Stub function for hostname (non-web platforms)
String? getCurrentHostname() {
  // Not available on non-web platforms
  return null;
}
