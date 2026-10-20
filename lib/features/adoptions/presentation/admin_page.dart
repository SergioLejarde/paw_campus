import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/presentation/app_feedback.dart';
import '../../lost_pets/data/lost_pets_repository.dart';
import '../../sos/data/sos_repository.dart';
import '../data/pets_repository.dart';

/// Provider que obtiene todas las mascotas pendientes de adopción
final pendingPetsProvider = FutureProvider.autoDispose((ref) async {
  final repo = PetsRepository();
  return repo.fetchPendingPets();
});

class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(pendingPetsProvider);
    final sosReportsAsync = ref.watch(allSosReportsAdminProvider);
    final lostPetsAsync = ref.watch(allLostPetsAdminProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel de Administración 🛠️'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          actions: [
            if (user != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Text(
                    user.email ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.pets),
                text: '🐾 Adopciones',
              ),
              Tab(
                icon: Icon(Icons.campaign, color: Color(0xFFE11D48)),
                text: '🚨 SOS',
              ),
              Tab(
                icon: Icon(Icons.location_on, color: Color(0xFF0D9488)),
                text: '📍 Perdidos',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: Adopciones Pendientes
            _buildPendingPetsTab(context, ref, petsAsync),

            // TAB 2: Denuncias de Maltrato SOS
            _buildSosReportsTab(context, ref, sosReportsAsync),

            // TAB 3: Animales Perdidos / Encontrados
            _buildLostPetsTab(context, ref, lostPetsAsync),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: MASCOTAS PENDIENTES
  // ==========================================
  Widget _buildPendingPetsTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Pet>> petsAsync,
  ) {
    return petsAsync.when(
      data: (pets) {
        if (pets.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No hay mascotas pendientes por aprobar 🐶',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(pendingPetsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () => context.push('/pet/${pet.id}'),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(pet.photoUrl),
                    radius: 26,
                  ),
                  title: Text(
                    pet.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${pet.species} • ${pet.age} años\n${pet.description}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        tooltip: 'Aprobar mascota',
                        onPressed: () async {
                          await _updatePetStatus(context, pet.id, 'approved');
                          ref.invalidate(pendingPetsProvider);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'Rechazar mascota',
                        onPressed: () async {
                          await _updatePetStatus(context, pet.id, 'rejected');
                          ref.invalidate(pendingPetsProvider);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '⚠️ Error cargando mascotas:\n$e',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: DENUNCIAS DE MALTRATO ANIMAL SOS
  // ==========================================
  Widget _buildSosReportsTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AbuseReport>> reportsAsync,
  ) {
    return reportsAsync.when(
      data: (reports) {
        if (reports.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No hay denuncias registradas en el sistema 🛡️',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ref.refresh(allSosReportsAdminProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildAdminSosCard(context, ref, report);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '⚠️ Error cargando denuncias SOS:\n$e',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminSosCard(
    BuildContext context,
    WidgetRef ref,
    AbuseReport report,
  ) {
    final isCritica = report.urgencyLevel == 'Crítica';
    final urgencyColor =
        isCritica ? const Color(0xFFE11D48) : const Color(0xFFEA580C);

    final (statusLabel, statusColor) = switch (report.status) {
      'pending_review' => (
          'Pendiente de Revisión',
          const Color(0xFFD97706),
        ),
      'in_progress' => ('En Gestión', const Color(0xFF0284C7)),
      'public_alert' => ('Alerta Pública Activa', const Color(0xFFE11D48)),
      'resolved' => ('Caso Resuelto', const Color(0xFF0D9488)),
      'rejected' => ('Descartado', const Color(0xFF64748B)),
      _ => (report.status, const Color(0xFF64748B)),
    };

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Urgencia y Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: urgencyColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 15, color: urgencyColor),
                      const SizedBox(width: 4),
                      Text(
                        'Urgencia: ${report.urgencyLevel}',
                        style: TextStyle(
                          color: urgencyColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tipo de Caso y Ubicación
            Text(
              report.abuseType,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 15, color: Color(0xFF0D9488)),
                const SizedBox(width: 4),
                Text(
                  '${report.municipality} • ${report.neighborhood}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Foto de evidencia si existe
            if (report.photoUrl != null && report.photoUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  report.photoUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80,
                    color: const Color(0xFFF1F5F9),
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image,
                        color: Color(0xFF94A3B8)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Descripción
            Text(
              report.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),

            // Dirección Privada / Notas confidenciales (Exclusivo Admin)
            if (report.addressNotes != null &&
                report.addressNotes!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lock_rounded,
                        size: 16, color: Color(0xFFB45309)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dirección exacta / Referencia confidencial:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            report.addressNotes!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF78350F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Datos del denunciante
            Row(
              children: [
                Icon(
                  report.isAnonymous ? Icons.visibility_off : Icons.person,
                  size: 14,
                  color: const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  report.isAnonymous
                      ? 'Denunciante Anónimo'
                      : 'Contacto: ${report.reporterContact ?? "Usuario registrado"}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Botones de Acción de Moderación
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (report.status != 'public_alert')
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 34),
                    ),
                    icon: const Icon(Icons.campaign, size: 16),
                    label: const Text(
                      'Publicar como Alerta',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _updateSosReportStatus(
                      context,
                      ref,
                      report.id,
                      'public_alert',
                    ),
                  ),
                if (report.status != 'in_progress')
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0284C7),
                      side: const BorderSide(color: Color(0xFF0284C7)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 34),
                    ),
                    icon: const Icon(Icons.sync_rounded, size: 16),
                    label: const Text(
                      'En Gestión',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _updateSosReportStatus(
                      context,
                      ref,
                      report.id,
                      'in_progress',
                    ),
                  ),
                if (report.status != 'resolved')
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0D9488),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 34),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text(
                      'Resolver',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _updateSosReportStatus(
                      context,
                      ref,
                      report.id,
                      'resolved',
                    ),
                  ),
                if (report.status != 'rejected')
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 34),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text(
                      'Descartar',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _updateSosReportStatus(
                      context,
                      ref,
                      report.id,
                      'rejected',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Función auxiliar para aprobar/rechazar mascotas
  Future<void> _updatePetStatus(
    BuildContext context,
    String petId,
    String newStatus,
  ) async {
    final repo = PetsRepository();
    try {
      AppFeedback.showLoadingDialog(
        context,
        message: 'Actualizando estado de la mascota...',
      );
      await repo.updatePetStatus(petId, newStatus);
      if (!context.mounted) return;
      AppFeedback.hideLoadingDialog(context);
      AppFeedback.showSuccess(
        context,
        newStatus == 'approved'
            ? 'Mascota aprobada correctamente'
            : 'Mascota rechazada correctamente',
      );
    } catch (e) {
      if (context.mounted) {
        AppFeedback.hideLoadingDialog(context);
        AppFeedback.showError(context, e);
      }
    }
  }

  /// Función auxiliar para actualizar el estado de reportes SOS
  Future<void> _updateSosReportStatus(
    BuildContext context,
    WidgetRef ref,
    String reportId,
    String newStatus,
  ) async {
    final repo = ref.read(sosRepositoryProvider);
    try {
      AppFeedback.showLoadingDialog(
        context,
        message: 'Actualizando estado de la denuncia...',
      );
      await repo.updateReportStatus(reportId, newStatus);
      ref.invalidate(allSosReportsAdminProvider);
      ref.invalidate(publicSosAlertsProvider);
      if (!context.mounted) return;
      AppFeedback.hideLoadingDialog(context);

      final statusMsg = switch (newStatus) {
        'public_alert' => 'Publicada como Alerta de Rescate comunitaria',
        'in_progress' => 'Marcada en gestión por el equipo',
        'resolved' => 'Marcada como resuelta',
        'rejected' => 'Denuncia descartada',
        _ => 'Estado actualizado',
      };
      AppFeedback.showSuccess(context, statusMsg);
    } catch (e) {
      if (context.mounted) {
        AppFeedback.hideLoadingDialog(context);
        AppFeedback.showError(context, e);
      }
    }
  }

  // ==========================================
  // TAB 3: ANIMALES PERDIDOS / ENCONTRADOS
  // ==========================================
  Widget _buildLostPetsTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LostPetReport>> lostPetsAsync,
  ) {
    return lostPetsAsync.when(
      data: (reports) {
        if (reports.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No hay reportes de animales perdidos o encontrados 📍',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(allLostPetsAdminProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildAdminLostPetCard(context, ref, report);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '⚠️ Error cargando reportes:\n$e',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminLostPetCard(
    BuildContext context,
    WidgetRef ref,
    LostPetReport report,
  ) {
    final isFlagged = report.status == 'flagged';
    final isResolved = report.status == 'resolved';
    final isLost = report.isLost;

    final (statusLabel, statusColor, statusBg) = switch (report.status) {
      'flagged' => (
          '⚠️ Reportado como indebido',
          const Color(0xFFE11D48),
          const Color(0xFFFFE4E6)
        ),
      'resolved' => (
          '🎉 Resuelto (¡Ya apareció!)',
          const Color(0xFF0D9488),
          const Color(0xFFCCFBF1)
        ),
      _ => (
          '✅ Activo en el mapa',
          const Color(0xFF059669),
          const Color(0xFFD1FAE5)
        ),
    };

    return Card(
      elevation: isFlagged ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isFlagged
            ? const BorderSide(color: Color(0xFFE11D48), width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Tipo de alerta y Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLost
                        ? const Color(0xFFFFF1F2)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isLost ? '🔴 Mascota Perdida' : '🟢 Avistado / Encontrado',
                    style: TextStyle(
                      color: isLost
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF059669),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Nombre y especie
            Text(
              '${report.petName} (${report.species})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),

            // Ubicación
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 15, color: Color(0xFF0D9488)),
                const SizedBox(width: 4),
                Text(
                  '${report.neighborhood}, ${report.municipality}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Foto si existe
            if (report.photoUrl != null && report.photoUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  report.photoUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Descripción
            Text(
              report.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),

            // Teléfono de contacto
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  'Contacto: ${report.contactPhone}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Acciones de Moderación para el Admin
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (isFlagged || isResolved)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 34),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text(
                      'Restaurar como Activo',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _updateLostPetStatus(
                      context,
                      ref,
                      report.id,
                      'active',
                    ),
                  ),
                if (!isResolved)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0D9488),
                      side: const BorderSide(color: Color(0xFF0D9488)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 34),
                    ),
                    icon: const Icon(Icons.celebration_outlined, size: 16),
                    label: const Text(
                      'Marcar Resuelto',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _updateLostPetStatus(
                      context,
                      ref,
                      report.id,
                      'resolved',
                    ),
                  ),
                if (!isFlagged)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE11D48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 34),
                    ),
                    icon: const Icon(Icons.flag_outlined, size: 16),
                    label: const Text(
                      'Marcar Indebido',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _updateLostPetStatus(
                      context,
                      ref,
                      report.id,
                      'flagged',
                    ),
                  ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF94A3B8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 34),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text(
                    'Eliminar',
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: () => _deleteLostPetReport(
                    context,
                    ref,
                    report.id,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Función auxiliar para actualizar el estado de reportes de perdidos
  Future<void> _updateLostPetStatus(
    BuildContext context,
    WidgetRef ref,
    String reportId,
    String newStatus,
  ) async {
    final repo = ref.read(lostPetsRepositoryProvider);
    try {
      AppFeedback.showLoadingDialog(
        context,
        message: 'Actualizando reporte...',
      );
      await repo.updateReportStatus(reportId, newStatus);
      ref.invalidate(allLostPetsAdminProvider);
      ref.invalidate(activeLostPetsProvider);
      if (!context.mounted) return;
      AppFeedback.hideLoadingDialog(context);

      final msg = switch (newStatus) {
        'active' => 'Reporte reactivado en el mapa público',
        'resolved' => 'Reporte marcado como resuelto',
        'flagged' => 'Reporte marcado como indebido',
        _ => 'Estado actualizado',
      };
      AppFeedback.showSuccess(context, msg);
    } catch (e) {
      if (context.mounted) {
        AppFeedback.hideLoadingDialog(context);
        AppFeedback.showError(context, e);
      }
    }
  }

  /// Función auxiliar para eliminar definitivamente un reporte de perdidos
  Future<void> _deleteLostPetReport(
    BuildContext context,
    WidgetRef ref,
    String reportId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar reporte'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este reporte de forma permanente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final repo = ref.read(lostPetsRepositoryProvider);
      try {
        AppFeedback.showLoadingDialog(context, message: 'Eliminando...');
        await repo.deleteReport(reportId);
        ref.invalidate(allLostPetsAdminProvider);
        ref.invalidate(activeLostPetsProvider);
        if (!context.mounted) return;
        AppFeedback.hideLoadingDialog(context);
        AppFeedback.showSuccess(context, 'Reporte eliminado correctamente');
      } catch (e) {
        if (context.mounted) {
          AppFeedback.hideLoadingDialog(context);
          AppFeedback.showError(context, e);
        }
      }
    }
  }
}
