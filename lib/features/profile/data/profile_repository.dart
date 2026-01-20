import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/profile.dart';

final supabase = Supabase.instance.client;

class ProfileRepository {
  /// Obtiene el perfil del usuario autenticado actual
  Future<UserProfile?> getCurrentProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  /// Obtiene el perfil por id (por ejemplo, dueño de una mascota)
  Future<UserProfile?> getProfileById(String id) async {
    final response =
        await supabase.from('profiles').select().eq('id', id).maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  /// Crea el perfil inicial luego de un registro
  Future<void> createProfileForUser({
    required String userId,
    required String email,
  }) async {
    await supabase.from('profiles').insert({
      'id': userId,
      'email': email,
    });
  }

  /// Actualiza campos del perfil del usuario actual
  Future<UserProfile> updateCurrentProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (photoUrl != null) updates['photo_url'] = photoUrl;

    final response = await supabase
        .from('profiles')
        .update(updates)
        .eq('id', user.id)
        .select()
        .maybeSingle();

    if (response == null) {
      throw Exception('No se pudo actualizar el perfil');
    }

    return UserProfile.fromJson(response);
  }

  // ============================================================
  // 🔥 NUEVO: Subir foto de perfil a Supabase Storage
  // ============================================================
  Future<String> uploadProfilePhoto(File file) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    final filePath = 'avatars/${user.id}.png';

    await supabase.storage.from('avatars').upload(
          filePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl =
        supabase.storage.from('avatars').getPublicUrl(filePath);

    return publicUrl;
  }
}
