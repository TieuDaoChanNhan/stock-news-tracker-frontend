import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Cache data với expiration time
  static Future<void> cacheData(String key, dynamic data, {Duration? expiration}) async {
    if (_prefs == null) await init();
    
    final jsonString = jsonEncode(data);
    await _prefs!.setString(key, jsonString);
    
    // Lưu timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await _prefs!.setInt('${key}_timestamp', timestamp);
    
    // Lưu expiration nếu có
    if (expiration != null) {
      final expirationTime = timestamp + expiration.inMilliseconds;
      await _prefs!.setInt('${key}_expiration', expirationTime);
    }
  }

  // Get cached data với auto expiration check
  static T? getCachedData<T>(
    String key, 
    T Function(Map<String, dynamic>) fromJson, {
    Duration? maxAge,
  }) {
    if (_prefs == null) return null;
    
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    
    // Check expiration từ cache
    final expirationTime = _prefs!.getInt('${key}_expiration');
    if (expirationTime != null && DateTime.now().millisecondsSinceEpoch > expirationTime) {
      clearCache(key);
      return null;
    }
    
    // Check max age nếu được specify
    if (maxAge != null) {
      final timestamp = _prefs!.getInt('${key}_timestamp') ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > maxAge.inMilliseconds) {
        clearCache(key);
        return null;
      }
    }
    
    try {
      final jsonData = jsonDecode(jsonString);
      if (jsonData is Map<String, dynamic>) {
        return fromJson(jsonData);
      } else if (jsonData is List) {
        // Handle list data
        return jsonData as T;
      }
      return null;
    } catch (e) {
      clearCache(key);
      return null;
    }
  }

  // Get cached list data
  static List<T>? getCachedListData<T>(
    String key, 
    T Function(Map<String, dynamic>) fromJson, {
    Duration? maxAge,
  }) {
    if (_prefs == null) return null;
    
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    
    // Check expiration
    if (maxAge != null) {
      final timestamp = _prefs!.getInt('${key}_timestamp') ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > maxAge.inMilliseconds) {
        clearCache(key);
        return null;
      }
    }
    
    try {
      final jsonData = jsonDecode(jsonString);
      if (jsonData is List) {
        return jsonData
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      clearCache(key);
      return null;
    }
  }

  // Cache simple values
  static Future<void> cacheString(String key, String value) async {
    if (_prefs == null) await init();
    await _prefs!.setString(key, value);
  }

  static Future<void> cacheInt(String key, int value) async {
    if (_prefs == null) await init();
    await _prefs!.setInt(key, value);
  }

  static Future<void> cacheBool(String key, bool value) async {
    if (_prefs == null) await init();
    await _prefs!.setBool(key, value);
  }

  static Future<void> cacheDouble(String key, double value) async {
    if (_prefs == null) await init();
    await _prefs!.setDouble(key, value);
  }

  // Get simple values
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  // Clear specific cache
  static Future<void> clearCache(String key) async {
    if (_prefs == null) await init();
    await _prefs!.remove(key);
    await _prefs!.remove('${key}_timestamp');
    await _prefs!.remove('${key}_expiration');
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    if (_prefs == null) await init();
    await _prefs!.clear();
  }

  // Check if cache exists and is valid
  static bool isCacheValid(String key, {Duration? maxAge}) {
    if (_prefs == null) return false;
    
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return false;
    
    if (maxAge != null) {
      final timestamp = _prefs!.getInt('${key}_timestamp') ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      return age <= maxAge.inMilliseconds;
    }
    
    return true;
  }

  // Get cache age
  static Duration? getCacheAge(String key) {
    if (_prefs == null) return null;
    
    final timestamp = _prefs!.getInt('${key}_timestamp');
    if (timestamp == null) return null;
    
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    return Duration(milliseconds: age);
  }

  // Cache size estimation
  static int getCacheSize() {
    if (_prefs == null) return 0;
    
    int totalSize = 0;
    for (String key in _prefs!.getKeys()) {
      final value = _prefs!.get(key);
      if (value is String) {
        totalSize += value.length;
      }
    }
    return totalSize;
  }

  // Cache statistics
  static Map<String, dynamic> getCacheStats() {
    if (_prefs == null) return {};
    
    final keys = _prefs!.getKeys();
    final dataKeys = keys.where((key) => 
        !key.endsWith('_timestamp') && !key.endsWith('_expiration')).toList();
    
    return {
      'total_keys': keys.length,
      'data_keys': dataKeys.length,
      'cache_size_bytes': getCacheSize(),
      'cache_keys': dataKeys,
    };
  }
}
