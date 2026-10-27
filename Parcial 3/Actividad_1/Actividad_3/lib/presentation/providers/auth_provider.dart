import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/datasources/auth_datasource.dart';
import 'package:pizzeria/models/user_profile.dart';

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  return SupabaseAuthDatasource();
});

class AuthNotifier extends AsyncNotifier<UserProfile?> {
  AuthDatasource get _datasource => ref.read(authDatasourceProvider);

  @override
  Future<UserProfile?> build() async {
    // Escucha cambios de sesión y se cancela al destruir el provider
    final sub = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.initialSession) return;
      if (data.session?.user == null) {
        state = const AsyncData(null);
      } else {
        state = AsyncData(await _datasource.getCurrentUserProfile());
      }
    });
    ref.onDispose(sub.cancel);

    return _datasource.getCurrentUserProfile();
  }

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) {
    return _run(() => _datasource.signIn(email: email, password: password));
  }

  Future<UserProfile> signUpBuyer({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _run(() => _datasource.signUpBuyer(
          email: email,
          password: password,
          fullName: fullName,
        ));
  }

  Future<UserProfile> signUpSeller({
    required String email,
    required String password,
    required String fullName,
    required String restaurantName,
  }) {
    return _run(() => _datasource.signUpSeller(
          email: email,
          password: password,
          fullName: fullName,
          restaurantName: restaurantName,
        ));
  }

  Future<void> signOut() async {
    await _datasource.signOut();
    state = const AsyncData(null);
  }

  // Ejecuta una acción y actualiza el estado; si falla, relanza el error
  // sin dejar la pantalla en "cargando".
  Future<UserProfile> _run(Future<UserProfile> Function() action) async {
    final profile = await action();
    state = AsyncData(profile);
    return profile;
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, UserProfile?>(AuthNotifier.new);