import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/dev_flags.dart';
import 'auth_token.dart';

class ApiClient {
  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = DevFlags.apiBase;
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse(base + normalized).replace(queryParameters: query);
  }

  static Future<Map<String, String>> _headers() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = AuthTokenStore.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> get(String path, {Map<String, dynamic>? query}) async {
    final uri = _uri(path, query);
    return http.get(uri, headers: await _headers());
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = _uri(path);
    return http.post(uri, headers: await _headers(), body: jsonEncode(body));
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final uri = _uri(path);
    return http.put(uri, headers: await _headers(), body: jsonEncode(body));
  }

  static Future<http.Response> delete(String path) async {
    final uri = _uri(path);
    return http.delete(uri, headers: await _headers());
  }
}
