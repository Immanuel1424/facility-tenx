// Web storage helper using direct localStorage access
// This is a workaround for SharedPreferences persistence issues on Flutter web

import 'dart:js' as js;

/// Direct localStorage access for web platform
class WebStorageHelper {
  static const String _companyIdKey = 'company_id';
  static const String _storagePrefix = 'facility_erp_';

  /// Get localStorage object
  static js.JsObject? _getLocalStorage() {
    try {
      print('🔍 WebStorageHelper._getLocalStorage(): Checking js.context...');
      final context = js.context;
      print('🔍 WebStorageHelper._getLocalStorage(): js.context is available');
      
      final storage = context['localStorage'];
      print('🔍 WebStorageHelper._getLocalStorage(): localStorage is ${storage != null ? "available" : "null"}');
      
      if (storage == null) {
        print('⚠️ WebStorageHelper: localStorage is null in js.context');
        return null;
      }
      
      final storageObj = storage as js.JsObject?;
      print('🔍 WebStorageHelper._getLocalStorage(): Successfully got localStorage object');
      return storageObj;
    } catch (e, stackTrace) {
      print('⚠️ WebStorageHelper._getLocalStorage() error: $e');
      print('⚠️ Stack trace: $stackTrace');
      return null;
    }
  }

  /// Get company ID directly from localStorage
  static String? getCompanyId() {
    try {
      final storage = _getLocalStorage();
      if (storage == null) {
        print('⚠️ WebStorageHelper: localStorage is not available');
        return null;
      }
      
      final key = '$_storagePrefix$_companyIdKey';
      print('🔍 WebStorageHelper.getCompanyId(): Looking for key: $key');
      
      // Debug: Print all localStorage keys
      try {
        final length = storage['length'];
        print('🔍 WebStorageHelper: localStorage has $length items');
        if (length != null) {
          final lengthInt = (length as num).toInt();
          if (lengthInt > 0) {
            for (int i = 0; i < lengthInt; i++) {
              final itemKey = storage.callMethod('key', [i]);
              final itemValue = storage.callMethod('getItem', [itemKey]);
              print('   - $itemKey: $itemValue');
            }
          }
        }
      } catch (e) {
        print('⚠️ Could not enumerate localStorage: $e');
      }
      
      final value = storage.callMethod('getItem', [key]);
      final companyId = value?.toString();
      
      print('🔍 WebStorageHelper.getCompanyId(): Found value: $companyId');
      return companyId;
    } catch (e) {
      print('⚠️ WebStorageHelper.getCompanyId() error: $e');
      return null;
    }
  }

  /// Save company ID directly to localStorage
  static Future<bool> saveCompanyId(String companyId) async {
    try {
      print('💾 ========== WebStorageHelper.saveCompanyId() START ==========');
      print('💾 WebStorageHelper.saveCompanyId() called with: $companyId');
      
      final storage = _getLocalStorage();
      if (storage == null) {
        print('❌ WebStorageHelper: localStorage is not available - cannot save!');
        return false;
      }
      
      final key = '$_storagePrefix$_companyIdKey';
      print('💾 WebStorageHelper: Saving to key: $key');
      print('💾 WebStorageHelper: Company ID value: $companyId');
      
      // Test write capability first
      try {
        final testKey = '${key}_test';
        storage.callMethod('setItem', [testKey, 'test_value']);
        final testRead = storage.callMethod('getItem', [testKey]);
        print('💾 WebStorageHelper: Test write/read - key: $testKey, value: $testRead');
        if (testRead?.toString() != 'test_value') {
          print('❌ WebStorageHelper: Test write failed! localStorage may be read-only or disabled');
          return false;
        }
        storage.callMethod('removeItem', [testKey]);
        print('✅ WebStorageHelper: Test write/read successful - localStorage is writable');
      } catch (e) {
        print('❌ WebStorageHelper: Test write failed with error: $e');
        return false;
      }
      
      // Check localStorage before save
      final beforeSave = storage.callMethod('getItem', [key]);
      print('💾 WebStorageHelper: Before save - key: $key, existing value: $beforeSave');
      
      // Save to localStorage
      print('💾 WebStorageHelper: Calling setItem($key, $companyId)...');
      storage.callMethod('setItem', [key, companyId]);
      print('💾 WebStorageHelper: setItem called - no exception thrown');
      
      // Immediately verify by reading back
      final verifyValue = storage.callMethod('getItem', [key]);
      final verifyCompanyId = verifyValue?.toString();
      print('💾 WebStorageHelper: Immediate verification - key: $key, value: $verifyCompanyId');
      
      if (verifyCompanyId == null || verifyCompanyId.isEmpty) {
        print('❌ WebStorageHelper.saveCompanyId() immediate verification failed! Value is null or empty');
        print('❌ This suggests setItem did not work or localStorage was cleared');
        return false;
      }
      
      if (verifyCompanyId != companyId) {
        print('❌ WebStorageHelper.saveCompanyId() immediate verification failed! Expected: $companyId, Got: $verifyCompanyId');
        return false;
      }
      
      print('✅ WebStorageHelper: Immediate verification passed!');
      
      // Wait a bit and verify again (to ensure it's persisted)
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final verifyValue2 = storage.callMethod('getItem', [key]);
      final verifyCompanyId2 = verifyValue2?.toString();
      print('💾 WebStorageHelper: Delayed verification (200ms) - key: $key, value: $verifyCompanyId2');
      
      if (verifyCompanyId2 != companyId) {
        print('❌ WebStorageHelper.saveCompanyId() delayed verification failed! Expected: $companyId, Got: $verifyCompanyId2');
        return false;
      }
      
      // Check localStorage length to confirm item was added
      final length = storage['length'];
      final lengthInt = length != null ? (length as num).toInt() : 0;
      print('💾 WebStorageHelper: localStorage now has $lengthInt items');
      
      // Also verify using getCompanyId() method
      final saved = getCompanyId();
      if (saved != companyId) {
        print('❌ WebStorageHelper.saveCompanyId() getCompanyId() verification failed! Expected: $companyId, Got: $saved');
        return false;
      }
      
      print('✅ WebStorageHelper.saveCompanyId($companyId): SUCCESS - verified multiple times');
      print('💾 ========== WebStorageHelper.saveCompanyId() END ==========');
      return true;
    } catch (e, stackTrace) {
      print('❌ WebStorageHelper.saveCompanyId() error: $e');
      print('❌ Stack trace: $stackTrace');
      return false;
    }
  }

  /// Clear company ID from localStorage
  static bool clearCompanyId() {
    try {
      final storage = _getLocalStorage();
      if (storage == null) {
        return false;
      }
      
      final key = '$_storagePrefix$_companyIdKey';
      storage.callMethod('removeItem', [key]);
      return true;
    } catch (e) {
      print('⚠️ WebStorageHelper.clearCompanyId() error: $e');
      return false;
    }
  }

  /// Check if company ID exists
  static bool hasCompanyId() {
    final companyId = getCompanyId();
    return companyId != null && companyId.isNotEmpty;
  }
}

