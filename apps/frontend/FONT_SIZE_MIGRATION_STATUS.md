# Font Size Migration Status

## ✅ Completed

### Core System
- ✅ Created `AppFontSizes` class with all font size constants
- ✅ Updated `AppTypography` to use `AppFontSizes` constants
- ✅ Updated `buildTextTheme` to use `AppFontSizes` constants
- ✅ Created documentation (`FONT_SIZE_SYSTEM.md`)

### Files Updated
- ✅ `apps/frontend/lib/src/core/theme/app_typography.dart` - All font sizes now use constants
- ✅ `apps/frontend/lib/src/features/maintenance_ticket/presentation/pages/tenant/tenant_ticket_detail_page.dart` - Updated hardcoded sizes
- ✅ `apps/frontend/lib/src/features/maintenance_ticket/presentation/widgets/ticket_rating_widget.dart` - Updated hardcoded sizes

## 🔄 Remaining Files to Update

### High Priority
- ⏳ `apps/frontend/lib/src/features/maintenance_ticket/presentation/pages/tenant/tenant_complaint_create_ai_page.dart`
  - Found 6 hardcoded font sizes: 12px, 13px, 11px, 10px
  - Should use: `AppFontSizes.bodySmall`, `AppFontSizes.labelMedium`, `AppFontSizes.labelSmall`, `AppFontSizes.tiny`

### Medium Priority
- ⏳ Other feature files with hardcoded font sizes
  - Search for: `fontSize: [0-9]+` to find remaining instances

## 📋 Migration Checklist

For each file with hardcoded font sizes:

1. [ ] Add import: `import '../../../../../core/theme/app_typography.dart';`
2. [ ] Replace hardcoded sizes with `AppFontSizes` constants:
   - `fontSize: 16` → `fontSize: AppFontSizes.titleSmall` or `AppFontSizes.bodyLarge`
   - `fontSize: 14` → `fontSize: AppFontSizes.bodyMedium` or `AppFontSizes.labelLarge`
   - `fontSize: 13` → `fontSize: AppFontSizes.labelMedium`
   - `fontSize: 12` → `fontSize: AppFontSizes.bodySmall` or `AppFontSizes.caption`
   - `fontSize: 11` → `fontSize: AppFontSizes.labelSmall`
   - `fontSize: 10` → `fontSize: AppFontSizes.tiny` or `AppFontSizes.overline`
3. [ ] Test the file to ensure visual consistency
4. [ ] Update this checklist

## 🎯 Quick Reference

| Hardcoded Size | Use Constant | Use Case |
|----------------|--------------|----------|
| 22px | `AppFontSizes.titleLarge` | Page headers |
| 20px | `AppFontSizes.titleMedium` | Section headers |
| 18px | `AppFontSizes.titleExtraSmall` | Alternative headers |
| 16px | `AppFontSizes.titleSmall` or `AppFontSizes.bodyLarge` | Card headers or large body |
| 14px | `AppFontSizes.bodyMedium` or `AppFontSizes.labelLarge` | Body text or buttons |
| 13px | `AppFontSizes.labelMedium` | Labels, captions |
| 12px | `AppFontSizes.bodySmall` or `AppFontSizes.caption` | Small body or captions |
| 11px | `AppFontSizes.labelSmall` | Small labels |
| 10px | `AppFontSizes.tiny` or `AppFontSizes.overline` | Very small text |

## 🔍 Finding Remaining Hardcoded Sizes

Run this command to find all remaining hardcoded font sizes:

```bash
grep -rn "fontSize: [0-9]" apps/frontend/lib/src/features/ | grep -v "AppFontSizes" | grep -v "app_typography.dart"
```

## 📝 Notes

- The system is now in place and working
- Most critical files have been updated
- Remaining files can be updated incrementally
- All new code should use `AppFontSizes` constants

