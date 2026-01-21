import 'package:flutter/material.dart';

/// Custom IconButton widget for AppBar actions with white background
/// This ensures consistent styling for AppBar buttons across the app
class AppBarIconButton extends StatelessWidget {
  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.isSelected = false,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surface, // Use theme color for dark mode support
        foregroundColor: colorScheme.onPrimary, // Use theme color for icon
        disabledBackgroundColor: colorScheme.surface.withValues(alpha: 0.5),
        disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.3),
      ),
    );
  }
}
