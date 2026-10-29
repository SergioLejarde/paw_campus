import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme.dart';
import '../../../core/presentation/pawco_design_system.dart';
import '../data/sos_repository.dart';

class SosPage extends ConsumerWidget {
  const SosPage({super.key});

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicAlertsAsync = ref.watch(publicSosAlertsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 860;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: PawCoColors.terracotta.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.campaign, color: PawCoColors.terracotta, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'SOS y Denuncias',
              style: GoogleFonts.fraunces(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: PawCoColors.ink,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(publicSosAlertsProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 16,
            vertical: 12,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==========================================
                  // SECCIÓN 1: CABECERA & MARCO LEGAL EN COLOMBIA
                  // ==========================================
                  _buildLegalNoticeHeader(),
                  const SizedBox(height: 18),

                  // ==========================================
                  // SECCIÓN 2: CANALES OFICIALES EN COLOMBIA
                  // ==========================================
                  _buildEmergencyCards(context),
                  const SizedBox(height: 16),
                  _buildChecklistExpansionTile(),
                  const SizedBox(height: 24),

                  // ==========================================
                  // SECCIÓN 3: REPORTE CIUDADANO EN RED PAWCO
                  // ==========================================
                  _buildReportToPawCoBanner(context),
                  const SizedBox(height: 28),

                  // ==========================================
                  // SECCIÓN 4: ALERTAS DE RESCATE VERIFICADAS
                  // ==========================================
                  _buildPublicAlertsHeader(context, ref),
                  const SizedBox(height: 14),
                  _buildPublicAlertsList(context, publicAlertsAsync),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Banner informativo sobre el marco legal en Colombia
  Widget _buildLegalNoticeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PawCoColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PawCoColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PawCoColors.terracottaLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.gavel_rounded, color: PawCoColors.terracottaDark, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Marco Legal de Protección Animal en Colombia',
                  style: GoogleFonts.fraunces(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: PawCoColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'En Colombia los animales son reconocidos constitucionalmente como seres sintientes (Ley 1774 de 2016 y Ley Ángel 2455 de 2024). '
            'El maltrato físico grave, abandono y explotación son delitos castigados con penas privativas de la libertad y multas agravadas.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: PawCoColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              PawCoBadge(
                label: 'Ley 1774 de 2016',
                icon: Icons.shield,
                backgroundColor: PawCoColors.terracottaLight,
                textColor: PawCoColors.terracottaDark,
              ),
              PawCoBadge(
                label: 'Ley Ángel (Ley 2455)',
                icon: Icons.balance,
                backgroundColor: PawCoColors.terracottaLight,
                textColor: PawCoColors.terracottaDark,
              ),
              PawCoBadge(
                label: 'GELMA Fiscalía 122',
                icon: Icons.account_balance,
                backgroundColor: PawCoColors.sageLight,
                textColor: PawCoColors.forest,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tarjetas interactivas de llamadas y enlaces directos
  Widget _buildEmergencyCards(BuildContext context) {
    return Column(
      children: [
        // 1. Policía Nacional - Línea 123
        PawCoHoverCard(
          borderRadius: 20,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: PawCoColors.terracottaLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_police,
                  color: PawCoColors.terracotta,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Policía Nacional — Línea 123',
                      style: GoogleFonts.fraunces(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PawCoColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Emergencias inmediatas, flagrancia de maltrato activo o animales en peligro inminente de muerte. Se articula con la Patrulla de Policía Ambiental y Ecológica Metropolitana de Bucaramanga.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: PawCoColors.muted),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PawCoColors.terracotta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.phone_in_talk, size: 16),
                      label: Text(
                        'Llamar al 123',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      onPressed: () => _makeCall('123'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Fiscalía General - Grupo GELMA (Línea 122 + Portal Web)
        PawCoHoverCard(
          borderRadius: 20,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: PawCoColors.sageLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: PawCoColors.forest,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fiscalía General — Grupo GELMA',
                      style: GoogleFonts.fraunces(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PawCoColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Grupo Especial para la Lucha Contra el Maltrato Animal. Atiende denuncias formales por lesiones, crueldad o muerte provocada.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: PawCoColors.muted),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PawCoColors.forest,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.open_in_new, size: 15),
                          label: Text(
                            'Denuncia Fácil (Web)',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () => _openUrl(
                            'https://sicecon.fiscalia.gov.co/denuncia/LlenarFormulario',
                          ),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: PawCoColors.forest,
                            side: const BorderSide(color: PawCoColors.forest),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.call, size: 15),
                          label: Text(
                            'Llamar al 122',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () => _makeCall('122'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. Inspección de Protección a la Vida (Bucaramanga y AMB)
        PawCoHoverCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: PawCoColors.slateBlueLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_city,
                  color: PawCoColors.slateBlue,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alcaldía de Bucaramanga y AMB',
                      style: GoogleFonts.fraunces(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PawCoColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Inspecciones de Policía de Protección a la Vida y Secretarías de Salud. Competentes para casos de tenencia irresponsable, animales en balcones sin techo y olores.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: PawCoColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Checklist desplegable para orientar al ciudadano
  Widget _buildChecklistExpansionTile() {
    return Container(
      decoration: BoxDecoration(
        color: PawCoColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PawCoColors.borderLight),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: PawCoColors.sageLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.checklist_rounded, color: PawCoColors.forest),
        ),
        title: Text(
          '¿Qué pruebas debo reunir antes de denunciar?',
          style: GoogleFonts.fraunces(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: PawCoColors.ink,
          ),
        ),
        subtitle: Text(
          'Recomendaciones para que tu denuncia prospere legalmente',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: PawCoColors.muted),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        children: [
          const Divider(color: PawCoColors.borderLight),
          const SizedBox(height: 6),
          _buildChecklistItem(
            Icons.camera_alt_outlined,
            'Fotos o videos claros:',
            'Donde se evidencie el estado del animal, sus lesiones o las condiciones inadecuadas del lugar.',
          ),
          const SizedBox(height: 10),
          _buildChecklistItem(
            Icons.place_outlined,
            'Ubicación exacta:',
            'Dirección con nomenclatura clara en Bucaramanga, Floridablanca, Girón o Piedecuesta, o punto de referencia visible.',
          ),
          const SizedBox(height: 10),
          _buildChecklistItem(
            Icons.access_time_outlined,
            'Fecha, hora y recurrencia:',
            'Anotar si es una agresión puntual o una situación reiterada en el tiempo.',
          ),
          const SizedBox(height: 10),
          _buildChecklistItem(
            Icons.person_outline,
            'Datos del agresor o tenedor (si los conoces):',
            'Nombre, descripción física o relación con el inmueble. Nunca te pongas en riesgo para obtenerlos.',
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: PawCoColors.forest),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: PawCoColors.ink),
              children: [
                TextSpan(
                  text: '$title ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Banner para reportar directamente a la red PawCo
  Widget _buildReportToPawCoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: PawCoColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PawCoColors.forest.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: PawCoColors.forest.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PawCoColors.forest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Reportar Caso a la Red PawCol',
                  style: GoogleFonts.fraunces(
                    color: PawCoColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tu reporte es confidencial. Puedes enviarlo de forma 100% anónima. '
            'Nuestro equipo y fundaciones aliadas en Bucaramanga y el AMB lo revisarán y, si requiere auxilio comunitario, '
            'se publicará como Alerta de Rescate sin exponer datos privados.',
            style: GoogleFonts.plusJakartaSans(
              color: PawCoColors.muted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: PawCoColors.forest,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.add_alert, size: 20),
              label: Text(
                'Radicar Reporte SOS Ahora',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => context.push('/sos/new'),
            ),
          ),
        ],
      ),
    );
  }

  /// Encabezado de alertas públicas
  Widget _buildPublicAlertsHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alertas de Rescate Comunitarias',
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: PawCoColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Casos verificados en Bucaramanga y AMB que requieren apoyo urgente',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: PawCoColors.muted),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: PawCoColors.forest),
          tooltip: 'Actualizar alertas',
          onPressed: () => ref.invalidate(publicSosAlertsProvider),
        ),
      ],
    );
  }

  /// Listado de alertas públicas
  Widget _buildPublicAlertsList(
    BuildContext context,
    AsyncValue<List<AbuseReport>> publicAlertsAsync,
  ) {
    return publicAlertsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: PawCoColors.forest),
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PawCoColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PawCoColors.border),
        ),
        child: Text('Error cargando alertas: $e', style: GoogleFonts.plusJakartaSans(color: PawCoColors.ink)),
      ),
      data: (alerts) {
        if (alerts.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: PawCoColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: PawCoColors.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle_outline, color: PawCoColors.forest, size: 48),
                const SizedBox(height: 12),
                Text(
                  'No hay alertas públicas activas en este momento',
                  style: GoogleFonts.fraunces(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PawCoColors.ink,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Todos los casos recientes han sido canalizados con éxito.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: PawCoColors.muted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: alerts.map((alert) => _buildAlertCard(context, alert)).toList(),
        );
      },
    );
  }

  Widget _buildAlertCard(BuildContext context, AbuseReport alert) {
    final isCritical = alert.urgencyLevel == 'Crítica';

    return PawCoHoverCard(
      borderRadius: 20,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PawCoBadge(
                label: 'ALERTA: ${alert.urgencyLevel.toUpperCase()}',
                icon: Icons.warning_amber_rounded,
                backgroundColor: isCritical ? PawCoColors.terracottaLight : PawCoColors.sageLight,
                textColor: isCritical ? PawCoColors.terracottaDark : PawCoColors.forest,
              ),
              const Spacer(),
              Text(
                '📍 ${alert.municipality}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PawCoColors.forest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            alert.abuseType,
            style: GoogleFonts.fraunces(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: PawCoColors.ink,
            ),
          ),
          if (alert.neighborhood.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Sector: ${alert.neighborhood}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: PawCoColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            alert.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: PawCoColors.inkSecondary,
              height: 1.4,
            ),
          ),
          if (alert.photoUrl != null && alert.photoUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                alert.photoUrl!,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
