import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider global para acceder fácilmente al repositorio de autenticación.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = Supabase.instance.client;
  return AuthRepository(supabase);
});

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  /// Registro de usuario con correo y contraseña
  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  /// Inicio de sesión
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  /// Cierre de sesión
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Devuelve el usuario autenticado actual
  User? get currentUser => _supabase.auth.currentUser;
}
