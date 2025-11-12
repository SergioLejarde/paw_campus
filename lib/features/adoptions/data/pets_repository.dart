import 'package:supabase_flutter/supabase_flutter.dart';

/// Instancia global de Supabase
final supabase = Supabase.instance.client;

/// Modelo de datos para una mascota (id = uuid en Supabase)
class Pet {
  final String id; // uuid
  final String name;
  final String species;
  final int age;
  final String description;
  final String photoUrl;
  final String status;
  final String createdBy; // uuid de auth.users

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.age,
    required this.description,
    required this.photoUrl,
    required this.status,
    required this.createdBy,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        id: (json['id'] ?? '').toString(),
        name: json['name'] ?? '',
        species: json['species'] ?? '',
        age: (json['age'] ?? 0) is int
            ? json['age']
            : int.tryParse('${json['age']}') ?? 0,
        description: json['description'] ?? '',
        photoUrl: json['photo_url'] ?? '',
        status: json['status'] ?? 'pending',
        createdBy: (json['created_by'] ?? '').toString(),
      );
}

/// Repositorio central de mascotas (CRUD + filtros)
class PetsRepository {
  /// Inserta una nueva mascota (solo usuarios autenticados)
  Future<void> addPet({
    required String name,
    required String species,
    required int age,
    required String description,
    required String photoUrl,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

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

  /// ✅ Actualiza el estado de una mascota (approved o rejected)
  Future<void> updatePetStatus(String id, String newStatus) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final List<dynamic> response = await supabase
        .from('pets')
        .update({'status': newStatus})
        .eq('id', id)
        .select(); // ✅ devuelve las filas actualizadas

    if (response.isEmpty) {
      // Si no se afectó ninguna fila (id inexistente o sin permisos)
      throw Exception('No se encontró la mascota o no se pudo actualizar.');
    }

    // Si llega aquí, el update fue exitoso ✅
  }

  /// Cambia el estado de una mascota a 'approved' (versión simplificada)
  Future<void> approvePet(String id) async {
    await updatePetStatus(id, 'approved');
  }
}
