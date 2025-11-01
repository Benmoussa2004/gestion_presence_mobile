import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import '../api/api_client.dart';

class UsersRepository {
  const UsersRepository();

  Future<void> setUser(AppUser user) async {
    final http.Response res = await ApiClient.put('/users/${user.id}', user.toMap());
    if (res.statusCode >= 400) {
      throw StateError('API setUser failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<AppUser?> getUser(String uid) async {
    final res = await ApiClient.get('/users/$uid');
    if (res.statusCode == 404) return null;
    if (res.statusCode >= 400) {
      throw StateError('API getUser failed: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return AppUser.fromMap(data['id'] as String? ?? uid, data);
  }

  Stream<AppUser?> watchUser(String uid) {
    return Stream<AppUser?>.periodic(const Duration(seconds: 2))
        .asyncMap((_) => getUser(uid));
  }

  Stream<List<AppUser>> watchUsersByRole(String role) {
    return Stream<List<AppUser>>.periodic(const Duration(seconds: 2))
        .asyncMap((_) => getUsersByRole(role));
  }

  Future<List<AppUser>> getUsersByRole(String role) async {
    final res = await ApiClient.get('/users', query: {'role': role});
    if (res.statusCode >= 400) {
      throw StateError('API getUsersByRole failed: ${res.statusCode} ${res.body}');
    }
    final list = (jsonDecode(res.body) as List)
        .cast<Map<String, dynamic>>();
    return list.map((m) => AppUser.fromMap(m['id'] as String? ?? (m['_id']?.toString() ?? ''), m)).toList();
  }

  Future<List<AppUser>> findByEmails(List<String> emails) async {
    if (emails.isEmpty) return [];
    final res = await ApiClient.post('/users/by-emails', {'emails': emails});
    if (res.statusCode >= 400) {
      throw StateError('API findByEmails failed: ${res.statusCode} ${res.body}');
    }
    final list = (jsonDecode(res.body) as List)
        .cast<Map<String, dynamic>>();
    return list.map((m) => AppUser.fromMap(m['id'] as String? ?? (m['_id']?.toString() ?? ''), m)).toList();
  }
}
