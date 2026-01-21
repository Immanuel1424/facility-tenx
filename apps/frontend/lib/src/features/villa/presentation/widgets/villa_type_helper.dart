/// Helper class to manage relationships between Villa Type and other fields
class VillaTypeHelper {
  /// Map of villa type to suggested bedroom count
  /// Dubai Region Standards for Alosool Group
  static const Map<String, int?> _bedroomCountMap = {
    'Studio': 1, // Studio typically has 1 bedroom or 0 (studio apartment)
    '1BHK': 1,
    '2BHK': 2,
    '3BHK': 3,
    '4BHK': 4,
    '5BHK': 5,
    'Penthouse': null, // Variable, no suggestion
    'Duplex': null, // Variable, no suggestion
    'Townhouse': null, // Variable, no suggestion
    'Villa': null, // Variable, no suggestion
    'Mansion': null, // Variable, no suggestion
  };

  /// Map of villa type to suggested floor count
  /// Dubai Region Standards for Alosool Group
  static const Map<String, int?> _floorCountMap = {
    'Duplex': 2, // Duplex typically has 2 floors
    'Townhouse': 2, // Townhouse typically has 2 floors
    // All others: null (no suggestion)
  };

  /// Get suggested bedroom count based on villa type
  /// Returns null if no suggestion should be made
  static int? getSuggestedBedroomCount(String? villaType) {
    if (villaType == null) return null;
    return _bedroomCountMap[villaType];
  }

  /// Get suggested floor count based on villa type
  /// Returns null if no suggestion should be made
  static int? getSuggestedFloorCount(String? villaType) {
    if (villaType == null) return null;
    return _floorCountMap[villaType];
  }

  /// Check if bedroom count should be suggested for the given villa type
  static bool shouldSuggestBedroomCount(String? villaType) {
    return getSuggestedBedroomCount(villaType) != null;
  }

  /// Check if floor count should be suggested for the given villa type
  static bool shouldSuggestFloorCount(String? villaType) {
    return getSuggestedFloorCount(villaType) != null;
  }

  /// Validate bedroom count against villa type (warning only, not error)
  /// Returns warning message if there's a mismatch, null otherwise
  static String? validateBedroomCountAgainstType(
    String? villaType,
    int? bedroomCount,
  ) {
    if (villaType == null || bedroomCount == null) return null;

    final suggested = getSuggestedBedroomCount(villaType);
    if (suggested == null) return null; // No suggestion, no validation

    if (bedroomCount != suggested) {
      return 'Note: $villaType typically has $suggested bedroom(s), but you entered $bedroomCount.';
    }

    return null;
  }

  /// Validate floor count against villa type (warning only, not error)
  /// Returns warning message if there's a mismatch, null otherwise
  static String? validateFloorCountAgainstType(
    String? villaType,
    int? floorCount,
  ) {
    if (villaType == null || floorCount == null) return null;

    final suggested = getSuggestedFloorCount(villaType);
    if (suggested == null) return null; // No suggestion, no validation

    if (floorCount != suggested) {
      return 'Note: $villaType typically has $suggested floor(s), but you entered $floorCount.';
    }

    return null;
  }
}

