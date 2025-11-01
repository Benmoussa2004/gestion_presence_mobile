import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/attendance_model.dart';
import '../api/api_client.dart';

class AttendanceRepository {
  const AttendanceRepository();

  Future<String> markAttendance(AttendanceModel model) async {
    final http.Response res = await ApiClient.post('/attendances', model.toMap());
    if (res.statusCode >= 400) throw StateError('API markAttendance failed: ${res.statusCode} ${res.body}');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['id'] ?? data['_id'] ?? '') as String;
  }

  /// Upsert attendance by (sessionId, studentId)
  Future<void> setAttendanceStatus({
    required String sessionId,
    required String studentId,
    required String status,
    required DateTime markedAt,
  }) async {
    final res = await ApiClient.post('/attendances/upsert', {
      'sessionId': sessionId,
      'studentId': studentId,
      'status': status,
      'markedAt': markedAt.toIso8601String(),
    });
    if (res.statusCode >= 400) {
      throw StateError('API setAttendanceStatus failed: ${res.statusCode} ${res.body}');
    }
  }

  Stream<List<AttendanceModel>> watchForSession(String sessionId) {
    return Stream<List<AttendanceModel>>.periodic(const Duration(seconds: 2)).asyncMap((_) async {
      final res = await ApiClient.get('/attendances', query: {'sessionId': sessionId});
      if (res.statusCode >= 400) throw StateError('API watchForSession failed: ${res.statusCode}');
      final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      return list.map((m) => AttendanceModel.fromMap((m['id'] ?? m['_id'] ?? '').toString(), m)).toList();
    });
  }
}
