import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// Common PlutoGrid configuration for consistent styling across the app
class PlutoGridConfig {
  PlutoGridConfig._();

  /// Creates a standardized PlutoGridConfiguration with consistent styling
  static PlutoGridConfiguration buildConfiguration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PlutoGridConfiguration(
      columnSize: const PlutoGridColumnSizeConfig(
        resizeMode: PlutoResizeMode.normal,
      ),
      style: PlutoGridStyleConfig(
        enableRowColorAnimation: true,
        rowHeight: 56,
        columnHeight: 52,
        activatedColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
        activatedBorderColor: theme.colorScheme.primary,
        gridBorderColor: Colors.transparent,
        borderColor: theme.colorScheme.outline.withOpacity(0.1),
        gridBackgroundColor: theme.colorScheme.surface,
        rowColor: theme.colorScheme.surface,
        evenRowColor: isDark
            ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.15)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        oddRowColor: theme.colorScheme.surface,
        columnTextStyle: theme.textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.3,
          color: theme.colorScheme.onSurface,
        ),
        cellTextStyle: theme.textTheme.bodyMedium!.copyWith(
          fontSize: 13,
        ),
        iconColor: theme.colorScheme.onSurfaceVariant,
        enableColumnBorderVertical: true,
        enableColumnBorderHorizontal: false,
        checkedColor: theme.colorScheme.primary,
        menuBackgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
      scrollbar: const PlutoGridScrollbarConfig(
        isAlwaysShown: true,
        scrollbarThickness: 10,
        scrollbarRadius: Radius.circular(10),
      ),
    );
  }

  /// Creates a standardized ThemeData for PlutoGrid
  static ThemeData buildGridTheme(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Theme.of(context).copyWith(
      // Text theme for search box and other text inputs
      textTheme: theme.textTheme.copyWith(
        bodyMedium: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface, // Use theme color for dark mode visibility
        ),
        bodyLarge: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface, // Use theme color for dark mode visibility
        ),
        bodySmall: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant, // Use theme color for dark mode visibility
        ),
        labelLarge: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface, // Use theme color for dark mode visibility
        ),
        labelMedium: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant, // Use theme color for dark mode visibility
        ),
        labelSmall: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant, // Use theme color for dark mode visibility
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        // Fill color for input fields (search box)
        fillColor: colorScheme.surfaceContainerHighest, // Use theme color for dark mode
        filled: true,
        // Hint text color
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7), // Use theme color for dark mode
        ),
        // Label text color
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant, // Use theme color for dark mode
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: colorScheme.primary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        isDense: false,
      ),
    );
  }
}

