import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Status colors for ticket management (light mode)
class _StatusColorsLight {
  _StatusColorsLight._();
  // Use primary color for "New" status to make it prominent
  static Color statusNew(Color primaryColor) => primaryColor;
  static const Color statusInProgress = AppColors.warning;
  static const Color statusResolved = AppColors.success;
  static const Color statusError = AppColors.destructive;
}

/// Status colors for ticket management (dark mode)
class _StatusColorsDark {
  _StatusColorsDark._();
  // Use lighter tint of primary for "New" status in dark mode
  static Color statusNew(Color primaryColor) {
    final hsl = HSLColor.fromColor(primaryColor);
    return hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();
  }

  static const Color statusInProgress = Color(0xFFFBBF24); // Amber-400
  static const Color statusResolved = Color(0xFF34D399); // Emerald-400
  static const Color statusError = Color(0xFFF87171); // Red-400
}

/// Custom ThemeExtension for Ticket Status Colors.
/// This allows semantic status colors to be accessed via Theme.of(context)
/// without polluting the standard ColorScheme.
@immutable
class TicketStatusTheme extends ThemeExtension<TicketStatusTheme> {
  const TicketStatusTheme({
    required this.statusNew,
    required this.statusInProgress,
    required this.statusResolved,
    required this.statusError,
  });

  final Color statusNew;
  final Color statusInProgress;
  final Color statusResolved;
  final Color statusError;

  @override
  TicketStatusTheme copyWith({
    Color? statusNew,
    Color? statusInProgress,
    Color? statusResolved,
    Color? statusError,
  }) {
    return TicketStatusTheme(
      statusNew: statusNew ?? this.statusNew,
      statusInProgress: statusInProgress ?? this.statusInProgress,
      statusResolved: statusResolved ?? this.statusResolved,
      statusError: statusError ?? this.statusError,
    );
  }

  @override
  TicketStatusTheme lerp(ThemeExtension<TicketStatusTheme>? other, double t) {
    if (other is! TicketStatusTheme) {
      return this;
    }

    return TicketStatusTheme(
      statusNew: Color.lerp(statusNew, other.statusNew, t)!,
      statusInProgress:
          Color.lerp(statusInProgress, other.statusInProgress, t)!,
      statusResolved: Color.lerp(statusResolved, other.statusResolved, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
    );
  }
}

/// Production-ready theming system for Helpdesk/Ticket Management application.
/// This is the single source of truth for all styling - widgets must use
/// Theme.of(context) and never hard-code colors or styles.
class AppTheme {
  AppTheme._();

  /// Helper function to darken a color (e.g., for AppBar background)
  static Color _darkenColor(Color color, [double amount = 0.3]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Helper function to lighten a color (e.g., for button overlays)
  static Color _lightenColor(Color color, [double amount = 0.15]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Light theme configuration with optional custom primary color
  static ThemeData lightTheme({Color? primaryColor}) {
    final effectivePrimary = primaryColor ?? AppColors.primary;
    final appBarColor =
        _darkenColor(effectivePrimary, 0.25); // Darker shade for AppBar
    // Compute overlay color for button hover/pressed states (lightened primary)
    final buttonOverlayColor = _lightenColor(effectivePrimary, 0.15);
    final colorScheme = ColorScheme.light(
      primary: effectivePrimary,
      onPrimary: AppColors.primaryForeground,
      primaryContainer: AppColors.accent,
      onPrimaryContainer: AppColors.accentForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      secondaryContainer: AppColors.muted,
      onSecondaryContainer: AppColors.mutedForeground,
      tertiary: AppColors.accent,
      onTertiary: AppColors.accentForeground,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
      surface: AppColors.card,
      onSurface: AppColors.cardForeground,
      surfaceContainerHighest: AppColors.muted,
      onSurfaceVariant: AppColors.mutedForeground,
      outline: AppColors.border,
      outlineVariant: AppColors.border.withValues(alpha: 0.5),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.foreground,
      onInverseSurface: AppColors.background,
      inversePrimary: effectivePrimary,
      brightness: Brightness.light,
    );

    final textTheme = AppTypography.buildTextTheme(Brightness.light);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      typography: Typography.material2021(),
      textTheme: textTheme,
      fontFamily: 'Inter', // Set Inter as default font
      extensions: <ThemeExtension<dynamic>>[
        TicketStatusTheme(
          statusNew: _StatusColorsLight.statusNew(effectivePrimary),
          statusInProgress: _StatusColorsLight.statusInProgress,
          statusResolved: _StatusColorsLight.statusResolved,
          statusError: _StatusColorsLight.statusError,
        ),
      ],
      // AppBar Theme - Use darker shade of primary color for better contrast
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: appBarColor,
        foregroundColor: colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: false, // Left align all titles
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onPrimary, // White icons
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onPrimary, // White icons for actions
        ),
      ),
      // Card Theme - No border radius with border color
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
        color: colorScheme.surface,
      ),
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.input, // White background inside text boxes
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        // Use floatingLabelBehavior to keep label above (not floating)
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        // Label style (when used as labelText)
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        // Helper text style
        helperStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
        ),
        // Icon colors - use #2b2a00 for input icons
        prefixIconColor: AppColors.inputIcon,
        suffixIconColor: AppColors.inputIcon,
      ),
      // Elevated Button Theme - Height 48, full width, Primary background, button typography
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return colorScheme.onSurface.withValues(alpha: 0.12);
              }
              return colorScheme.primary;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return colorScheme.onSurface.withValues(alpha: 0.38);
              }
              return colorScheme.onPrimary;
            },
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          minimumSize: WidgetStateProperty.all(
            const Size(double.infinity, 48),
          ), // Full width, height 48
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.focused)) {
                return buttonOverlayColor;
              }
              return null;
            },
          ),
          textStyle: WidgetStateProperty.all(
            textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
      // Filled Button Theme - Same as Elevated for consistency
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(colorScheme.primary),
          foregroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          minimumSize: WidgetStateProperty.all(
            const Size(double.infinity, 48),
          ), // Full width, height 48
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.focused)) {
                return buttonOverlayColor;
              }
              return null;
            },
          ),
          textStyle: WidgetStateProperty.all(
            textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          side: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        deleteIconColor: colorScheme.onSurfaceVariant,
        disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.12),
        thickness: 1,
        space: 1,
      ),
      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        minLeadingWidth: 40,
        iconColor: colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// Dark theme configuration with optional custom primary color
  static ThemeData darkTheme({Color? primaryColor}) {
    final effectivePrimary = primaryColor ?? AppColors.primary;
    final appBarColor =
        _darkenColor(effectivePrimary, 0.25); // Darker shade for AppBar
    // Compute overlay color for button hover/pressed states (lightened primary)
    final buttonOverlayColor = _lightenColor(effectivePrimary, 0.15);
    final colorScheme = ColorScheme.dark(
      primary: effectivePrimary,
      onPrimary: AppColors.primaryForeground,
      primaryContainer: AppColors.accentForeground,
      onPrimaryContainer: AppColors.accent,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      secondaryContainer: AppColors.muted,
      onSecondaryContainer: AppColors.mutedForeground,
      tertiary: AppColors.accent,
      onTertiary: AppColors.accentForeground,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
      surface: const Color(0xFF1E1E1E),
      onSurface: const Color(0xFFFFFFFF), // Pure white for maximum text visibility and contrast
      surfaceContainerHighest: const Color(0xFF2D2D2D),
      onSurfaceVariant: const Color(0xFFE5E7EB), // Lighter gray-200 for better label visibility
      outline: const Color(0xFF9CA3AF), // Lighter gray-400 for better border visibility
      outlineVariant: const Color(0xFF6B7280),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFFE5E7EB),
      onInverseSurface: const Color(0xFF111827),
      inversePrimary: effectivePrimary,
      brightness: Brightness.dark,
    );

    final textTheme = AppTypography.buildTextTheme(Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212), // Dark background
      typography: Typography.material2021(),
      textTheme: textTheme,
      fontFamily: 'Inter', // Set Inter as default font
      extensions: <ThemeExtension<dynamic>>[
        TicketStatusTheme(
          statusNew: _StatusColorsDark.statusNew(effectivePrimary),
          statusInProgress: _StatusColorsDark.statusInProgress,
          statusResolved: _StatusColorsDark.statusResolved,
          statusError: _StatusColorsDark.statusError,
        ),
      ],
      // AppBar Theme - Use darker shade of primary color for better contrast
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: appBarColor,
        foregroundColor: colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: false, // Left align all titles
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onPrimary, // White icons
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onPrimary, // White icons for actions
        ),
      ),
      // Card Theme - No border radius with border color
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
        color: colorScheme.surface,
      ),
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D), // Dark background for input fields in dark mode
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        // Use floatingLabelBehavior to keep label above (not floating)
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        // Label style (when used as labelText) - Use lighter color for visibility
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface, // Use onSurface (white) for maximum contrast
          fontWeight: FontWeight.w600, // Make labels bolder for better readability
        ),
        // Helper text style - Use lighter color for visibility
        helperStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9), // Higher opacity for better visibility
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
        ),
        // Icon colors - Use white for maximum visibility in dark mode
        prefixIconColor: colorScheme.onSurface,
        suffixIconColor: colorScheme.onSurface,
      ),
      // Elevated Button Theme - Height 48, full width, Primary background, button typography
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return colorScheme.onSurface.withValues(alpha: 0.12);
              }
              return colorScheme.primary;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return colorScheme.onSurface.withValues(alpha: 0.38);
              }
              return colorScheme.onPrimary;
            },
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          ),
          minimumSize: WidgetStateProperty.all(
            const Size(double.infinity, 48),
          ), // Full width, height 48
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.focused)) {
                return buttonOverlayColor;
              }
              return null;
            },
          ),
          textStyle: WidgetStateProperty.all(
            textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            ),
          ),
        ),
      ),
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(colorScheme.primary),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          minimumSize: WidgetStateProperty.all(const Size(64, 48)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          side: WidgetStateProperty.all(
            BorderSide(
              color: colorScheme.outline,
              width: 1,
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.focused)) {
                return buttonOverlayColor;
              }
              return null;
            },
          ),
          textStyle: WidgetStateProperty.all(
            textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(colorScheme.primary),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          minimumSize: WidgetStateProperty.all(const Size(64, 48)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.focused)) {
                return buttonOverlayColor;
              }
              return null;
            },
          ),
          textStyle: WidgetStateProperty.all(
            textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          minimumSize: WidgetStateProperty.all(const Size(64, 48)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.focused)) {
                return buttonOverlayColor;
              }
              return null;
            },
          ),
          textStyle: WidgetStateProperty.all(
            textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        deleteIconColor: colorScheme.onSurfaceVariant,
        disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.12),
        thickness: 1,
        space: 1,
      ),
      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface, // Use white for icons for better visibility in dark mode
        size: 24,
      ),
      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        minLeadingWidth: 40,
        iconColor: colorScheme.onSurface, // Use white for list tile icons
      ),
      // Dropdown Button Theme - Normal font weight for all dropdowns
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface, // Ensure dropdown text is visible
        ),
      ),
      // Text Selection Theme - Ensure selected text is visible in dark mode
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withValues(alpha: 0.3),
        selectionHandleColor: colorScheme.primary,
      ),
      // Dialog Theme - Consistent styling for all dialogs
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        backgroundColor: colorScheme.surface,
        elevation: 8,
        alignment: Alignment.center,
        iconColor: colorScheme.primary,
      ),
    );
  }
}

/// Extension method to easily access TicketStatusTheme from context
extension TicketStatusThemeExtension on BuildContext {
  TicketStatusTheme get ticketStatusTheme =>
      Theme.of(this).extension<TicketStatusTheme>() ??
      TicketStatusTheme(
        statusNew: _StatusColorsLight.statusNew(AppColors.primary),
        statusInProgress: _StatusColorsLight.statusInProgress,
        statusResolved: _StatusColorsLight.statusResolved,
        statusError: _StatusColorsLight.statusError,
      );
}
