import 'dart:async';

import '../../data/repositories/auth_repository.dart';

class AuthController {
  final AuthRepository _auth;
  const AuthController(this._auth);

  Future<void> signIn(String email, String password) {
    return _auth.signInWithEmail(email, password);
  }

  Future<void> signOut() => _auth.signOut();

  /// Creates the auth user and persists the profile document in Firestore.
  /// Adds a timeout for the profile write so the UI does not get stuck.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    Duration profileWriteTimeout = const Duration(seconds: 8),
  }) async {
    await _auth.signUpWithEmail(name, email, password, role);
  }
}
