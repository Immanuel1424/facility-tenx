# Header Styles Guide

This guide explains the centralized header styling system used throughout the application.

## Overview

All headers are now defined in a single place and automatically adapt to mobile and desktop screen sizes. This ensures consistent styling and typography across the entire application.

## Header Types

### 1. PageHeader
**Use for:** AppBar titles and main page titles

**Mobile:** 20px, Semi-bold  
**Desktop:** 22px, Semi-bold

```dart
PageHeader('My Page Title')
```

### 2. SectionHeader
**Use for:** Dashboard sections and major content sections

**Mobile:** 18px, Semi-bold  
**Desktop:** 20px, Semi-bold

```dart
SectionHeader(
  'Key Metrics',
  icon: Icons.dashboard,
)
```

### 3. CardHeader
**Use for:** Card titles and content section headers

**Size:** 16px, Semi-bold (same on mobile and desktop)

```dart
CardHeader(
  'Ticket Information',
  icon: Icons.info_outline,
)
```

### 4. SubsectionHeader
**Use for:** Nested sections and smaller headers

**Mobile:** 14px, Medium  
**Desktop:** 15px, Medium

```dart
SubsectionHeader(
  'Details',
  icon: Icons.info,
)
```

## Usage Examples

### Basic Header (No Icon)
```dart
CardHeader('My Card Title')
```

### Header with Icon
```dart
SectionHeader(
  'Analytics',
  icon: Icons.analytics,
)
```

### Header with Custom Color
```dart
CardHeader(
  'Important Section',
  icon: Icons.warning,
  color: Colors.red,
)
```

### Header with Custom Spacing
```dart
SectionHeader(
  'Metrics',
  icon: Icons.dashboard,
  spacing: 12, // Custom spacing between icon and text
)
```

## Direct Style Access

If you need to access the styles directly (for custom widgets), use:

```dart
// Page header style
final style = AppTypography.pageHeader(context);

// Section header style
final style = AppTypography.sectionHeader(context);

// Card header style
final style = AppTypography.cardHeader(context);

// Subsection header style
final style = AppTypography.subsectionHeader(context);
```

## Migration Guide

### Before
```dart
Row(
  children: [
    Icon(Icons.info, size: 18, color: colorScheme.primary),
    const SizedBox(width: 8),
    Text(
      'Card Title',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ],
)
```

### After
```dart
CardHeader(
  'Card Title',
  icon: Icons.info,
)
```

## Benefits

1. **Consistency:** All headers use the same styling system
2. **Responsive:** Automatically adapts to mobile/desktop screen sizes
3. **Maintainable:** Change styles in one place, affects entire app
4. **Type-safe:** Compile-time checks ensure correct usage
5. **Clean Code:** Less boilerplate, more readable

## Font

All headers use **Inter** font family, which is the default font for the entire application.

## Theme Integration

Header styles automatically use colors from the current theme:
- Light mode: Uses `colorScheme.onSurface` for text
- Dark mode: Uses `colorScheme.onSurface` for text
- Icons: Use `colorScheme.primary` by default

## Best Practices

1. **Always use header widgets** instead of manually creating headers
2. **Choose the right header type** based on hierarchy:
   - PageHeader → Top-level page titles
   - SectionHeader → Major sections (dashboard, analytics)
   - CardHeader → Card titles and content sections
   - SubsectionHeader → Nested or smaller sections
3. **Use icons consistently** - same icon for similar content types
4. **Don't override styles** - use the provided customization options instead

## Files

- **Typography definitions:** `lib/src/core/theme/app_typography.dart`
- **Header widgets:** `lib/src/core/widgets/header_widgets.dart`
- **Theme configuration:** `lib/src/core/theme/app_theme.dart`

