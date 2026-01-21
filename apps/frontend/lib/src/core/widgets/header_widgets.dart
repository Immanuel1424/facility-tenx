import 'package:flutter/material.dart';
import '../theme/app_typography.dart';

/// Reusable header widgets for consistent styling across the application
/// These widgets automatically adapt to mobile/desktop screen sizes

/// Page Header Widget - For AppBar titles and main page titles
class PageHeader extends StatelessWidget {
  const PageHeader(
    this.text, {
    super.key,
    this.color,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.pageHeader(context);
    return Text(
      text,
      style: color != null ? style.copyWith(color: color) : style,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
    );
  }
}

/// Section Header Widget - For dashboard sections and major content sections
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.text, {
    super.key,
    this.icon,
    this.color,
    this.maxLines,
    this.overflow,
    this.spacing = 8,
  });

  final String text;
  final IconData? icon;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = AppTypography.sectionHeader(context);
    final textWidget = Text(
      text,
      style: color != null ? style.copyWith(color: color) : style,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
    );

    if (icon != null) {
      return Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: color ?? theme.colorScheme.primary,
          ),
          SizedBox(width: spacing),
          Expanded(child: textWidget),
        ],
      );
    }

    return textWidget;
  }
}

/// Card Header Widget - For card titles and content section headers
class CardHeader extends StatelessWidget {
  const CardHeader(
    this.text, {
    super.key,
    this.icon,
    this.color,
    this.maxLines,
    this.overflow,
    this.spacing = 8,
  });

  final String text;
  final IconData? icon;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = AppTypography.cardHeader(context);
    final textWidget = Text(
      text,
      style: color != null ? style.copyWith(color: color) : style,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
    );

    if (icon != null) {
      return Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color ?? theme.colorScheme.primary,
          ),
          SizedBox(width: spacing),
          Expanded(child: textWidget),
        ],
      );
    }

    return textWidget;
  }
}

/// Subsection Header Widget - For nested sections and smaller headers
class SubsectionHeader extends StatelessWidget {
  const SubsectionHeader(
    this.text, {
    super.key,
    this.icon,
    this.color,
    this.maxLines,
    this.overflow,
    this.spacing = 8,
  });

  final String text;
  final IconData? icon;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = AppTypography.subsectionHeader(context);
    final textWidget = Text(
      text,
      style: color != null ? style.copyWith(color: color) : style,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
    );

    if (icon != null) {
      return Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? theme.colorScheme.primary,
          ),
          SizedBox(width: spacing),
          Expanded(child: textWidget),
        ],
      );
    }

    return textWidget;
  }
}

