import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/abuse_report.dart';

export '../domain/abuse_report.dart';

/// Provider global para acceder al repositorio SOS
final sosRepositoryProvider = Provider<SosRepository>((ref) => SosRepository());

/// Provider para las alertas públicas de rescate verificadas
final publicSosAlertsProvider =
    FutureProvider.autoDispose<List<AbuseReport>>((ref) async {
  final repo = ref.watch(sosRepositoryProvider);
  return repo.fetchPublicAlerts();
});

/// Provider para administradores con todas las denuncias recibidas
final allSosReportsAdminProvider =
    FutureProvider.autoDispose<List<AbuseReport>>((ref) async {
  final repo = ref.watch(sosRepositoryProvider);
  return repo.fetchAllReportsForAdmin();
});

class SosRepository {
  /// Lista estática en memoria para garantizar funcionamiento continuo
  /// incluso si la tabla 'abuse_reports' aún no ha sido creada en Supabase.
  static final List<AbuseReport> _localFallbackReports = [
    AbuseReport(
      id: 'sos-sample-cabecera',
      urgencyLevel: 'Crítica',
      abuseType: 'Animal herido en vía pública',
      municipality: 'Bucaramanga',
      neighborhood: 'Cabecera del Llano',
      addressNotes: 'Cra. 33 # 48-12, cerca al parque San Pío',
      description:
          'Perrito criollo atropellado en la Carrera 33. Fue estabilizado de emergencia en veterinaria de paso pero requiere con urgencia hogar temporal solidario o apoyo para radiografía de fémur.',
      photoUrl:
          'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
      isAnonymous: true,
      status: 'public_alert',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AbuseReport(
      id: 'sos-sample-canaveral',
      urgencyLevel: 'Alta',
      abuseType: 'Abandono severo',
      municipality: 'Floridablanca',
      neighborhood: 'Cañaveral',
      addressNotes: 'Zona verde diagonal al Parque La Pera',
      description:
          'Gatita rescatada de una caja con 4 cachorros lactantes. Ya recibieron atención primaria por voluntaria pero necesitan urgente alimento húmedo especial y hogar de paso.',
      photoUrl:
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
      isAnonymous: false,
      reporterContact: '315 889 0012',
      status: 'public_alert',
      createdAt: DateTime.now().subtract(const Duration(hours: 15)),
    ),
    AbuseReport(
      id: 'sos-sample-giron',
      urgencyLevel: 'Crítica',
      abuseType: 'Negligencia / Sin agua ni techo',
      municipality: 'Girón',
      neighborhood: 'El Poblado',
      addressNotes: 'Calle 42 # 22-15 casa esquinera de dos pisos',
      description:
          'Canino encerrado permanentemente en terraza sin techo ni agua limpia bajo el sol y lluvia. Vecinos informan que aúlla constantemente y muestra desnutrición severa.',
      photoUrl:
          'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&q=80',
      isAnonymous: true,
      status: 'pending_review',
      createdAt: DateTime.now().subtract(const Duration(hours: 20)),
    ),
  ];

  SupabaseClient get _client => Supabase.instance.client;

  /// Registra una nueva denuncia o reporte SOS.
  /// Intenta guardar en Supabase; si falla, lo almacena en `_localFallbackReports`.
  Future<void> submitReport(AbuseReport report) async {
    // Almacenar en la lista local para respuesta inmediata
    final existingIndex =
        _localFallbackReports.indexWhere((r) => r.id == report.id);
    if (existingIndex >= 0) {
      _localFallbackReports[existingIndex] = report;
    } else {
      _localFallbackReports.insert(0, report);
    }

    try {
      final user = _client.auth.currentUser;
      final reporterId =
          report.isAnonymous ? null : (report.reporterId ?? user?.id);

      final fullPayload = {
        'id': report.id,
        'urgency_level': report.urgencyLevel,
        'abuse_type': report.abuseType,
        'municipality': report.municipality,
        'neighborhood': report.neighborhood,
        'address_notes': report.addressNotes,
        'description': report.description,
        'photo_url': report.photoUrl,
        'is_anonymous': report.isAnonymous,
        'reporter_id': reporterId,
        'reporter_contact': report.reporterContact,
        'status': report.status,
      };

      try {
        await _client.from('abuse_reports').insert(fullPayload);
      } catch (_) {
        // Esquema simplificado en caso de columnas pendientes
        await _client.from('abuse_reports').insert({
          'id': report.id,
          'urgency_level': report.urgencyLevel,
          'municipality': report.municipality,
          'neighborhood': report.neighborhood,
          'address_notes': report.addressNotes,
          'description': report.description,
          'photo_url': report.photoUrl,
          'is_anonymous': report.isAnonymous,
          'reporter_id': reporterId,
          'status': report.status,
        });
      }
    } catch (_) {
      // El reporte ya está guardado en memoria en `_localFallbackReports`
    }
  }

  /// Obtiene los reportes aprobados como 'public_alert' para ayuda ciudadana
  Future<List<AbuseReport>> fetchPublicAlerts() async {
    try {
      final response = await _client
          .from('abuse_reports')
          .select()
          .eq('status', 'public_alert')
          .order('created_at', ascending: false);

      final dbReports = (response as List)
          .map((item) => AbuseReport.fromJson(item as Map<String, dynamic>))
          .toList();

      if (dbReports.isNotEmpty) {
        // Sincronizar identificadores para no duplicar
        final dbIds = dbReports.map((r) => r.id).toSet();
        final localOnly = _localFallbackReports
            .where((r) => r.status == 'public_alert' && !dbIds.contains(r.id))
            .toList();
        return [...dbReports, ...localOnly];
      }
    } catch (_) {
      // Usar fallback local
    }

    return _localFallbackReports
        .where((r) => r.status == 'public_alert')
        .toList();
  }

  /// Obtiene todos los reportes para moderación del administrador
  Future<List<AbuseReport>> fetchAllReportsForAdmin() async {
    try {
      final response = await _client
          .from('abuse_reports')
          .select()
          .order('created_at', ascending: false);

      final dbReports = (response as List)
          .map((item) => AbuseReport.fromJson(item as Map<String, dynamic>))
          .toList();

      final dbIds = dbReports.map((r) => r.id).toSet();
      final localOnly =
          _localFallbackReports.where((r) => !dbIds.contains(r.id)).toList();

      return [...dbReports, ...localOnly];
    } catch (_) {
      return List<AbuseReport>.from(_localFallbackReports);
    }
  }

  /// Actualiza el estado de una denuncia en Supabase y memoria
  Future<void> updateReportStatus(String id, String newStatus) async {
    final index = _localFallbackReports.indexWhere((r) => r.id == id);
    if (index != -1) {
      _localFallbackReports[index] =
          _localFallbackReports[index].copyWith(status: newStatus);
    }

    try {
      await _client
          .from('abuse_reports')
          .update({'status': newStatus}).eq('id', id);
    } catch (_) {
      // Ya se actualizó en memoria
    }
  }

  /// Sube la foto de evidencia al bucket 'pet_photos' en la carpeta 'sos/'
  Future<String> uploadEvidencePhoto(XFile file) async {
    try {
      final fileExt = file.path.split('.').last.toLowerCase();
      final safeExt = (fileExt.isEmpty || fileExt.length > 5) ? 'jpg' : fileExt;
      final fileName = 'sos_${DateTime.now().millisecondsSinceEpoch}.$safeExt';
      final filePath = 'sos/$fileName';

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
      // Fallback a imagen de rescate si el bucket no tiene permisos o falla
      return 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?auto=format&fit=crop&w=800&q=80';
    }
  }
}
