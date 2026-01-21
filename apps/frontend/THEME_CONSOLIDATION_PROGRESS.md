# Theme Consolidation Progress

## Overview
This document tracks the progress of consolidating all hardcoded theme values (fontSize, colors, borderRadius, etc.) into the centralized theme system in `app_theme.dart` and `app_typography.dart`.

## Completed Files

### 1. `dashboard_stat_card_enhanced.dart` ✅
- **Fixed**: Hardcoded fontSize (11, 10, 24, 22) → Using `AppFontSizes` constants
- **Fixed**: Hardcoded `Colors.black.withOpacity` → Using `colorScheme.shadow`
- **Fixed**: Hardcoded `Colors.green/red/grey` → Using `colorScheme.primary/error/onSurfaceVariant`
- **Fixed**: Hardcoded `BorderRadius.circular(8)` → Using `context.cardBorderRadius`
- **Fixed**: Hardcoded `fontSize: 11` in trend badge → Using `textTheme.labelSmall`

### 2. `maintenance_ticket_list_page.dart` ✅
- **Fixed**: Hardcoded `fontSize: 12` → Using `textTheme.bodySmall`
- **Fixed**: Hardcoded `fontSize: 14` → Using `textTheme.bodyMedium`
- **Fixed**: Hardcoded `fontSize: 16` → Using `textTheme.titleSmall`

## Pattern for Fixes

### Font Sizes
Replace hardcoded fontSize values with theme typography:
- `fontSize: 10` → `textTheme.tiny` or `AppFontSizes.tiny`
- `fontSize: 11` → `textTheme.labelSmall` or `AppFontSizes.labelSmall`
- `fontSize: 12` → `textTheme.bodySmall` or `AppFontSizes.bodySmall`
- `fontSize: 13` → `textTheme.labelMedium` or `AppFontSizes.labelMedium`
- `fontSize: 14` → `textTheme.bodyMedium` or `AppFontSizes.bodyMedium`
- `fontSize: 16` → `textTheme.titleSmall` or `AppFontSizes.titleSmall`
- `fontSize: 18` → `textTheme.titleMedium` or `AppFontSizes.titleMedium`
- `fontSize: 20` → `textTheme.titleMedium` or `AppFontSizes.titleMedium`
- `fontSize: 22` → `textTheme.titleLarge` or `AppFontSizes.titleLarge`
- `fontSize: 24` → `textTheme.headlineSmall` or `AppFontSizes.headlineSmall`

### Colors
Replace hardcoded colors with theme colors:
- `Colors.black` → `colorScheme.shadow` or `colorScheme.onSurface`
- `Colors.white` → `colorScheme.onPrimary` or `colorScheme.surface`
- `Colors.green` → `colorScheme.primary` (or success if available)
- `Colors.red` → `colorScheme.error`
- `Colors.grey` → `colorScheme.onSurfaceVariant`
- `Color(0x...)` → Use `AppColors` constants or `colorScheme` values

### Border Radius
Replace hardcoded borderRadius with theme:
- `BorderRadius.circular(X)` → `context.cardBorderRadius` (for cards)
- Or use theme-defined radius from `cardTheme.shape`

### TextStyle
Replace inline `TextStyle` with theme text styles:
- `TextStyle(fontSize: X, ...)` → `textTheme.bodySmall?.copyWith(...)`
- Always use theme text styles as base, then override specific properties

## Files Remaining (43+ files identified)

### High Priority (Common Widgets)
- [ ] `user_list_page.dart` - Multiple fontSize: 10, 11
- [ ] `villa_list_page.dart` - Multiple fontSize: 10, 13
- [ ] `user_detail_page.dart` - Multiple fontSize: 11, 13, 14, 16, 24
- [ ] `villa_detail_page.dart` - Multiple fontSize: 16
- [ ] `user_create_page.dart` - Check for hardcoded values
- [ ] `villa_create_page.dart` - Check for hardcoded values

### Medium Priority (Feature Pages)
- [ ] `technician_ticket_detail_page.dart`
- [ ] `tenant_ticket_detail_page.dart`
- [ ] `maintenance_ticket_detail_page_enhanced.dart`
- [ ] `maintenance_ticket_create_page.dart`
- [ ] `tenant_complaint_create_page.dart`
- [ ] `tenant_complaint_create_ai_page.dart`

### Lower Priority (Widgets)
- [ ] `maintenance_ticket_list_item.dart`
- [ ] `maintenance_ticket_action_buttons.dart`
- [ ] `maintenance_ticket_priority_chip.dart`
- [ ] `maintenance_ticket_status_chip.dart`
- [ ] `comment_input_widget.dart`
- [ ] `attachment_gallery_widget.dart`
- [ ] And 30+ more files...

## Helper Extensions Added

### `theme_helpers.dart`
Added helper methods:
- `context.textTheme` - Quick access to text theme
- `context.colorScheme` - Quick access to color scheme
- `context.bodyTextStyle({Color? color})` - Body text with optional color
- `context.smallTextStyle({Color? color})` - Small text (12px)
- `context.captionTextStyle({Color? color})` - Caption text (12px)
- `context.labelTextStyle({Color? color})` - Label text (13px)

## Next Steps

1. Continue fixing high-priority files systematically
2. Create automated script to find and report all hardcoded values
3. Batch fix similar patterns across multiple files
4. Test application after each batch of changes
5. Update this document as progress is made

## Notes

- Always test after making changes to ensure UI consistency
- Some hardcoded values may be intentional (e.g., icon sizes, specific spacing)
- Focus on fontSize, colors, and borderRadius first as they have the most impact
- Use `AppFontSizes` constants for responsive sizing when needed
- Use `AppColors` constants for semantic colors

