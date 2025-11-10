import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/config/dev_flags.dart';
import 'auth_token.dart';

class ApiClient {
  static final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 30);

  static String _defaultBase() {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.165.216.47:3000';
    } catch (_) {
      // ignore platform check errors
    }
    return 'http://localhost:3000';
  }

  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = DevFlags.apiBaseUrl.isNotEmpty ? DevFlags.apiBaseUrl : _defaultBase();
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
    return _client.get(uri, headers: await _headers()).timeout(_timeout);
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = _uri(path);
    return _client.post(uri, headers: await _headers(), body: jsonEncode(body)).timeout(_timeout);
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final uri = _uri(path);
    return _client.put(uri, headers: await _headers(), body: jsonEncode(body)).timeout(_timeout);
  }

  static Future<http.Response> delete(String path) async {
    final uri = _uri(path);
    return _client.delete(uri, headers: await _headers()).timeout(_timeout);
  }
}
