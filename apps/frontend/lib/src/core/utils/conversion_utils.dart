/// Utility class for type-safe data conversions
class ConversionUtils {
  // String conversions
  static String? nullableString(String? value) =>
      value?.isEmpty == true ? null : value;

  static String nonNullString(String? value, {String defaultValue = ''}) =>
      value ?? defaultValue;

  // Number conversions
  static int? nullableInt(int? value) => value;

  static int nonNullInt(int? value, {int defaultValue = 0}) =>
      value ?? defaultValue;

  static double? nullableDouble(double? value) => value;

  static double nonNullDouble(double? value, {double defaultValue = 0.0}) =>
      value ?? defaultValue;

  // Boolean conversions
  static bool convertBool(bool? value, {bool defaultValue = false}) =>
      value ?? defaultValue;

  // DateTime conversions
  static DateTime? nullableDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value).toLocal();
    } catch (e) {
      return null;
    }
  }

  static String? dateTimeToUtcString(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.toUtc().toIso8601String();
  }

  // List conversions
  static List<T> safeList<T>(
    List<dynamic>? items,
    T Function(dynamic) mapper,
  ) {
    if (items == null) return [];
    return items
        .where((item) => item != null)
        .map((item) {
          try {
            return mapper(item);
          } catch (e) {
            return null;
          }
        })
        .whereType<T>()
        .toList();
  }

  // Enum conversions with fallback
  static T? safeEnum<T extends Enum>(
    String? value,
    List<T> values, {
    T? defaultValue,
  }) {
    if (value == null) return defaultValue;
    try {
      return values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
        orElse: () => defaultValue ?? values.first,
      );
    } catch (e) {
      return defaultValue ?? values.first;
    }
  }

  // Color parsing
  static int? parseColorHex(String? colorCode) {
    if (colorCode == null || colorCode.isEmpty) return null;
    try {
      // Handle hex colors like "#FF0000" or "FF0000"
      final hex = colorCode.replaceAll('#', '');
      return int.parse('FF$hex', radix: 16);
    } catch (e) {
      return null;
    }
  }
}

