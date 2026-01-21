import 'package:flutter/material.dart';
import '../theme/app_typography.dart';

/// Extension methods for accessing theme values
extension ThemeHelpers on BuildContext {
  /// Get the card border radius from the theme
  BorderRadius get cardBorderRadius {
    final cardTheme = Theme.of(this).cardTheme;
    if (cardTheme.shape is RoundedRectangleBorder) {
      final shape = cardTheme.shape as RoundedRectangleBorder;
      final borderRadius = shape.borderRadius;
      if (borderRadius is BorderRadius) {
        return borderRadius;
      }
    }
    // Fallback to theme default (3px)
    return BorderRadius.circular(3);
  }

  /// Get text theme for easy access
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme for easy access
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Helper to get body text style with optional color override
  TextStyle bodyTextStyle({Color? color}) {
    return textTheme.bodyMedium?.copyWith(color: color) ??
        const TextStyle();
  }

  /// Helper to get small text style (12px)
  TextStyle smallTextStyle({Color? color}) {
    return textTheme.bodySmall?.copyWith(color: color) ??
        const TextStyle();
  }

  /// Helper to get caption text style (12px)
  TextStyle captionTextStyle({Color? color}) {
    return textTheme.bodySmall?.copyWith(color: color) ??
        const TextStyle();
  }

  /// Helper to get label text style (13px)
  TextStyle labelTextStyle({Color? color}) {
    return textTheme.labelMedium?.copyWith(color: color) ??
        const TextStyle();
  }
}

