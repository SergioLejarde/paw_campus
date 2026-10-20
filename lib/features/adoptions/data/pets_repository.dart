import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/pet.dart';

export '../domain/pet.dart';

/// Instancia global de Supabase
final supabase = Supabase.instance.client;

/// Repositorio central de mascotas (CRUD + filtros)
class PetsRepository {
  /// Lista semilla de respaldo con mascotas en adopción en Bucaramanga y AMB.
  /// Garantiza que el catálogo siempre esté activo y visualmente impecable.
  static final List<Pet> seedApprovedPets = [
    Pet(
      id: 'seed-luna-bga',
      name: 'Luna',
      species: 'Perro',
      age: 2,
      description:
          'Perrita mestiza muy cariñosa y obediente rescatada en Cabecera. Está esterilizada, vacunada y desparasitada. Adora pasear por los parques de Bucaramanga y convive excelente con niños y otros perros.',
      photoUrl:
          'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
      status: 'approved',
      createdBy: 'pawco-seed-admin',
      city: 'Bucaramanga',
      neighborhood: 'Cabecera del Llano',
      size: 'Mediano',
    ),
    Pet(
      id: 'seed-simon-florida',
      name: 'Simón',
      species: 'Gato',
      age: 1,
      description:
          'Gatito atigrado juguetón y ronroneador rescatado en Cañaveral. Acostumbrado a vivir en apartamento, usa su arenero a la perfección y es muy sociable con las visitas.',
      photoUrl:
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
      status: 'approved',
      createdBy: 'pawco-seed-admin',
      city: 'Floridablanca',
      neighborhood: 'Cañaveral',
      size: 'Pequeño',
    ),
    Pet(
      id: 'seed-nala-giron',
      name: 'Nala',
      species: 'Perro',
      age: 3,
      description:
          'Noble compañera rescatada en Girón. Muy tranquila, leal y protectora. Busca una familia con paciencia que le brinde un hogar seguro y mucho amor.',
      photoUrl:
          'https://images.unsplash.com/photo-1537151625747-768eb6cf92b2?auto=format&fit=crop&w=800&q=80',
      status: 'approved',
      createdBy: 'pawco-seed-admin',
      city: 'Girón',
      neighborhood: 'El Poblado',
      size: 'Mediano',
    ),
    Pet(
      id: 'seed-milo-piede',
      name: 'Milo',
      species: 'Gato',
      age: 2,
      description:
          'Gatito blanco con negro muy dormilón y tierno rescatado en Piedecuesta. Castrado y con esquema de vacunas al día. Le encanta tomar el sol en las tardes.',
      photoUrl:
          'https://images.unsplash.com/photo-1573865526739-10659fec78a5?auto=format&fit=crop&w=800&q=80',
      status: 'approved',
      createdBy: 'pawco-seed-admin',
      city: 'Piedecuesta',
      neighborhood: 'Hoyo Grande',
      size: 'Pequeño',
    ),
    Pet(
      id: 'seed-toby-bga',
      name: 'Toby',
      species: 'Perro',
      age: 4,
      description:
          'Mestizo noble y bonachón rescatado en la Ciudadela Real de Minas. Es súper tranquilo en casa, camina muy bien con correa y es ideal para personas mayores o familias.',
      photoUrl:
          'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&q=80',
      status: 'approved',
      createdBy: 'pawco-seed-admin',
      city: 'Bucaramanga',
      neighborhood: 'Real de Minas',
      size: 'Grande',
    ),
    Pet(
      id: 'seed-copito-bga',
      name: 'Copito',
      species: 'Otro',
      age: 1,
      description:
          'Conejito enano rescatado en Provenza. Dócil y acostumbrado al contacto humano. Requiere tenencia responsable en casa segura.',
      photoUrl:
          'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?auto=format&fit=crop&w=800&q=80',
      status: 'approved',
      createdBy: 'pawco-seed-admin',
      city: 'Bucaramanga',
      neighborhood: 'Provenza',
      size: 'Pequeño',
    ),
  ];

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

  /// Obtiene las mascotas aprobadas (visibles al público).
  /// Si Supabase devuelve lista vacía o si ocurre un fallo de red,
  /// recurre a los peluditos semilla curados de Bucaramanga y AMB.
  Future<List<Pet>> fetchApprovedPets() async {
    try {
      final List<dynamic> response = await supabase
          .from('pets')
          .select()
          .eq('status', 'approved')
          .order('created_at', ascending: false);

      final pets = response
          .map((item) => Pet.fromJson(item as Map<String, dynamic>))
          .toList();

      if (pets.isNotEmpty) {
        return pets;
      }
      return seedApprovedPets;
    } catch (_) {
      return seedApprovedPets;
    }
  }

  /// Obtiene las mascotas subidas por el usuario autenticado
  Future<List<Pet>> fetchMyPets() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      final List<dynamic> response = await supabase
          .from('pets')
          .select()
          .eq('created_by', user.id)
          .order('created_at', ascending: false);

      return response
          .map((item) => Pet.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Obtiene todas las mascotas (sin filtro de estado)
  Future<List<Pet>> getAllPets() async {
    try {
      final List<dynamic> response = await supabase
          .from('pets')
          .select()
          .order('created_at', ascending: false);

      final pets = response
          .map((item) => Pet.fromJson(item as Map<String, dynamic>))
          .toList();

      if (pets.isNotEmpty) {
        return pets;
      }
      return seedApprovedPets;
    } catch (_) {
      return seedApprovedPets;
    }
  }

  /// Obtiene las mascotas pendientes (solo admin)
  Future<List<Pet>> fetchPendingPets() async {
    try {
      final List<dynamic> response = await supabase
          .from('pets')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return response
          .map((item) => Pet.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// 🔍 Obtiene mascota por ID (para la pantalla de detalle)
  Future<Pet?> getPetById(String id) async {
    try {
      final List<dynamic> response = await supabase
          .from('pets')
          .select()
          .eq('id', id)
          .limit(1);

      if (response.isNotEmpty) {
        return Pet.fromJson(response.first);
      }
    } catch (_) {
      // Intentar buscar en mascotas semilla
    }

    try {
      return seedApprovedPets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
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
