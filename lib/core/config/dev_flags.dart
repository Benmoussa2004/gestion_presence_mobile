import 'package:flutter/foundation.dart';

/// Dev flags controlled via --dart-define at runtime.
/// Exemple :
/// flutter run --dart-define=API_BASE_URL=https://mon-backend.onrender.com
class DevFlags {
  /// Role forcé (debug)
  static const String forceRole = String.fromEnvironment('FORCE_ROLE');

  /// Route forcée (debug)
  static const String forceRoute = String.fromEnvironment('FORCE_ROUTE');

  /// BACKEND: 'api' ou 'firebase' (debug)
  static const String backend = String.fromEnvironment('BACKEND');

  /// URL du backend cloud passée via --dart-define
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Use API backend ?
  static bool get useApi => backend.toLowerCase() == 'api';

  /// URL de base utilisée par ApiClient
  /// ❗ Obligatoire pour une app cloud
  static String get apiBase {
    if (apiBaseUrl.isNotEmpty) {
      return apiBaseUrl;
    }

    // ⚠️ Default fallback cloud (à personnaliser)
    return "https://TON_BACKEND_CLOUD_URL.com";
  }

  /// Simple helper logs
  static void debugLog(String message) {
    if (kDebugMode) {
      print('[DevFlags] $message');
    }
  }
}
