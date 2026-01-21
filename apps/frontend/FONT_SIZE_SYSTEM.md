# Font Size System Documentation

## Overview

All font sizes in the application are centralized in a single location for easy maintenance and consistency. This ensures that font sizes can be updated globally by changing values in one place.

## Location

**File:** `lib/src/core/theme/app_typography.dart`

**Class:** `AppFontSizes`

## Font Size Constants

### Display Sizes (Rarely Used)
- `displayLarge`: 57px
- `displayMedium`: 45px
- `displaySmall`: 36px

### Headline Sizes
- `headlineLarge`: 32px
- `headlineMedium`: 28px
- `headlineSmall`: 24px

### Title/Header Sizes
- `titleLarge`: 22px (Page headers - Desktop)
- `titleLargeMobile`: 20px (Page headers - Mobile)
- `titleMedium`: 20px (Section headers - Desktop)
- `titleMediumMobile`: 18px (Section headers - Mobile)
- `titleSmall`: 16px (Card headers)
- `titleExtraSmall`: 18px (Alternative card header size)

### Body Sizes
- `bodyLarge`: 16px
- `bodyMedium`: 14px
- `bodySmall`: 12px

### Label Sizes
- `labelLarge`: 14px (Button text)
- `labelMedium`: 13px (Form labels, captions)
- `labelSmall`: 11px (Small labels, helper text)

### Special Sizes
- `caption`: 12px (Captions, timestamps)
- `overline`: 10px (Overline text)
- `tiny`: 10px (Very small text, e.g., badges)

## Usage

### Direct Access to Constants

```dart
import 'package:your_app/core/theme/app_typography.dart';

// Use the constant directly
Text(
  'Hello',
  style: TextStyle(fontSize: AppFontSizes.bodyMedium),
)
```

### Using Typography Methods

```dart
import 'package:your_app/core/theme/app_typography.dart';

// Use the typography method (recommended)
Text(
  'Hello',
  style: AppTypography.body(context),
)
```

### Using Theme Text Styles

```dart
// Use theme text styles (automatically uses AppFontSizes)
Text(
  'Hello',
  style: Theme.of(context).textTheme.bodyMedium,
)
```

## Migration Guide

### Before (Hardcoded)
```dart
Text(
  'Hello',
  style: TextStyle(fontSize: 14),
)
```

### After (Centralized)
```dart
// Option 1: Use constant
Text(
  'Hello',
  style: TextStyle(fontSize: AppFontSizes.bodyMedium),
)

// Option 2: Use typography method (recommended)
Text(
  'Hello',
  style: AppTypography.body(context),
)

// Option 3: Use theme
Text(
  'Hello',
  style: Theme.of(context).textTheme.bodyMedium,
)
```

## Updating Font Sizes

To update font sizes across the entire application:

1. Open `lib/src/core/theme/app_typography.dart`
2. Find the `AppFontSizes` class
3. Update the desired constant value
4. All usages throughout the app will automatically use the new size

### Example: Making body text larger

```dart
// Before
static const double bodyMedium = 14;

// After
static const double bodyMedium = 16;
```

This change will automatically apply to:
- All `AppTypography.body(context)` calls
- All `Theme.of(context).textTheme.bodyMedium` usages
- All direct `AppFontSizes.bodyMedium` references

## Best Practices

1. **Never hardcode font sizes** - Always use `AppFontSizes` constants
2. **Prefer typography methods** - Use `AppTypography.body(context)` over direct constants when possible
3. **Use theme text styles** - When using Material widgets, prefer `Theme.of(context).textTheme.*`
4. **Document exceptions** - If you must use a custom size, document why in a comment
5. **Test responsive behavior** - Some sizes adapt to mobile/desktop automatically

## Responsive Font Sizes

Some font sizes automatically adapt to screen size:

- **Page Headers**: 20px (mobile) → 22px (desktop)
- **Section Headers**: 18px (mobile) → 20px (desktop)
- **Subsection Headers**: 14px (mobile) → 15px (desktop)

These are handled automatically by the `AppTypography` methods. Use these methods instead of direct constants for responsive behavior.

## Font Size Hierarchy

```
Display (57px, 45px, 36px)
  ↓
Headline (32px, 28px, 24px)
  ↓
Title/Header (22px, 20px, 18px, 16px)
  ↓
Body (16px, 14px, 12px)
  ↓
Label (14px, 13px, 11px)
  ↓
Special (12px, 10px)
```

## Common Use Cases

| Use Case | Font Size | Method/Constant |
|----------|-----------|-----------------|
| Page title | 22px/20px | `AppTypography.pageHeader(context)` |
| Section header | 20px/18px | `AppTypography.sectionHeader(context)` |
| Card header | 16px | `AppTypography.cardHeader(context)` |
| Body text | 14px | `AppTypography.body(context)` |
| Button text | 14px | `AppTypography.button(context)` |
| Form label | 13px | `AppTypography.label(context)` |
| Caption | 12px | `AppTypography.caption(context)` |
| Small text | 11px | `AppTypography.small(context)` |
| Tiny text | 10px | `AppTypography.tiny(context)` |

## Verification

To verify all font sizes are centralized:

```bash
# Search for hardcoded font sizes (should return minimal results)
grep -r "fontSize: [0-9]" apps/frontend/lib/src/features/

# Search for AppFontSizes usage (should return many results)
grep -r "AppFontSizes\." apps/frontend/lib/src/
```

## Future Updates

When updating font sizes:

1. Update the constant in `AppFontSizes`
2. Test the application thoroughly
3. Update this documentation if adding new sizes
4. Consider accessibility guidelines (WCAG recommends minimum 16px for body text)

