import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../theme/app_typography.dart';

/// Standardized text field widget that follows the app's design system.
///
/// Features:
/// - Label above the input field
/// - Optional helper text to the right of the label
/// - Icon on the left inside the input
/// - Consistent styling across the app
class StandardTextField extends StatelessWidget {
  const StandardTextField({
    super.key,
    required this.name,
    required this.label,
    this.helperText,
    this.icon,
    this.hintText,
    this.initialValue,
    this.obscureText = false,
    this.onTogglePassword,
    this.validator,
    this.keyboardType,
    this.autofillHints,
    this.onSubmitted,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.suffixIcon,
  });

  final String name;
  final String label;
  final String? helperText;
  final IconData? icon;
  final String? hintText;
  final String? initialValue;
  final bool obscureText;
  final VoidCallback? onTogglePassword;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<String>? autofillHints;
  final ValueChanged<String?>? onSubmitted;
  final int maxLines;
  final bool enabled;
  final bool readOnly;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPassword = onTogglePassword != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and Helper Text Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.label(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme
                      .onSurface, // Explicitly use theme color for visibility
                ),
              ),
            ),
            if (helperText != null) ...[
              const SizedBox(width: 8),
              Text(
                helperText!,
                style: AppTypography.body(context).copyWith(
                  color: colorScheme
                      .onSurfaceVariant, // Use theme color instead of hardcoded
                  fontSize: 12,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Input Field
        FormBuilderTextField(
          name: name,
          initialValue: initialValue,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          validator: validator,
          onSubmitted: onSubmitted,
          maxLines: maxLines,
          enabled: enabled,
          readOnly: readOnly,
          style: AppTypography.body(context).copyWith(
            color: colorScheme
                .onSurface, // Explicitly set text color for visibility
          ),
          decoration: InputDecoration(
            hintText: hintText ?? 'Enter ${label.toLowerCase()}',
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: colorScheme
                        .onSurfaceVariant, // Use theme color for dark mode support
                  )
                : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: colorScheme
                          .onSurfaceVariant, // Use theme color for dark mode support
                    ),
                    onPressed: onTogglePassword,
                  )
                : suffixIcon,
            // Use the theme's input decoration
          ),
        ),
      ],
    );
  }
}
