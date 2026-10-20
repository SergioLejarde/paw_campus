import 'package:flutter_test/flutter_test.dart';
import 'package:paw_campus/features/lost_pets/data/lost_pets_repository.dart';

void main() {
  group('LostPetReport Model', () {
    test('serializes and deserializes correctly', () {
      final now = DateTime(2026, 10, 20, 15, 0);
      final report = LostPetReport(
        id: 'lost-test-1',
        reportType: 'lost',
        petName: 'Max',
        species: 'Perro',
        municipality: 'Bucaramanga',
        neighborhood: 'Cabecera',
        description: 'Golden Retriever macho extraviado en San Pío',
        photoUrl: 'https://example.com/max.jpg',
        contactPhone: '3187654321',
        latitude: 7.1186,
        longitude: -73.1108,
        status: 'active',
        createdBy: 'user-123',
        createdAt: now,
      );

      final json = report.toJson();
      expect(json['id'], 'lost-test-1');
      expect(json['report_type'], 'lost');
      expect(json['pet_name'], 'Max');
      expect(json['species'], 'Perro');
      expect(json['municipality'], 'Bucaramanga');
      expect(json['neighborhood'], 'Cabecera');
      expect(json['description'], 'Golden Retriever macho extraviado en San Pío');
      expect(json['photo_url'], 'https://example.com/max.jpg');
      expect(json['contact_phone'], '3187654321');
      expect(json['latitude'], 7.1186);
      expect(json['longitude'], -73.1108);
      expect(json['status'], 'active');
      expect(json['created_by'], 'user-123');

      final fromJson = LostPetReport.fromJson(json);
      expect(fromJson.id, report.id);
      expect(fromJson.reportType, report.reportType);
      expect(fromJson.petName, report.petName);
      expect(fromJson.species, report.species);
      expect(fromJson.municipality, report.municipality);
      expect(fromJson.neighborhood, report.neighborhood);
      expect(fromJson.description, report.description);
      expect(fromJson.photoUrl, report.photoUrl);
      expect(fromJson.contactPhone, report.contactPhone);
      expect(fromJson.latitude, report.latitude);
      expect(fromJson.longitude, report.longitude);
      expect(fromJson.status, report.status);
      expect(fromJson.createdBy, report.createdBy);
    });

    test('helpers, getters and phone formatting work as expected', () {
      final lostReport = LostPetReport(
        id: 'lost-1',
        reportType: 'lost',
        petName: 'Toby',
        species: 'Perro',
        municipality: 'Floridablanca',
        neighborhood: 'Cañaveral',
        description: 'Perrito perdido',
        contactPhone: '315 123-4567',
        status: 'active',
        createdAt: DateTime.now(),
      );

      expect(lostReport.isLost, true);
      expect(lostReport.isFound, false);
      expect(lostReport.isActive, true);
      expect(lostReport.isResolved, false);
      expect(lostReport.isFlagged, false);
      expect(lostReport.typeLabel, 'Perdido');
      expect(lostReport.cleanWhatsappPhone, '573151234567');
      expect(lostReport.latLng.latitude, 7.1193);
      expect(lostReport.latLng.longitude, -73.1227);

      final foundReport = lostReport.copyWith(
        reportType: 'found',
        status: 'resolved',
      );
      expect(foundReport.isLost, false);
      expect(foundReport.isFound, true);
      expect(foundReport.isResolved, true);
      expect(foundReport.typeLabel, 'Avistado / Encontrado');
    });
  });

  group('LostPetsRepository', () {
    test('provides initial realistic Bucaramanga seed cases', () async {
      final repo = LostPetsRepository();
      final activeReports = await repo.fetchActiveLostPets();

      expect(activeReports.isNotEmpty, true);
      expect(activeReports.length, greaterThanOrEqualTo(4));

      // Verificar distribución en AMB
      final municipalities =
          activeReports.map((r) => r.municipality).toSet();
      expect(municipalities.contains('Bucaramanga'), true);
      expect(municipalities.contains('Floridablanca'), true);

      // Verificar que todos los reportes iniciales estén activos
      expect(activeReports.every((r) => r.isActive), true);
    });

    test('submits new report with active status immediately', () async {
      final repo = LostPetsRepository();
      final newReport = LostPetReport(
        id: 'test-immediate-live',
        reportType: 'found',
        petName: 'Gatito blanco en parque',
        species: 'Gato',
        municipality: 'Girón',
        neighborhood: 'El Poblado',
        description: 'Gatito bebé resguardado',
        contactPhone: '3001234567',
        latitude: 7.0684,
        longitude: -73.1698,
        createdAt: DateTime.now(),
      );

      await repo.submitReport(newReport);

      final active = await repo.fetchActiveLostPets();
      final found = active.any((r) => r.id == 'test-immediate-live');
      expect(found, true);
    });

    test('marks report as resolved and updates status', () async {
      final repo = LostPetsRepository();
      await repo.markAsResolved('lost-seed-san-pio');

      final allReports = await repo.fetchAllLostPetsAdmin();
      final report =
          allReports.firstWhere((r) => r.id == 'lost-seed-san-pio');
      expect(report.status, 'resolved');
    });

    test('flags report as inappropriate', () async {
      final repo = LostPetsRepository();
      await repo.flagInappropriateReport('lost-seed-ninos');

      final allReports = await repo.fetchAllLostPetsAdmin();
      final report =
          allReports.firstWhere((r) => r.id == 'lost-seed-ninos');
      expect(report.status, 'flagged');
      expect(report.isFlagged, true);
    });

    test('deletes report from repository', () async {
      final repo = LostPetsRepository();
      await repo.deleteReport('lost-seed-real-minas');

      final allReports = await repo.fetchAllLostPetsAdmin();
      final found = allReports.any((r) => r.id == 'lost-seed-real-minas');
      expect(found, false);
    });
  });
}
