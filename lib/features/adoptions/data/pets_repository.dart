import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// Modelo de datos simple para una mascota
class Pet {
  final int id;
  final String name;
  final String species;
  final int age;
  final String description;
  final String photoUrl;
  final String status;
  final String createdBy;

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
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        species: json['species'] ?? '',
        age: json['age'] ?? 0,
        description: json['description'] ?? '',
        photoUrl: json['photo_url'] ?? '',
        status: json['status'] ?? 'pending',
        createdBy: json['created_by'] ?? '',
      );
}

/// Repositorio de mascotas con operaciones CRUD básicas
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
    });
  }

  /// Obtiene las mascotas aprobadas
  Future<List<Pet>> fetchApprovedPets() async {
    final List<dynamic> response = await supabase
        .from('pets')
        .select()
        .eq('status', 'approved')
        .order('created_at', ascending: false);

    return response.map((item) => Pet.fromJson(item)).toList();
  }

  /// (Opcional) Obtiene todas las mascotas (sin filtro de estado)
  Future<List<Pet>> getAllPets() async {
    final List<dynamic> response =
        await supabase.from('pets').select().order('created_at', ascending: false);

    return response.map((item) => Pet.fromJson(item)).toList();
  }

  /// (Opcional) Cambia el estado de una mascota (solo admin)
  Future<void> approvePet(int id) async {
    await supabase.from('pets').update({'status': 'approved'}).eq('id', id);
  }
}
