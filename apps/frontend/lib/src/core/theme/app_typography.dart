import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized font size constants - Single source of truth for all font sizes
/// Update these values to change font sizes across the entire application
class AppFontSizes {
  AppFontSizes._();

  // Display sizes (rarely used)
  static const double displayLarge = 57;
  static const double displayMedium = 45;
  static const double displaySmall = 36;

  // Headline sizes
  static const double headlineLarge = 32;
  static const double headlineMedium = 28;
  static const double headlineSmall = 24;

  // Title/Header sizes
  static const double titleLarge = 22; // Page headers (desktop)
  static const double titleLargeMobile = 20; // Page headers (mobile)
  static const double titleMedium = 20; // Section headers (desktop)
  static const double titleMediumMobile = 18; // Section headers (mobile)
  static const double titleSmall = 16; // Card headers
  static const double titleExtraSmall = 18; // Alternative card header size

  // Body sizes
  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;

  // Label sizes
  static const double labelLarge = 14; // Button text
  static const double labelMedium = 13; // Form labels, captions
  static const double labelSmall = 11; // Small labels, helper text

  // Special sizes
  static const double caption = 12; // Captions, timestamps
  static const double overline = 10; // Overline text
  static const double tiny = 10; // Very small text (e.g., badges)
}

/// Centralized typography system using Inter font.
/// All text styles must come from this file - no inline TextStyles allowed.
class AppTypography {
  AppTypography._();

  /// Responsive header styles - automatically adapts to screen size
  /// Use these throughout the application for consistent headers

  /// Page Header - For AppBar titles and main page titles
  /// Mobile: 20px, Desktop: 22px, Semi-bold
  static TextStyle pageHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize:
          isMobile ? AppFontSizes.titleLargeMobile : AppFontSizes.titleLarge,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
      letterSpacing: 0,
      height: 1.27,
    );
  }

  /// Section Header - For dashboard sections and major content sections
  /// Mobile: 18px, Desktop: 20px, Semi-bold
  static TextStyle sectionHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize:
          isMobile ? AppFontSizes.titleMediumMobile : AppFontSizes.titleMedium,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
      letterSpacing: 0,
      height: 1.33,
    );
  }

  /// Card Header - For card titles and content section headers
  /// Mobile: 16px, Desktop: 16px, Semi-bold
  static TextStyle cardHeader(BuildContext context) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: AppFontSizes.titleSmall,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
      letterSpacing: 0.15,
      height: 1.5,
    );
  }

  /// Subsection Header - For nested sections and smaller headers
  /// Mobile: 14px, Desktop: 15px, Medium
  static TextStyle subsectionHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: isMobile ? AppFontSizes.bodyMedium : AppFontSizes.bodyLarge,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurface,
      letterSpacing: 0.15,
      height: 1.43,
    );
  }

  /// Headline text style - 22px, semi-bold
  static TextStyle headline(BuildContext context) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: AppFontSizes.titleLarge,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Title text style - 16px, medium
  static TextStyle title(BuildContext context) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: AppFontSizes.titleSmall,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Body text style - 14px, regular
  static TextStyle body(BuildContext context) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: AppFontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Label text style - 13px, medium
  static TextStyle label(BuildContext context) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: AppFontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Button text style - 14px, semi-bold
  static TextStyle button(BuildContext context) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: AppFontSizes.labelLarge,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }

  /// Caption text style - 12px, regular
  static TextStyle caption(BuildContext context) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: AppFontSizes.caption,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  /// Small text style - 11px, medium
  static TextStyle small(BuildContext context) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: AppFontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  /// Tiny text style - 10px, regular
  static TextStyle tiny(BuildContext context) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: AppFontSizes.tiny,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  /// Builds comprehensive TextTheme using Inter font
  static TextTheme buildTextTheme(Brightness brightness) {
    final baseTextStyle = TextStyle(
      fontFamily: 'Inter',
      color: brightness == Brightness.light
          ? AppColors.foreground
          : const Color(0xFFFFFFFF), // Pure white for maximum visibility in dark mode
    );

    return TextTheme(
      // Display Styles
      displayLarge: baseTextStyle.copyWith(
        fontSize: AppFontSizes.displayLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: baseTextStyle.copyWith(
        fontSize: AppFontSizes.displayMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: baseTextStyle.copyWith(
        fontSize: AppFontSizes.displaySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
      ),
      // Headline Styles
      headlineLarge: baseTextStyle.copyWith(
        fontSize: AppFontSizes.headlineLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: baseTextStyle.copyWith(
        fontSize: AppFontSizes.headlineMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: baseTextStyle.copyWith(
        fontSize: AppFontSizes.headlineSmall,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.33,
      ),
      // Title Styles - Standardized for consistent headers
      // Page Header: 22px semi-bold (desktop), 20px (mobile)
      titleLarge: baseTextStyle.copyWith(
        fontSize: AppFontSizes.titleLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
      ),
      // Section Header: 20px semi-bold (desktop), 18px (mobile)
      titleMedium: baseTextStyle.copyWith(
        fontSize: AppFontSizes.titleMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
      ),
      // Card Header: 16px semi-bold
      titleSmall: baseTextStyle.copyWith(
        fontSize: AppFontSizes.titleSmall,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      // Body Styles (using body spec: 14px regular)
      bodyLarge: baseTextStyle.copyWith(
        fontSize: AppFontSizes.bodyLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: baseTextStyle.copyWith(
        fontSize: AppFontSizes.bodyMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: baseTextStyle.copyWith(
        fontSize: AppFontSizes.bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      // Label Styles (using label spec: 13px medium)
      labelLarge: baseTextStyle.copyWith(
        fontSize: AppFontSizes.labelLarge,
        fontWeight: FontWeight.w600, // Button: 14px semi-bold
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: baseTextStyle.copyWith(
        fontSize: AppFontSizes.labelMedium,
        fontWeight: FontWeight.w500, // Label: 13px medium
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: baseTextStyle.copyWith(
        fontSize: AppFontSizes.labelSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }
}
