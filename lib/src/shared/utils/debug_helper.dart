import 'package:flutter/foundation.dart';

class DebugHelper {
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] ${tag ?? 'DEBUG'}: $message');
    }
  }

  static void logError(String error, {StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] ${tag ?? 'ERROR'}: $error');
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  static void logApiCall(String method, String url, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      log('API $method: $url', tag: 'API');
      if (data != null) {
        log('Data: $data', tag: 'API');
      }
    }
  }

  static void logNavigation(String from, String to) {
    log('Navigation: $from -> $to', tag: 'NAV');
  }

  static Map<String, dynamic> getSystemInfo() {
    return {
      'isDebug': kDebugMode,
      'isWeb': kIsWeb,
      'platform': defaultTargetPlatform.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
