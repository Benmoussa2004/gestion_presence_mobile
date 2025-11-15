import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/dev_flags.dart';
import 'auth_token.dart';

class ApiClient {
  static final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 25);

  /// URL CLOUD du backend
  /// - définie via DevFlags.apiBase
  /// - sinon l'utilisateur DOIT configurer l'URL dans dev_flags.dart
  static String get baseUrl {
    if (DevFlags.apiBase.isEmpty) {
      throw StateError(
        '❌ API_BASE_URL non configurée.\n'
        '➡️ Définis-la dans dev_flags.dart ou via --dart-define.\n'
        'Exemple : flutter run --dart-define=API_BASE_URL=https://mon-api.com'
      );
    }
    return DevFlags.apiBase;
  }

  /// Construction propre de l’URI
  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse(baseUrl + normalized)
        .replace(queryParameters: query);
  }

  /// Ajout du token si présent
  static Future<Map<String, String>> _headers() async {
    final headers = {'Content-Type': 'application/json'};
    final token = AuthTokenStore.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // -------------------------
  // HTTP METHODS
  // -------------------------

  static Future<http.Response> get(String path,
      {Map<String, dynamic>? query}) async {
    final uri = _uri(path, query);
    return await _client
        .get(uri, headers: await _headers())
        .timeout(_timeout);
  }

  static Future<http.Response> post(
      String path, Map<String, dynamic> body) async {
    final uri = _uri(path);
    return await _client
        .post(uri, headers: await _headers(), body: jsonEncode(body))
        .timeout(_timeout);
  }

  static Future<http.Response> put(
      String path, Map<String, dynamic> body) async {
    final uri = _uri(path);
    return await _client
        .put(uri, headers: await _headers(), body: jsonEncode(body))
        .timeout(_timeout);
  }

  static Future<http.Response> delete(String path) async {
    final uri = _uri(path);
    return await _client
        .delete(uri, headers: await _headers())
        .timeout(_timeout);
  }
}
