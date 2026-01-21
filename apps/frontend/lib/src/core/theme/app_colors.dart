import 'package:flutter/material.dart';

/// Centralized color tokens for the application.
/// All colors must come from this file - no inline colors allowed.
///
/// Primary color: #FCB447 (Brand Orange)
/// This palette is generated to harmonize with the primary orange color.
class AppColors {
  AppColors._();

  // ============================================================================
  // PRIMARY COLOR - STRICTLY #FCB447
  // ============================================================================
  static const Color primary = Color(0xFFFCB447); // Brand Orange (STRICT)
  static const Color primaryForeground =
      Color(0xFFFFFFFF); // White for contrast

  // ============================================================================
  // BACKGROUND COLORS - Light/Neutral shades (slate-like)
  // ============================================================================
  /// Light background - Very light slate/neutral shade (slate-50 equivalent)
  static const Color background = Color(0xFFF8FAFC); // Light slate-50
  /// Dark foreground text - High contrast (slate-900 equivalent)
  static const Color foreground = Color(0xFF0F172A); // Dark slate-900
  /// Border color - Subtle gray border
  static const Color border = Color(0xFFE2E8F0); // Slate-200
  /// Input field background - Pure white for contrast
  static const Color input = Color(0xFFFFFFFF);

  // ============================================================================
  // INPUT COLORS
  // ============================================================================
  /// Input icon color - Muted gray for reduced intensity
  static const Color inputIcon = Color(0xFF64748B); // Slate-500

  // ============================================================================
  // SECONDARY COLORS - Complementary to primary blue
  // ============================================================================
  /// Secondary background - Light slate
  static const Color secondary = Color(0xFFF1F5F9); // Slate-100
  static const Color secondaryForeground = Color(0xFF0F172A); // Slate-900

  // ============================================================================
  // MUTED COLORS - For subtle UI elements
  // ============================================================================
  /// Muted background - Very light slate
  static const Color muted = Color(0xFFF1F5F9); // Slate-100
  static const Color mutedForeground = Color(0xFF64748B); // Slate-500

  // ============================================================================
  // ACCENT COLORS - Light tint of primary blue
  // ============================================================================
  /// Accent background - Very light blue tint (10% of primary)
  static const Color accent = Color(0xFFE0F2FE); // Sky-100 (light blue tint)
  static const Color accentForeground =
      Color(0xFF075985); // Sky-800 (dark blue)

  // ============================================================================
  // SEMANTIC COLORS - Harmonized with primary blue
  // ============================================================================
  /// Success - Green that harmonizes with blue
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color successForeground = Color(0xFFFFFFFF);

  /// Warning - Amber that harmonizes with blue
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color warningForeground = Color(0xFF78350F); // Amber-900

  /// Destructive/Error - Red that harmonizes with blue
  static const Color destructive = Color(0xFFEF4444); // Red-500
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  // ============================================================================
  // CARD COLORS
  // ============================================================================
  /// Card background - Pure white
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF0F172A); // Slate-900

  // ============================================================================
  // SIDEBAR COLORS
  // ============================================================================
  /// Sidebar background - Dark slate
  static const Color sidebar = Color(0xFF0F172A); // Slate-900
  static const Color sidebarForeground = Color(0xFFE2E8F0); // Slate-200
  /// Sidebar primary - Same as primary brand color
  static const Color sidebarPrimary = Color(0xFFFCB447); // Brand Orange
  static const Color sidebarPrimaryForeground = Color(0xFFFFFFFF); // White
}
