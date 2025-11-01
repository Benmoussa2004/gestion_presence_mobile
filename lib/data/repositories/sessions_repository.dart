import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/session_model.dart';
import '../api/api_client.dart';

class SessionsRepository {
  const SessionsRepository();

  Future<String> createSession(SessionModel model) async {
    final http.Response res = await ApiClient.post('/sessions', model.toMap());
    if (res.statusCode >= 400) throw StateError('API createSession failed: ${res.statusCode} ${res.body}');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['id'] ?? data['_id'] ?? '') as String;
  }

  Future<void> updateSession(SessionModel model) async {
    final res = await ApiClient.put('/sessions/${model.id}', model.toMap());
    if (res.statusCode >= 400) throw StateError('API updateSession failed: ${res.statusCode} ${res.body}');
  }

  Future<void> deleteSession(String id) async {
    final res = await ApiClient.delete('/sessions/$id');
    if (res.statusCode >= 400) throw StateError('API deleteSession failed: ${res.statusCode} ${res.body}');
  }

  Stream<List<SessionModel>> watchSessionsForClass(String classId) {
    return Stream<List<SessionModel>>.periodic(const Duration(seconds: 2)).asyncMap((_) async {
      final res = await ApiClient.get('/sessions', query: {'classId': classId});
      if (res.statusCode >= 400) throw StateError('API watchSessionsForClass failed: ${res.statusCode}');
      final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      return list.map((m) => SessionModel.fromMap((m['id'] ?? m['_id'] ?? '').toString(), m)).toList();
    });
  }
}
