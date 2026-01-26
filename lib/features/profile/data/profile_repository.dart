import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:image_picker/image_picker.dart';
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

  /// Obtiene el perfil por id
  Future<UserProfile?> getProfileById(String id) async {
    final response = await supabase
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
    await supabase.from('profiles').insert({'id': userId, 'email': email});
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
  // 📸 Subir foto de perfil (WEB + MOBILE correcto)
  // ============================================================
  Future<String> uploadProfilePhoto(XFile file) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    final ext = file.name.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final filePath = 'avatars/${user.id}/$fileName';

    final storage = supabase.storage.from('avatars');

    if (kIsWeb) {
      // 🌍 WEB → subir bytes
      final bytes = await file.readAsBytes();
      await storage.uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
    } else {
      // 📱 MOBILE → usar File sin romper Web
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
