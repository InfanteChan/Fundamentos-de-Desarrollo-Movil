import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  User? get usuarioActual => _auth.currentUser;

  Future<AuthResponse> registrar({
    required String nombre,
    required String email,
    required String password,
  }) {
    return _auth.signUp(
      email: email,
      password: password,
      data: {'nombre': nombre},
    );
  }

  Future<AuthResponse> iniciarSesion({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> cerrarSesion() => _auth.signOut();
}