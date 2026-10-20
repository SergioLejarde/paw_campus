import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.campaign, color: Color(0xFFE11D48), size: 28),
            SizedBox(width: 8),
            Text(
              'SOS y Denuncias',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(publicSosAlertsProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==========================================
                  // SECCIÓN 1: CANALES OFICIALES EN COLOMBIA
                  // ==========================================
                  _buildLegalNoticeHeader(),
                  const SizedBox(height: 16),
                  _buildEmergencyCards(context),
                  const SizedBox(height: 16),
                  _buildChecklistExpansionTile(),
                  const SizedBox(height: 24),

                  // ==========================================
                  // SECCIÓN 2: REPORTE CIUDADANO EN RED PAWCO
                  // ==========================================
                  _buildReportToPawCoBanner(context),
                  const SizedBox(height: 24),

                  // ==========================================
                  // SECCIÓN 3: ALERTAS DE RESCATE VERIFICADAS
                  // ==========================================
                  _buildPublicAlertsHeader(context, ref),
                  const SizedBox(height: 12),
                  _buildPublicAlertsList(context, publicAlertsAsync),
                  const SizedBox(height: 36),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gavel_rounded, color: Color(0xFFE11D48), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Marco Legal de Protección Animal en Colombia',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9F1239),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'En Colombia los animales son reconocidos como seres sintientes (Ley 1774 de 2016 y Ley Ángel 2455). '
            'El maltrato físico grave, abandono y explotación son delitos castigados con penas de prisión y fuertes multas económicas.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF881337),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildTag('Ley 1774 de 2016', const Color(0xFFBE123C)),
              _buildTag('Ley Ángel (2455)', const Color(0xFFBE123C)),
              _buildTag('GELMA Fiscalía', const Color(0xFF0F766E)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// Tarjetas interactivas de llamadas y enlaces directos
  Widget _buildEmergencyCards(BuildContext context) {
    return Column(
      children: [
        // 1. Policía Nacional - Línea 123
        Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE4E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_police,
                    color: Color(0xFFE11D48),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Policía Nacional — Línea 123',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Emergencias inmediatas, flagrancia de maltrato activo o animales en peligro inminente de muerte. Se articula con la Patrulla de Policía Ambiental y Ecológica.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          minimumSize: const Size(0, 36),
                        ),
                        icon: const Icon(Icons.phone_in_talk, size: 16),
                        label: const Text(
                          'Llamar al 123',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _makeCall('123'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Fiscalía General - Grupo GELMA (Línea 122 + Portal Web)
        Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFCCFBF1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Color(0xFF0F766E),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fiscalía General — Grupo GELMA',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Grupo Especial para la Lucha Contra el Maltrato Animal. Atiende denuncias formales por lesiones, crueldad o muerte provocada.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: const Size(0, 36),
                            ),
                            icon: const Icon(Icons.open_in_new, size: 15),
                            label: const Text(
                              'Denuncia Fácil (Web)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _openUrl(
                              'https://sicecon.fiscalia.gov.co/denuncia/LlenarFormulario',
                            ),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F766E),
                              side: const BorderSide(color: Color(0xFF0D9488)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: const Size(0, 36),
                            ),
                            icon: const Icon(Icons.call, size: 15),
                            label: const Text(
                              'Llamar al 122',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
        ),

        // 3. Inspección de Protección a la Vida (Bucaramanga y AMB)
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_city,
                    color: Color(0xFFD97706),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alcaldía de Bucaramanga y AMB',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Inspecciones de Policía de Protección a la Vida y Secretarías de Salud. '
                        'Competentes para casos de tenencia irresponsable, animales en balcones sin techo, olores/ruido y profilaxis.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Checklist desplegable para orientar al ciudadano
  Widget _buildChecklistExpansionTile() {
    return Card(
      elevation: 1,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFF1F5F9),
          child: Icon(Icons.checklist_rounded, color: Color(0xFF0D9488)),
        ),
        title: const Text(
          '¿Qué pruebas debo reunir antes de denunciar?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: const Text(
          'Recomendaciones para que tu denuncia prospere legalmente',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(),
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
        Icon(icon, size: 18, color: const Color(0xFF0D9488)),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33E11D48),
            blurRadius: 12,
            offset: Offset(0, 4),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Reportar Caso a la Red PawCo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Tu reporte es confidencial. Puedes enviarlo de forma 100% anónima. '
            'Nuestro equipo y fundaciones aliadas lo revisarán y, si requiere ayuda ciudadana, '
            'se publicará como Alerta de Rescate sin exponer datos privados.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFBE123C),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_alert, color: Color(0xFFE11D48)),
              label: const Text(
                'Radicar Reporte SOS Ahora',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              onPressed: () => context.push('/sos/new'),
            ),
          ),
        ],
      ),
    );
  }

  /// Encabezado de la sección 3
  Widget _buildPublicAlertsHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.health_and_safety_outlined,
                color: Color(0xFF0D9488), size: 22),
            SizedBox(width: 8),
            Text(
              'Alertas de Rescate Verificadas',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          tooltip: 'Actualizar alertas',
          onPressed: () => ref.refresh(publicSosAlertsProvider),
        ),
      ],
    );
  }

  /// Lista de casos aprobados como 'public_alert'
  Widget _buildPublicAlertsList(
    BuildContext context,
    AsyncValue<List<AbuseReport>> alertsAsync,
  ) {
    return alertsAsync.when(
      data: (alerts) {
        if (alerts.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: const [
                  Icon(Icons.check_circle_outline,
                      size: 44, color: Color(0xFF0D9488)),
                  SizedBox(height: 12),
                  Text(
                    'No hay alertas públicas activas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Todos los casos recientes han sido canalizados con éxito en el Área Metropolitana.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: alerts.map((alert) {
            return _buildAlertCard(context, alert);
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Card(
        color: const Color(0xFFFEF2F2),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No se pudieron cargar las alertas comunitarias: $e',
            style: const TextStyle(color: Color(0xFFE11D48)),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, AbuseReport alert) {
    final isCritica = alert.urgencyLevel == 'Crítica';
    final badgeColor =
        isCritica ? const Color(0xFFE11D48) : const Color(0xFFEA580C);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de evidencia si existe
          if (alert.photoUrl != null && alert.photoUrl!.isNotEmpty)
            Stack(
              children: [
                Image.network(
                  alert.photoUrl!,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: const Color(0xFFF1F5F9),
                    alignment: Alignment.center,
                    child: const Icon(Icons.pets,
                        size: 40, color: Color(0xFFCBD5E1)),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Urgencia: ${alert.urgencyLevel}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${alert.municipality} • ${alert.neighborhood}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (alert.photoUrl == null || alert.photoUrl!.isEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Urgencia: ${alert.urgencyLevel}',
                          style: TextStyle(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        '${alert.municipality} • ${alert.neighborhood}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                Text(
                  alert.abuseType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Fila inferior con fecha y botón de apoyo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTimeAgo(alert.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        minimumSize: const Size(0, 36),
                      ),
                      icon: const Icon(Icons.volunteer_activism, size: 16),
                      label: const Text(
                        'Brindar Ayuda',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _showHelpBottomSheet(context, alert),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpBottomSheet(BuildContext context, AbuseReport alert) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite,
                        color: Color(0xFFE11D48), size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Apoyo para caso en ${alert.neighborhood}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Si puedes brindar hogar temporal solidario, transporte o donar para atención veterinaria, '
                  'contáctate con los canales comunitarios de PawCo:',
                  style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 16),
                if (alert.reporterContact != null &&
                    alert.reporterContact!.isNotEmpty)
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: const Color(0xFFCCFBF1),
                    leading: const Icon(Icons.phone, color: Color(0xFF0F766E)),
                    title: const Text('Contacto directo del rescatista'),
                    subtitle: Text(alert.reporterContact!),
                    trailing: const Icon(Icons.call_made, size: 18),
                    onTap: () {
                      Navigator.pop(ctx);
                      _makeCall(alert.reporterContact!);
                    },
                  )
                else
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: const Color(0xFFFFF7ED),
                    leading: const Icon(Icons.volunteer_activism,
                        color: Color(0xFFD97706)),
                    title: const Text('Red de Voluntarios PawCo'),
                    subtitle: const Text(
                      'Caso gestionado a través de fundaciones aliadas de Bucaramanga.',
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes <= 0 ? 1 : diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} h';
    } else {
      return 'Hace ${diff.inDays} d';
    }
  }
}
