import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paw_campus/app/theme.dart';
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
    User? user;
    try {
      user = Supabase.instance.client.auth.currentUser;
    } catch (_) {
      user = null;
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: PawCoColors.background,
        appBar: AppBar(
          backgroundColor: PawCoColors.auroraStart,
          foregroundColor: Colors.white,
          title: Text(
            'Panel de Administración 🛠️',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          actions: [
            if (user?.email != null && MediaQuery.of(context).size.width >= 520)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Text(
                    user!.email!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: PawCoColors.lilacGlow,
                    ),
                  ),
                ),
              ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: PawCoColors.lilacGlow.withValues(alpha: 0.7),
            indicatorColor: PawCoColors.malva,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.pets_rounded),
                text: '🐾 Adopciones',
              ),
              Tab(
                icon: Icon(Icons.campaign_rounded, color: PawCoColors.malva),
                text: '🚨 SOS',
              ),
              Tab(
                icon: Icon(
                  Icons.location_on_rounded,
                  color: PawCoColors.lilacGlow,
                ),
                text: '📍 Perdidos',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPendingPetsTab(context, ref, petsAsync),
            _buildSosReportsTab(context, ref, sosReportsAsync),
            _buildLostPetsTab(context, ref, lostPetsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPetsTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Pet>> petsAsync,
  ) {
    return petsAsync.when(
      data: (pets) {
        if (pets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No hay mascotas pendientes por aprobar 🐶',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: PawCoColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: PawCoColors.plum,
          onRefresh: () async => ref.refresh(pendingPetsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: PawCoColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: PawCoColors.border),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: () => context.push('/pet/${pet.id}'),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: pet.photoUrl.isNotEmpty
                            ? Image.network(
                                pet.photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: PawCoColors.cottonLilac,
                                  child: const Icon(
                                    Icons.pets_rounded,
                                    color: PawCoColors.plum,
                                  ),
                                ),
                              )
                            : Container(
                                color: PawCoColors.cottonLilac,
                                child: const Icon(
                                  Icons.pets_rounded,
                                  color: PawCoColors.plum,
                                ),
                              ),
                      ),
                    ),
                    title: Text(
                      pet.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        color: PawCoColors.ink,
                      ),
                    ),
                    subtitle: Text(
                      '${pet.species} • ${pet.age} años\n${pet.description}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: PawCoColors.muted,
                      ),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle_rounded,
                            color: PawCoColors.plum,
                          ),
                          tooltip: 'Aprobar mascota',
                          onPressed: () async {
                            await _updatePetStatus(
                              context,
                              pet.id,
                              'approved',
                            );
                            ref.invalidate(pendingPetsProvider);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.cancel_rounded,
                            color: PawCoColors.error,
                          ),
                          tooltip: 'Rechazar mascota',
                          onPressed: () async {
                            await _updatePetStatus(
                              context,
                              pet.id,
                              'rejected',
                            );
                            ref.invalidate(pendingPetsProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: PawCoColors.plum),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '⚠️ Error cargando mascotas:\n$e',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: PawCoColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildSosReportsTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AbuseReport>> reportsAsync,
  ) {
    return reportsAsync.when(
      data: (reports) {
        if (reports.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No hay denuncias registradas en el sistema 🛡️',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: PawCoColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: PawCoColors.plum,
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
      loading: () => const Center(
        child: CircularProgressIndicator(color: PawCoColors.plum),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '⚠️ Error cargando denuncias SOS:\n$e',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: PawCoColors.error),
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
        isCritica ? PawCoColors.terracottaDark : PawCoColors.malva;

    final (statusLabel, statusColor) = switch (report.status) {
      'pending_review' => ('Pendiente de Revisión', const Color(0xFFD97706)),
      'in_progress' => ('En Gestión', PawCoColors.plumVibrant),
      'public_alert' => ('Alerta Pública Activa', PawCoColors.malva),
      'resolved' => ('Caso Resuelto', PawCoColors.plum),
      'rejected' => ('Descartado', PawCoColors.muted),
      _ => (report.status, PawCoColors.muted),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PawCoColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PawCoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 15,
                      color: urgencyColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Urgencia: ${report.urgencyLevel}',
                      style: GoogleFonts.plusJakartaSans(
                        color: urgencyColor,
                        fontWeight: FontWeight.w800,
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
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.plusJakartaSans(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report.abuseType,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: PawCoColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 15,
                color: PawCoColors.plum,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${report.municipality} • ${report.neighborhood}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PawCoColors.inkSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (report.photoUrl != null && report.photoUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                report.photoUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  color: PawCoColors.sageMuted,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: PawCoColors.muted,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            report.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: PawCoColors.inkSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (report.addressNotes != null &&
              report.addressNotes!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: PawCoColors.sageMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PawCoColors.cottonLilac),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: PawCoColors.plum,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dirección exacta / Referencia confidencial:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: PawCoColors.plum,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          report.addressNotes!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: PawCoColors.ink,
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
          Row(
            children: [
              Icon(
                report.isAnonymous ? Icons.visibility_off : Icons.person,
                size: 14,
                color: PawCoColors.muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  report.isAnonymous
                      ? 'Denunciante Anónimo'
                      : 'Contacto: ${report.reporterContact ?? "Usuario registrado"}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: PawCoColors.muted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: PawCoColors.border),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (report.status != 'public_alert')
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PawCoColors.malva,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 34),
                  ),
                  icon: const Icon(Icons.campaign_rounded, size: 16),
                  label: const Text(
                    'Publicar como Alerta',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    foregroundColor: PawCoColors.plum,
                    side: const BorderSide(color: PawCoColors.plum),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 34),
                  ),
                  icon: const Icon(Icons.sync_rounded, size: 16),
                  label: const Text(
                    'En Gestión',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    foregroundColor: PawCoColors.plum,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 34),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Resolver', style: TextStyle(fontSize: 12)),
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
                    foregroundColor: PawCoColors.muted,
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
    );
  }

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

  Widget _buildLostPetsTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LostPetReport>> lostPetsAsync,
  ) {
    return lostPetsAsync.when(
      data: (reports) {
        if (reports.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No hay reportes de animales perdidos o encontrados 📍',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: PawCoColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: PawCoColors.plum,
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
      loading: () => const Center(
        child: CircularProgressIndicator(color: PawCoColors.plum),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '⚠️ Error cargando reportes:\n$e',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: PawCoColors.error),
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
          PawCoColors.error,
          PawCoColors.softMalva
        ),
      'resolved' => (
          '🎉 Resuelto (¡Ya apareció!)',
          PawCoColors.plum,
          PawCoColors.cottonLilac
        ),
      _ => (
          '✅ Activo en el mapa',
          const Color(0xFF059669),
          const Color(0xFFD1FAE5)
        ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PawCoColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isFlagged ? PawCoColors.error : PawCoColors.border,
          width: isFlagged ? 1.6 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLost
                      ? PawCoColors.softMalva
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isLost ? '🔴 Mascota Perdida' : '🟢 Avistado / Encontrado',
                  style: GoogleFonts.plusJakartaSans(
                    color: isLost
                        ? PawCoColors.terracottaDark
                        : const Color(0xFF059669),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.plusJakartaSans(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${report.petName} (${report.species})',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: PawCoColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 15,
                color: PawCoColors.plum,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${report.neighborhood}, ${report.municipality}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PawCoColors.inkSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (report.photoUrl != null && report.photoUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
          Text(
            report.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: PawCoColors.inkSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 14, color: PawCoColors.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Contacto: ${report.contactPhone}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: PawCoColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: PawCoColors.border),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isFlagged || isResolved)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PawCoColors.plum,
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
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    foregroundColor: PawCoColors.plum,
                    side: const BorderSide(color: PawCoColors.plum),
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
                    foregroundColor: PawCoColors.error,
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
                  foregroundColor: PawCoColors.muted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 34),
                ),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Eliminar', style: TextStyle(fontSize: 12)),
                onPressed: () => _deleteLostPetReport(context, ref, report.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
              backgroundColor: PawCoColors.error,
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
