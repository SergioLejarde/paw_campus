import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/pet.dart';

export '../domain/pet.dart';

/// Instancia global de Supabase
final supabase = Supabase.instance.client;

/// Repositorio central de mascotas (CRUD + filtros)
class PetsRepository {
  /// Inserta una nueva mascota (solo usuarios autenticados)
  Future<void> addPet({
    required String name,
    required String species,
    required int age,
    required String description,
    required String photoUrl,
    String city = 'Bucaramanga',
    String? neighborhood,
    String size = 'Mediano',
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final fullData = {
      'name': name,
      'species': species,
      'age': age,
      'description': description,
      'photo_url': photoUrl,
      'created_by': user.id,
      'status': 'pending',
      'city': city,
      if (neighborhood != null && neighborhood.isNotEmpty)
        'neighborhood': neighborhood,
      'size': size,
    };

    try {
      await supabase.from('pets').insert(fullData);
    } catch (_) {
      // Si la tabla pets aún no tiene las columnas city, neighborhood o size,
      // reintenta con el esquema base para garantizar que nunca falle.
      await supabase.from('pets').insert({
        'name': name,
        'species': species,
        'age': age,
        'description': description,
        'photo_url': photoUrl,
        'created_by': user.id,
        'status': 'pending',
      });
    }
  }

  /// Obtiene las mascotas aprobadas (visibles al público)
  Future<List<Pet>> fetchApprovedPets() async {
    final List<dynamic> response = await supabase
        .from('pets')
        .select()
        .eq('status', 'approved')
        .order('created_at', ascending: false);

    return response
        .map((item) => Pet.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene las mascotas subidas por el usuario autenticado
  Future<List<Pet>> fetchMyPets() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final List<dynamic> response = await supabase
        .from('pets')
        .select()
        .eq('created_by', user.id)
        .order('created_at', ascending: false);

    return response
        .map((item) => Pet.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene todas las mascotas (sin filtro de estado)
  Future<List<Pet>> getAllPets() async {
    final List<dynamic> response = await supabase
        .from('pets')
        .select()
        .order('created_at', ascending: false);

    return response
        .map((item) => Pet.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene las mascotas pendientes (solo admin)
  Future<List<Pet>> fetchPendingPets() async {
    final List<dynamic> response = await supabase
        .from('pets')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return response
        .map((item) => Pet.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// 🔍 Obtiene mascota por ID (para la pantalla de detalle)
  Future<Pet?> getPetById(String id) async {
    final List<dynamic> response = await supabase
        .from('pets')
        .select()
        .eq('id', id)
        .limit(1);

    if (response.isEmpty) return null;

    return Pet.fromJson(response.first);
  }

  /// 🟢 Actualiza el estado de una mascota (approved o rejected)
  Future<void> updatePetStatus(String id, String newStatus) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final List<dynamic> response = await supabase
        .from('pets')
        .update({'status': newStatus})
        .eq('id', id)
        .select(); // devuelve filas afectadas

    if (response.isEmpty) {
      throw Exception('No se encontró la mascota o no se pudo actualizar.');
    }
  }

  /// Cambia el estado de una mascota a 'approved' (versión simplificada)
  Future<void> approvePet(String id) async {
    await updatePetStatus(id, 'approved');
  }
}
