import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/profile.dart';

class ProfileRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  User? _safeCurrentUser() {
    try {
      return _supabase.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Obtiene el perfil del usuario autenticado actual
  Future<UserProfile?> getCurrentProfile() async {
    final user = _safeCurrentUser();
    if (user == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  /// Obtiene el perfil por id
  Future<UserProfile?> getProfileById(String id) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  /// Crea el perfil inicial luego del registro
  Future<void> createProfileForUser({
    required String userId,
    required String email,
  }) async {
    await _supabase.from('profiles').insert({'id': userId, 'email': email});
  }

  /// Actualiza campos del perfil del usuario actual
  Future<UserProfile> updateCurrentProfile({
    String? name,
    String? phone,
    String? photoUrl,
    String? city,
  }) async {
    final user = _safeCurrentUser();
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (photoUrl != null) updates['photo_url'] = photoUrl;
    if (city != null) updates['city'] = city;

    final response = await _supabase
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
  // 📸 Subir foto de perfil (WEB + MOBILE correcto)
  // ============================================================
  Future<String> uploadProfilePhoto(XFile file) async {
    final user = _safeCurrentUser();
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    final ext = file.name.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final filePath = 'avatars/${user.id}/$fileName';

    final storage = _supabase.storage.from('avatars');

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      await storage.uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
    } else {
      final fileBytes = await file.readAsBytes();
      await storage.uploadBinary(
        filePath,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );
    }

    return storage.getPublicUrl(filePath);
  }
}
