import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Predefined primary color options for the application
class PrimaryColorOption {
  const PrimaryColorOption({
    required this.name,
    required this.color,
    required this.value,
  });

  final String name;
  final Color color;
  final int value; // For storage in SharedPreferences

  static const List<PrimaryColorOption> options = [
    PrimaryColorOption(
      name: 'Blue',
      color: Color(0xFF007be5),
      value: 0xFF007be5,
    ),
    PrimaryColorOption(
      name: 'Orange',
      color: Color(0xFFFCB447),
      value: 0xFFFCB447,
    ),
    PrimaryColorOption(
      name: 'Maroon',
      color: Color(0xFF8C2232),
      value: 0xFF8C2232,
    ),
    PrimaryColorOption(
      name: 'Green',
      color: Color(0xFF16A34A),
      value: 0xFF16A34A,
    ),
    PrimaryColorOption(
      name: 'Purple',
      color: Color(0xFF9333EA),
      value: 0xFF9333EA,
    ),
    PrimaryColorOption(
      name: 'Red',
      color: Color(0xFFDC2626),
      value: 0xFFDC2626,
    ),
    PrimaryColorOption(
      name: 'Teal',
      color: Color(0xFF14B8A6),
      value: 0xFF14B8A6,
    ),
    PrimaryColorOption(
      name: 'Indigo',
      color: Color(0xFF6366F1),
      value: 0xFF6366F1,
    ),
    PrimaryColorOption(
      name: 'Pink',
      color: Color(0xFFEC4899),
      value: 0xFFEC4899,
    ),
  ];

  static PrimaryColorOption? fromValue(int value) {
    try {
      return options.firstWhere((option) => option.value == value);
    } catch (e) {
      return null;
    }
  }
}

/// Service to manage theme preferences including primary color
class ThemeService {
  static const String _primaryColorKey = 'primary_color';
  static const int _defaultPrimaryColor = 0xFFFCB447; // Brand Orange (default)

  /// Get the saved primary color or return default
  static Future<Color> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_primaryColorKey) ?? _defaultPrimaryColor;
    return Color(colorValue);
  }

  /// Save the primary color preference
  static Future<void> setPrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.value);
  }

  /// Get the saved primary color option or return default
  static Future<PrimaryColorOption> getPrimaryColorOption() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_primaryColorKey) ?? _defaultPrimaryColor;
    return PrimaryColorOption.fromValue(colorValue) ?? PrimaryColorOption.options.first;
  }

  /// Save the primary color option
  static Future<void> setPrimaryColorOption(PrimaryColorOption option) async {
    await setPrimaryColor(option.color);
  }

  /// Reset to default primary color
  static Future<void> resetPrimaryColor() async {
    await setPrimaryColor(Color(_defaultPrimaryColor));
  }
}

/// Notifier for theme changes - allows reactive theme updates
class ThemeNotifier extends ValueNotifier<Color> {
  ThemeNotifier() : super(const Color(0xFFFCB447)) {
    _loadPrimaryColor();
  }

  Future<void> _loadPrimaryColor() async {
    value = await ThemeService.getPrimaryColor();
  }

  Future<void> updatePrimaryColor(Color color) async {
    await ThemeService.setPrimaryColor(color);
    value = color;
  }

  Future<void> updatePrimaryColorOption(PrimaryColorOption option) async {
    await ThemeService.setPrimaryColorOption(option);
    value = option.color;
  }
}

/// Global theme notifier instance - can be accessed from anywhere
final themeNotifier = ThemeNotifier();

