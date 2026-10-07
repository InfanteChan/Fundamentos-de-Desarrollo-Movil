import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/mappers/user_mapper.dart';
import 'package:pizzeria/models/user_profile.dart';

abstract class AuthDatasource {
  Future<UserProfile> signUpBuyer({
    required String email,
    required String password,
    required String fullName,
  });

  Future<UserProfile> signUpSeller({
    required String email,
    required String password,
    required String fullName,
    required String restaurantName,
  });

  Future<UserProfile> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserProfile?> getCurrentUserProfile();
}

class SupabaseAuthDatasource implements AuthDatasource {
  final SupabaseClient _client;

  SupabaseAuthDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<UserProfile> signUpBuyer({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: 'comprador',
    );
    return _loadProfile(fallbackRole: 'comprador');
  }

  @override
  Future<UserProfile> signUpSeller({
    required String email,
    required String password,
    required String fullName,
    required String restaurantName,
  }) async {
    final user = await _signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: 'vendedor',
    );

    try {
      await _client.from('restaurants').insert({
        'seller_id': user.id,
        'name': restaurantName,
        'description': 'Pizzería artesanal e italiana',
        'address': 'Ciudad de México, Centro',
        'latitude': 19.432608,
        'longitude': -99.133209,
        'phone': '555-0199',
        'image_url':
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
      });
    } catch (e) {
      debugPrint('No se pudo crear la pizzería: $e');
      throw Exception('Tu cuenta se creó, pero no se pudo crear la pizzería');
    }

    return _loadProfile(fallbackRole: 'vendedor');
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw Exception(_translateAuthError(e.message));
    }
    return _loadProfile();
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (data != null) return UserMapper.fromMap(data);
    } catch (e) {
      debugPrint('Error al leer el perfil: $e');
    }

    // Respaldo: usar los datos guardados al registrarse
    return UserProfile(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name']?.toString() ??
          user.email?.split('@').first ??
          'Usuario',
      role: user.userMetadata?['role']?.toString() ?? 'comprador',
      createdAt: DateTime.now(),
    );
  }

  // ---------- Auxiliares ----------

  Future<User> _signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': role},
      );
      final user = response.user;
      if (user == null) throw Exception('No se pudo registrar el usuario');
      if (response.session == null) {
        throw Exception('Cuenta creada. Confirma tu correo para continuar');
      }
      return user;
    } on AuthException catch (e) {
      throw Exception(_translateAuthError(e.message));
    }
  }

  Future<UserProfile> _loadProfile({String fallbackRole = 'comprador'}) async {
    final profile = await getCurrentUserProfile();
    if (profile == null) throw Exception('No se pudo cargar tu perfil');
    return profile;
  }

  String _translateAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (m.contains('already registered') || m.contains('already been registered')) {
      return 'Ese correo ya está registrado';
    }
    if (m.contains('password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    if (m.contains('email not confirmed')) {
      return 'Debes confirmar tu correo antes de entrar';
    }
    return message;
  }
}