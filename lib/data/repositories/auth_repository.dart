import 'dart:async';
import 'dart:convert';

import '../api/api_client.dart';
import '../api/auth_token.dart';
import '../models/auth_user.dart';

class AuthRepository {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _current;

  Stream<AuthUser?> authStateChanges() => _controller.stream;

  Future<void> signInWithEmail(String email, String password) async {
    final res = await ApiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });
    if (res.statusCode >= 400) {
      throw StateError('Login échoué: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['token'] as String?;
    final user = data['user'] as Map<String, dynamic>?;
    if (token == null || user == null) {
      throw StateError('Réponse invalide du serveur');
    }
    AuthTokenStore.token = token;
    _current = AuthUser(uid: (user['id'] ?? user['_id']).toString(), email: user['email'] as String?);
    _controller.add(_current);
  }

  Future<void> signUpWithEmail(String name, String email, String password, String role) async {
    final res = await ApiClient.post('/auth/signup', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
    if (res.statusCode >= 400) {
      throw StateError('Inscription échouée: ${res.statusCode} ${res.body}');
    }
    // Optionnel: auto-login
    await signInWithEmail(email, password);
  }

  Future<void> signOut() async {
    AuthTokenStore.token = null;
    _current = null;
    _controller.add(null);
  }
}
