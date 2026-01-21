import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage company ID storage in SharedPreferences.
/// Company ID persists across app restarts and logout operations.
/// 
/// On web, SharedPreferences uses localStorage with a 'flutter.' prefix by default.
/// This is handled internally by the package, so we don't need to worry about it.
/// 
/// Note: SharedPreferences.getInstance() already handles caching internally,
/// so we don't need to implement our own singleton pattern.
class CompanyIdStorage {
  static const String _companyIdKey = 'company_id';

  /// Get SharedPreferences instance
  /// SharedPreferences.getInstance() is cached internally by the package
  static Future<SharedPreferences?> _getPrefs() async {
    try {
      // SharedPreferences.getInstance() already handles caching internally
      // On web, this uses localStorage with 'flutter.' prefix automatically
      final prefs = await SharedPreferences.getInstance();
      return prefs;
    } catch (e, stackTrace) {
      print('⚠️ Error getting SharedPreferences instance: $e');
      print('⚠️ Stack trace: $stackTrace');
      return null;
    }
  }

  /// Get the stored company ID from SharedPreferences.
  /// Returns null if no company ID is stored.
  static Future<String?> getCompanyId() async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) {
        print('⚠️ CompanyIdStorage.getCompanyId(): SharedPreferences instance is null');
        return null;
      }
      
      // On web, reload to ensure we have the latest data from localStorage
      if (kIsWeb) {
        try {
          await prefs.reload();
          print('✅ Reloaded SharedPreferences before reading (web)');
        } catch (e) {
          print('⚠️ Error reloading SharedPreferences before reading: $e');
        }
      }
      
      final companyId = prefs.getString(_companyIdKey);
      print('🔍 CompanyIdStorage.getCompanyId(): $companyId (web: $kIsWeb)');
      
      // On web, SharedPreferences stores with 'flutter.' prefix in localStorage
      // The getString() method handles this automatically
      return companyId;
    } catch (e, stackTrace) {
      print('⚠️ Error reading company ID from storage: $e');
      print('⚠️ Stack trace: $stackTrace');
      return null;
    }
  }

  /// Save the company ID to SharedPreferences.
  /// Returns true if successful, false otherwise.
  static Future<bool> saveCompanyId(String companyId) async {
    try {
      print('💾 ========== CompanyIdStorage.saveCompanyId() START ==========');
      print('💾 CompanyIdStorage.saveCompanyId() called with: "$companyId" (web: $kIsWeb)');
      
      if (companyId.isEmpty) {
        print('❌ CompanyIdStorage.saveCompanyId(): Company ID is empty!');
        return false;
      }
      
      final prefs = await _getPrefs();
      if (prefs == null) {
        print('⚠️ CompanyIdStorage.saveCompanyId(): SharedPreferences instance is null, cannot save');
        return false;
      }
      
      // Debug: Print current state before save
      final beforeSave = prefs.getString(_companyIdKey);
      print('💾 Before save - current value: $beforeSave');
      print('💾 Before save - all keys: ${prefs.getKeys()}');
      
      // On web, SharedPreferences automatically uses 'flutter.' prefix in localStorage
      // The setString() method handles this automatically
      print('💾 Calling setString("$_companyIdKey", "$companyId")...');
      final result = await prefs.setString(_companyIdKey, companyId);
      print('💾 setString returned: $result');
      
      if (!result) {
        print('❌ setString returned false - save failed!');
        return false;
      }
      
      // Immediately check the cache (should be updated)
      final immediateCheck = prefs.getString(_companyIdKey);
      print('💾 Immediate check after setString: $immediateCheck');
      
      // On web, SharedPreferences writes are asynchronous to localStorage
      // We need to wait a bit and reload to ensure the write is persisted
      if (kIsWeb) {
        print('💾 Web platform detected - waiting for async write...');
        // Wait for the async write to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));
        
        // Reload to get the latest data from localStorage
        try {
          print('💾 Reloading SharedPreferences...');
          await prefs.reload();
          print('✅ Reloaded SharedPreferences after save (web)');
        } catch (e, stackTrace) {
          print('⚠️ Error reloading SharedPreferences after save: $e');
          print('⚠️ Stack trace: $stackTrace');
        }
      }
      
      // Verify the save by reading back
      final saved = prefs.getString(_companyIdKey);
      print('💾 Verification after save: saved value = "$saved"');
      print('💾 Verification: expected = "$companyId", actual = "$saved"');
      
      if (saved != companyId) {
        print('⚠️ CompanyIdStorage verification failed! Expected: "$companyId", Got: "$saved"');
        
        // On web, try one more reload with a longer delay
        if (kIsWeb) {
          try {
            print('💾 Attempting second reload with longer delay...');
            await Future<void>.delayed(const Duration(milliseconds: 200));
            await prefs.reload();
            final reloaded = prefs.getString(_companyIdKey);
            print('🔍 CompanyIdStorage after second reload: "$reloaded"');
            if (reloaded == companyId) {
              print('✅ CompanyIdStorage verification passed after second reload');
              print('💾 ========== CompanyIdStorage.saveCompanyId() END (SUCCESS) ==========');
              return true;
            } else {
              print('❌ CompanyIdStorage: Still not matching after second reload.');
              print('❌ Expected: "$companyId", Got: "$reloaded"');
            }
          } catch (e) {
            print('⚠️ Error in second reload attempt: $e');
          }
        }
        print('💾 ========== CompanyIdStorage.saveCompanyId() END (FAILED) ==========');
        return false;
      }
      
      print('✅ CompanyIdStorage.saveCompanyId() completed successfully');
      print('💾 ========== CompanyIdStorage.saveCompanyId() END (SUCCESS) ==========');
      return true;
    } catch (e, stackTrace) {
      print('⚠️ Error saving company ID to SharedPreferences: $e');
      print('⚠️ Stack trace: $stackTrace');
      print('💾 ========== CompanyIdStorage.saveCompanyId() END (ERROR) ==========');
      return false;
    }
  }

  /// Clear the company ID from SharedPreferences.
  /// Returns true if successful, false otherwise.
  static Future<bool> clearCompanyId() async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) {
        print('⚠️ CompanyIdStorage.clearCompanyId(): SharedPreferences instance is null');
        return false;
      }
      
      final result = await prefs.remove(_companyIdKey);
      print('🔍 CompanyIdStorage.clearCompanyId(): $result');
      return result;
    } catch (e, stackTrace) {
      print('⚠️ Error clearing company ID from SharedPreferences: $e');
      print('⚠️ Stack trace: $stackTrace');
      return false;
    }
  }

  /// Check if a company ID is stored.
  /// Returns true if company ID exists, false otherwise.
  static Future<bool> hasCompanyId() async {
    final companyId = await getCompanyId();
    final hasId = companyId != null && companyId.isNotEmpty;
    print('🔍 CompanyIdStorage.hasCompanyId(): $hasId');
    return hasId;
  }
  
  /// Debug method to print all keys in SharedPreferences (useful for troubleshooting)
  static Future<void> debugPrintAllKeys() async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) {
        print('⚠️ Cannot debug: SharedPreferences instance is null');
        return;
      }
      
      // Reload to ensure we have the latest data (especially important on web)
      if (kIsWeb) {
        try {
          await prefs.reload();
          print('✅ Reloaded SharedPreferences for debugging');
        } catch (e) {
          print('⚠️ Could not reload SharedPreferences: $e');
        }
      }
      
      final keys = prefs.getKeys();
      print('🔍 CompanyIdStorage.debugPrintAllKeys():');
      print('   Total keys: ${keys.length}');
      for (final key in keys) {
        final value = prefs.get(key);
        print('   - $key: $value');
      }
      print('   Looking for key: $_companyIdKey');
      final companyIdValue = prefs.getString(_companyIdKey);
      print('   Company ID value: $companyIdValue');
      
      // On web, also check localStorage directly to see the actual stored keys
      if (kIsWeb) {
        print('   Note: On web, SharedPreferences uses localStorage with "flutter." prefix');
        print('   The actual localStorage key would be: "flutter.$_companyIdKey"');
      }
    } catch (e, stackTrace) {
      print('⚠️ Error debugging SharedPreferences: $e');
      print('⚠️ Stack trace: $stackTrace');
    }
  }
  
  /// Force reload SharedPreferences (useful for web when data might be stale)
  static Future<void> reload() async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.reload();
        print('✅ CompanyIdStorage: Reloaded SharedPreferences');
      }
    } catch (e) {
      print('⚠️ Error reloading SharedPreferences: $e');
    }
  }
}
