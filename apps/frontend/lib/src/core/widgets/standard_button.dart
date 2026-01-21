import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Standardized button widget that follows the app's design system.
/// 
/// Features:
/// - Full width by default
/// - Height 48px
/// - Primary blue background
/// - White text
/// - Optional trailing icon (e.g., arrow)
class StandardButton extends StatelessWidget {
  const StandardButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon = false,
    this.isLoading = false,
    this.fullWidth = true,
    this.variant = ButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool trailingIcon;
  final bool isLoading;
  final bool fullWidth;
  final ButtonVariant variant;

  @override
  Widget build(BuildContext context) {

    Widget buttonContent = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryForeground,
              ),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null && !trailingIcon) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTypography.button(context),
              ),
              if (icon != null && trailingIcon) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 20),
              ],
            ],
          );

    switch (variant) {
      case ButtonVariant.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: buttonContent,
          ),
        );
      case ButtonVariant.filled:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: FilledButton(
            onPressed: isLoading ? null : onPressed,
            child: buttonContent,
          ),
        );
      case ButtonVariant.outlined:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: buttonContent,
          ),
        );
      case ButtonVariant.text:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            child: buttonContent,
          ),
        );
    }
  }
}

enum ButtonVariant {
  primary,
  filled,
  outlined,
  text,
}

