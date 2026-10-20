import 'package:flutter_test/flutter_test.dart';
import 'package:paw_campus/features/sos/data/sos_repository.dart';

void main() {
  group('AbuseReport Model', () {
    test('serializes and deserializes correctly', () {
      final now = DateTime(2026, 10, 20, 10, 30);
      final report = AbuseReport(
        id: 'test-1',
        urgencyLevel: 'Crítica',
        abuseType: 'Animal herido en vía pública',
        municipality: 'Bucaramanga',
        neighborhood: 'Cabecera',
        addressNotes: 'Cra 33 con calle 48',
        description: 'Perrito herido requiere auxilio urgente',
        photoUrl: 'https://example.com/photo.jpg',
        isAnonymous: true,
        status: 'pending_review',
        createdAt: now,
      );

      final json = report.toJson();
      expect(json['id'], 'test-1');
      expect(json['urgency_level'], 'Crítica');
      expect(json['abuse_type'], 'Animal herido en vía pública');
      expect(json['municipality'], 'Bucaramanga');
      expect(json['neighborhood'], 'Cabecera');
      expect(json['address_notes'], 'Cra 33 con calle 48');
      expect(json['description'], 'Perrito herido requiere auxilio urgente');
      expect(json['is_anonymous'], true);
      expect(json['status'], 'pending_review');

      final fromJson = AbuseReport.fromJson(json);
      expect(fromJson.id, report.id);
      expect(fromJson.urgencyLevel, report.urgencyLevel);
      expect(fromJson.abuseType, report.abuseType);
      expect(fromJson.municipality, report.municipality);
      expect(fromJson.neighborhood, report.neighborhood);
      expect(fromJson.addressNotes, report.addressNotes);
      expect(fromJson.description, report.description);
      expect(fromJson.photoUrl, report.photoUrl);
      expect(fromJson.isAnonymous, report.isAnonymous);
      expect(fromJson.status, report.status);
    });

    test('copyWith updates properties properly', () {
      final original = AbuseReport(
        id: 'test-2',
        urgencyLevel: 'Alta',
        abuseType: 'Abandono severo',
        municipality: 'Floridablanca',
        neighborhood: 'Cañaveral',
        description: 'Cachorros en parque',
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        status: 'public_alert',
        urgencyLevel: 'Crítica',
      );

      expect(updated.id, original.id);
      expect(updated.status, 'public_alert');
      expect(updated.urgencyLevel, 'Crítica');
      expect(updated.abuseType, original.abuseType);
    });
  });

  group('SosRepository Fallback', () {
    test('provides initial public alerts safely in memory', () async {
      final repo = SosRepository();
      // Since Supabase isn't initialized with mock credentials in test runner,
      // it falls back gracefully to in-memory alerts
      final alerts = await repo.fetchPublicAlerts();
      expect(alerts.isNotEmpty, true);
      expect(alerts.every((a) => a.status == 'public_alert'), true);
      expect(alerts.any((a) => a.municipality == 'Bucaramanga'), true);
    });

    test('updates status in memory fallback', () async {
      final repo = SosRepository();
      final allReports = await repo.fetchAllReportsForAdmin();
      expect(allReports.isNotEmpty, true);

      final firstId = allReports.first.id;
      await repo.updateReportStatus(firstId, 'resolved');

      final refreshed = await repo.fetchAllReportsForAdmin();
      final updatedReport = refreshed.firstWhere((r) => r.id == firstId);
      expect(updatedReport.status, 'resolved');
    });
  });
}
