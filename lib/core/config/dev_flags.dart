import 'package:flutter/foundation.dart';

/// Dev flags controlled via --dart-define at runtime.
///
/// Examples:
/// - flutter run --dart-define=FORCE_ROLE=teacher
/// - flutter run --dart-define=FORCE_ROUTE=/classes
class DevFlags {
  /// FORCE_ROLE values: 'admin' | 'teacher' | 'student' | ''
  static const String forceRole = String.fromEnvironment('FORCE_ROLE');

  /// FORCE_ROUTE values: '/classes' | '/attendance' | '/login' | ...
  static const String forceRoute = String.fromEnvironment('FORCE_ROUTE');

  /// BACKEND: 'firebase' (default) or 'api'
  static const String backend = String.fromEnvironment('BACKEND');

  /// API base URL, e.g. http://192.168.1.10:3000
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get hasForceRole => forceRole.isNotEmpty;
  static bool get hasForceRoute => forceRoute.isNotEmpty;
  static bool get useApi => backend.toLowerCase() == 'api';
  static String get apiBase => apiBaseUrl.isNotEmpty ? apiBaseUrl : 'http://10.165.216.47:3000';

  /// Simple helper for local debug logs if needed.
  static void debugLog(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[DevFlags] $message');
    }
  }
}
