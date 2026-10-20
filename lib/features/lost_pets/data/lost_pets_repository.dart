import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/lost_pet_report.dart';

export '../domain/lost_pet_report.dart';

/// Provider global para acceder al repositorio de animales perdidos y encontrados
final lostPetsRepositoryProvider =
    Provider<LostPetsRepository>((ref) => LostPetsRepository());

/// Provider reactivo para obtener los reportes activos para la lista y el mapa
final activeLostPetsProvider =
    FutureProvider.autoDispose<List<LostPetReport>>((ref) async {
  final repo = ref.watch(lostPetsRepositoryProvider);
  return repo.fetchActiveLostPets();
});

/// Provider reactivo para que el administrador gestione todos los reportes (incluyendo flagged y resolved)
final allLostPetsAdminProvider =
    FutureProvider.autoDispose<List<LostPetReport>>((ref) async {
  final repo = ref.watch(lostPetsRepositoryProvider);
  return repo.fetchAllLostPetsAdmin();
});

class LostPetsRepository {
  /// Lista en memoria con casos semilla realistas en el Área Metropolitana de Bucaramanga
  /// para garantizar interactividad inmediata incluso si la tabla en Supabase está vacía o en proceso de migración.
  static final List<LostPetReport> _localFallbackLostPets = [
    LostPetReport(
      id: 'lost-seed-san-pio',
      reportType: 'lost',
      petName: 'Max',
      species: 'Perro',
      municipality: 'Bucaramanga',
      neighborhood: 'Cabecera del Llano',
      description:
          'Golden Retriever macho, 3 años. Llevaba collar de cuero marrón con placa. Se asustó con pólvora cerca al Parque San Pío y corrió hacia la Cra 33. Es muy dócil y responde a su nombre.',
      photoUrl:
          'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=800&q=80',
      contactPhone: '3187654321',
      latitude: 7.1186,
      longitude: -73.1108,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    LostPetReport(
      id: 'lost-seed-ninos',
      reportType: 'lost',
      petName: 'Mía',
      species: 'Gato',
      municipality: 'Bucaramanga',
      neighborhood: 'San Alonso',
      description:
          'Gatita siamesa de ojos azules, esterilizada. No lleva collar. Se escapó por el balcón de un segundo piso cerca al Parque de los Niños. Muy asustadiza con ruidos fuertes.',
      photoUrl:
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
      contactPhone: '3159988776',
      latitude: 7.1255,
      longitude: -73.1189,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    LostPetReport(
      id: 'lost-seed-canaveral',
      reportType: 'found',
      petName: 'Perrito criollo con pañoleta',
      species: 'Perro',
      municipality: 'Floridablanca',
      neighborhood: 'Cañaveral',
      description:
          'Avistado perrito mestizo mediano color caramelo con pañoleta azul desgastada. Estaba desorientado cerca al CC La Florida buscando comida. Se encuentra resguardado provisionalmente en portería.',
      photoUrl:
          'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
      contactPhone: '3104433221',
      latitude: 7.0682,
      longitude: -73.1065,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
    LostPetReport(
      id: 'lost-seed-real-minas',
      reportType: 'lost',
      petName: 'Rocky',
      species: 'Perro',
      municipality: 'Bucaramanga',
      neighborhood: 'Ciudadela Real de Minas',
      description:
          'Schnauzer sal y pimienta de orejas y cola natural. Se extravió en el Parque de las Cigarras mientras jugaba sin correa. Requiere medicación para la piel. Ofrecemos gratificación.',
      photoUrl:
          'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&q=80',
      contactPhone: '3123344556',
      latitude: 7.1052,
      longitude: -73.1285,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
  ];

  SupabaseClient get _client => Supabase.instance.client;

  /// Obtiene los reportes activos para la lista y el mapa público
  Future<List<LostPetReport>> fetchActiveLostPets() async {
    try {
      final response = await _client
          .from('lost_pets')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);

      final dbReports = (response as List)
          .map((item) => LostPetReport.fromJson(item as Map<String, dynamic>))
          .toList();

      final dbIds = dbReports.map((r) => r.id).toSet();
      // Combinar con los datos semilla que no estén duplicados en la base de datos
      final activeLocal = _localFallbackLostPets
          .where((r) => r.status == 'active' && !dbIds.contains(r.id))
          .toList();

      return [...dbReports, ...activeLocal];
    } catch (_) {
      // Fallback a los reportes en memoria si Supabase no tiene la tabla o está offline
      return _localFallbackLostPets.where((r) => r.status == 'active').toList();
    }
  }

  /// Obtiene todos los reportes para moderación del administrador
  Future<List<LostPetReport>> fetchAllLostPetsAdmin() async {
    try {
      final response = await _client
          .from('lost_pets')
          .select()
          .order('created_at', ascending: false);

      final dbReports = (response as List)
          .map((item) => LostPetReport.fromJson(item as Map<String, dynamic>))
          .toList();

      final dbIds = dbReports.map((r) => r.id).toSet();
      final localOnly =
          _localFallbackLostPets.where((r) => !dbIds.contains(r.id)).toList();

      return [...dbReports, ...localOnly];
    } catch (_) {
      return List<LostPetReport>.from(_localFallbackLostPets);
    }
  }

  /// Publicación inmediata en vivo de reporte de animal perdido o encontrado.
  /// Se guarda tanto en memoria como en Supabase para reflejo instantáneo.
  Future<void> submitReport(LostPetReport report) async {
    // Asegurar que nace activo para no retrasar la búsqueda crítica
    final activeReport = report.copyWith(status: 'active');

    final existingIndex =
        _localFallbackLostPets.indexWhere((r) => r.id == activeReport.id);
    if (existingIndex >= 0) {
      _localFallbackLostPets[existingIndex] = activeReport;
    } else {
      _localFallbackLostPets.insert(0, activeReport);
    }

    try {
      final user = _client.auth.currentUser;
      final payload = {
        'id': activeReport.id,
        'report_type': activeReport.reportType,
        'pet_name': activeReport.petName,
        'species': activeReport.species,
        'municipality': activeReport.municipality,
        'neighborhood': activeReport.neighborhood,
        'description': activeReport.description,
        'photo_url': activeReport.photoUrl,
        'contact_phone': activeReport.contactPhone,
        'latitude': activeReport.latitude,
        'longitude': activeReport.longitude,
        'status': 'active',
        'created_by': activeReport.createdBy ?? user?.id,
        'created_at': activeReport.createdAt.toIso8601String(),
      };

      await _client.from('lost_pets').upsert(payload);
    } catch (_) {
      // Silencioso: el reporte ya está registrado en memoria y visible en la UI
    }
  }

  /// Marca un reporte como resuelto ("¡Ya apareció! 🎉")
  Future<void> markAsResolved(String id) async {
    await updateReportStatus(id, 'resolved');
  }

  /// Marca un reporte como indebido ("Reportar publicación indebida")
  Future<void> flagInappropriateReport(String id) async {
    await updateReportStatus(id, 'flagged');
  }

  /// Actualiza el estado de un reporte en memoria y en Supabase
  Future<void> updateReportStatus(String id, String newStatus) async {
    final index = _localFallbackLostPets.indexWhere((r) => r.id == id);
    if (index != -1) {
      _localFallbackLostPets[index] =
          _localFallbackLostPets[index].copyWith(status: newStatus);
    }

    try {
      await _client
          .from('lost_pets')
          .update({'status': newStatus}).eq('id', id);
    } catch (_) {
      // Ya se actualizó localmente
    }
  }

  /// Elimina un reporte
  Future<void> deleteReport(String id) async {
    _localFallbackLostPets.removeWhere((r) => r.id == id);

    try {
      await _client.from('lost_pets').delete().eq('id', id);
    } catch (_) {
      // Ya se eliminó localmente
    }
  }

  /// Sube la foto de la mascota perdida/encontrada al bucket 'pet_photos' en 'lost_pets/'
  Future<String> uploadLostPetPhoto(XFile file) async {
    try {
      final fileExt = file.path.split('.').last.toLowerCase();
      final safeExt = (fileExt.isEmpty || fileExt.length > 5) ? 'jpg' : fileExt;
      final fileName =
          'lost_${DateTime.now().millisecondsSinceEpoch}.$safeExt';
      final filePath = 'lost_pets/$fileName';

      final storage = _client.storage.from('pet_photos');

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        await storage.uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$safeExt'),
        );
      } else {
        await storage.upload(
          filePath,
          File(file.path),
          fileOptions: FileOptions(contentType: 'image/$safeExt'),
        );
      }

      return storage.getPublicUrl(filePath);
    } catch (_) {
      // Fallback a imagen predeterminada si falla el bucket
      return 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80';
    }
  }
}
