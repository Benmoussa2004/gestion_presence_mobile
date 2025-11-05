import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/app_user.dart';
import 'models/auth_user.dart';
import 'repositories/auth_repository.dart';
import 'repositories/users_repository.dart';
import 'repositories/classes_repository.dart';
import 'repositories/sessions_repository.dart';
import 'repositories/attendance_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final usersRepositoryProvider = Provider<UsersRepository>((ref) => UsersRepository());
final classesRepositoryProvider = Provider<ClassesRepository>((ref) => ClassesRepository());
final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) => SessionsRepository());
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) => AttendanceRepository());

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserDocProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return const Stream.empty();
  }
  return ref.watch(usersRepositoryProvider).watchUser(user.uid);
});
/// URL de ton serveur Node.js
final apiBaseUrlProvider = Provider<String>(
  (_) => 'http://localhost:3000', // ✅ pour Flutter Web (Chrome)
);
