import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/main_shell.dart';
import '../../../app/theme.dart';
import '../../../core/presentation/pawco_design_system.dart';

/// 🌿 Página de Inicio, Impacto Comunitario, Quiénes Somos y Voluntariado de PawCo
/// Diseñada con estética editorial cálida, siluetas de animales y total transparencia.
class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key});

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _transparencyKey = GlobalKey();
  final GlobalKey _volunteerKey = GlobalKey();

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _openReportChoiceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: PawCoColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '¿Qué deseas reportar hoy?',
              style: GoogleFonts.fraunces(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: PawCoColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tu reporte inmediato salva vidas en el Área Metropolitana de Bucaramanga.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: PawCoColors.muted,
              ),
            ),
            const SizedBox(height: 20),
            PawCoHoverCard(
              backgroundColor: PawCoColors.terracottaLight,
              borderColor: PawCoColors.terracotta.withValues(alpha: 0.3),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(mainNavIndexProvider.notifier).state = 4; // SOS
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PawCoColors.terracotta,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Denuncia SOS por Maltrato o Emergencia',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: PawCoColors.terracottaDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Animal herido, abandonado o en riesgo inminente.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: PawCoColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: PawCoColors.terracottaDark),
                ],
              ),
            ),
            const SizedBox(height: 10),
            PawCoHoverCard(
              backgroundColor: PawCoColors.sandLight,
              borderColor: PawCoColors.sand,
              onTap: () {
                Navigator.pop(ctx);
                ref.read(mainNavIndexProvider.notifier).state = 2; // Perdidos
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PawCoColors.forest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.location_searching, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mascota Perdida o Encontrada',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: PawCoColors.forest,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Publica foto, zona y contacto para que regrese a casa.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: PawCoColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: PawCoColors.forest),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showVolunteerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _VolunteerApplicationModal(
        onSuccess: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: PawCoColors.forest,
              content: Text('¡Gracias por unirte! Nos pondremos en contacto contigo para el voluntariado.'),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 860;

    return Scaffold(
      backgroundColor: Colors.transparent, // Permite ver las siluetas del fondo
      body: SafeArea(
        top: !isDesktop, // Si no es desktop, deja espacio para status bar
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32.0 : 16.0,
            vertical: 18.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. Saludo Editorial Superior ---
                  _buildTopEditorialGreeting(isDesktop),
                  const SizedBox(height: 18),

                  // --- 1.5 Manifiesto Emocional (Conexión Directa) ---
                  PawCoFadeSlide(
                    child: _buildEmotionalCalloutCard(isDesktop),
                  ),
                  const SizedBox(height: 20),

                  // --- 2. Hero Banner ("Conviértete en un Héroe") ---
                  PawCoFadeSlide(
                    child: _buildHeroBanner(isDesktop),
                  ),
                  const SizedBox(height: 28),

                  // --- 3. Acciones Rápidas (Quick Actions) ---
                  _buildSectionHeader(
                    title: 'Acciones Rápidas',
                    subtitle: '¿Cómo deseas marcar la diferencia hoy en Santander?',
                  ),
                  const SizedBox(height: 12),
                  PawCoFadeSlide(
                    child: _buildQuickActionsGrid(isDesktop),
                  ),
                  const SizedBox(height: 32),

                  // --- 4. Estadísticas de Impacto Comunitario ---
                  _buildSectionHeader(
                    title: 'Impacto Comunitario en el AMB',
                    subtitle: 'Bucaramanga, Floridablanca, Girón y Piedecuesta unidos',
                  ),
                  const SizedBox(height: 12),
                  PawCoFadeSlide(
                    child: _buildCommunityImpactCard(isDesktop),
                  ),
                  const SizedBox(height: 36),

                  // --- 5. Transparencia Total: ¿Por qué creamos PawCo? ---
                  KeyedSubtree(
                    key: _transparencyKey,
                    child: PawCoFadeSlide(
                      child: _buildTransparencySection(isDesktop),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // --- 6. Quiénes Somos / Conoce al Creador ---
                  PawCoFadeSlide(
                    child: _buildAboutCreatorSection(isDesktop),
                  ),
                  const SizedBox(height: 36),

                  // --- 7. Módulo Interactivo de Voluntariado Ciudadano ---
                  KeyedSubtree(
                    key: _volunteerKey,
                    child: PawCoFadeSlide(
                      child: _buildVolunteerSection(isDesktop),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // --- Footer sutil ---
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.pets, size: 18, color: PawCoColors.forest),
                            const SizedBox(width: 8),
                            Text(
                              'PawCol • Bucaramanga & Área Metropolitana',
                              style: GoogleFonts.fraunces(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: PawCoColors.forest,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Cada vida rescatada cuenta. Tecnología al servicio del amor animal.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: PawCoColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // COMPONENTES DE SECCIÓN
  // ==========================================================================

  Widget _buildTopEditorialGreeting(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: PawCoColors.forest.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pets, color: PawCoColors.forest, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  'PawCol Santander',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: PawCoColors.forest,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const PawCoBadge(label: 'Bucaramanga & AMB'),
              ],
            ),
            if (!isDesktop)
              IconButton(
                icon: const Icon(Icons.volunteer_activism_outlined, color: PawCoColors.forest),
                tooltip: 'Donar a causas del AMB',
                onPressed: () {
                  ref.read(mainNavIndexProvider.notifier).state = 3; // Donar
                },
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Juntos por los animales',
          style: GoogleFonts.fraunces(
            fontSize: isDesktop ? 34 : 26,
            fontWeight: FontWeight.w700,
            color: PawCoColors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Uniendo rescatistas, fundaciones y corazones solidarios en Bucaramanga y su área metropolitana.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: isDesktop ? 15 : 13.5,
            color: PawCoColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionalCalloutCard(bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: PawCoColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 12,
            bottom: 6,
            child: AnimalSilhouetteCardWatermark(
              width: 140,
              height: 95,
              opacity: 0.14,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 28.0 : 20.0,
              vertical: isDesktop ? 24.0 : 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: PawCoColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: PawCoColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.volunteer_activism_outlined,
                            size: 13,
                            color: PawCoColors.forest,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Impacto real a un clic de distancia',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: PawCoColors.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Alguna vez has querido ayudar a un peludito, pero sentiste que faltaba algo para lograr un bienestar real?',
                  style: GoogleFonts.fraunces(
                    fontSize: isDesktop ? 22 : 18.5,
                    fontWeight: FontWeight.w600,
                    color: PawCoColors.ink,
                    height: 1.28,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'En PawCol transformamos tus buenas intenciones en resultados tangibles. Conectamos tu solidaridad con acciones directas y transparentes que hoy están cambiando vidas en Bucaramanga y su Área Metropolitana, con la visión de llegar muy pronto a toda Colombia y el mundo.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isDesktop ? 14.5 : 13.5,
                    color: PawCoColors.inkSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pasa del deseo de ayudar a la satisfacción de ser parte del cambio: la plataforma que esperabas para proteger y respaldar a nuestros animales ya está aquí, a un solo clic de distancia.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isDesktop ? 14.5 : 13.5,
                    fontWeight: FontWeight.w600,
                    color: PawCoColors.ink,
                    height: 1.48,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PawCoColors.forest,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        ref.read(mainNavIndexProvider.notifier).state = 3; // Donar
                      },
                      icon: const Icon(Icons.favorite_border, size: 15),
                      label: Text(
                        'Sumarme al cambio hoy',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PawCoColors.ink,
                        side: const BorderSide(color: PawCoColors.border, width: 1.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _openReportChoiceDialog,
                      icon: const Icon(Icons.pets_outlined, size: 15),
                      label: Text(
                        'Brindar ayuda a un peludito',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
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

  Widget _buildHeroBanner(bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEDF0EA), // Piedra salvia clara y neutra
            Color(0xFFE2E7DE),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD2D9CC),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: PawCoColors.ink.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Marca de agua sutil de siluetas
          const Positioned(
            right: 10,
            bottom: 4,
            child: AnimalSilhouetteCardWatermark(
              width: 130,
              height: 90,
              opacity: 0.16,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32.0 : 22.0,
              vertical: isDesktop ? 28.0 : 22.0,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFD2D9CC)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite_border, size: 12, color: PawCoColors.forest),
                            const SizedBox(width: 5),
                            Text(
                              'Causa Solidaria Santandereana',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: PawCoColors.forest,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Conviértete en un Héroe para los Animales',
                        style: GoogleFonts.fraunces(
                          fontSize: isDesktop ? 26 : 21,
                          fontWeight: FontWeight.w600,
                          color: PawCoColors.ink,
                          height: 1.22,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adopta, reporta maltrato o apoya con bultos de concentrado a los albergues más necesitados del AMB.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isDesktop ? 14 : 13,
                          color: PawCoColors.inkSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PawCoColors.forest,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              ref.read(mainNavIndexProvider.notifier).state = 1; // Adopciones
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Explorar Adopciones',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward, size: 15),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.65),
                              foregroundColor: PawCoColors.ink,
                              side: const BorderSide(color: Color(0xFFC5CEBE), width: 1),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _scrollToKey(_transparencyKey),
                            child: Text(
                              'Conocer nuestra misión',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (MediaQuery.of(context).size.width >= 640) ...[
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 2,
                    child: Center(
                      child: DogCatHeroIllustration(
                        width: 170,
                        height: 140,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.fraunces(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: PawCoColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: PawCoColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(bool isDesktop) {
    final actions = [
      _QuickActionItem(
        title: 'Reportar Peludito',
        subtitle: 'Maltrato SOS o Mascota perdida',
        icon: Icons.add_alert_outlined,
        backgroundColor: PawCoColors.terracottaLight,
        accentColor: PawCoColors.terracottaDark,
        onTap: _openReportChoiceDialog,
      ),
      _QuickActionItem(
        title: 'Adoptar un Compañero',
        subtitle: 'Perros y gatos buscando hogar',
        icon: Icons.pets_outlined,
        backgroundColor: const Color(0xFFE3E8DC),
        accentColor: PawCoColors.forest,
        onTap: () {
          ref.read(mainNavIndexProvider.notifier).state = 1; // Adopciones
        },
      ),
      _QuickActionItem(
        title: 'Donar a una Meta',
        subtitle: 'Bultos de comida y cirugías',
        icon: Icons.volunteer_activism_outlined,
        backgroundColor: PawCoColors.sageLight,
        accentColor: PawCoColors.forest,
        onTap: () {
          ref.read(mainNavIndexProvider.notifier).state = 3; // Donar
        },
      ),
      _QuickActionItem(
        title: 'Ser Voluntario',
        subtitle: 'Paseos, baños y veeduría',
        icon: Icons.handshake_outlined,
        backgroundColor: PawCoColors.slateBlueLight,
        accentColor: PawCoColors.slateBlue,
        onTap: _showVolunteerModal,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: actions.map((item) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: _buildActionCard(item),
            ),
          );
        }).toList(),
      );
    }

    // Móvil: Grid 2x2
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildActionCard(actions[0])),
            const SizedBox(width: 10),
            Expanded(child: _buildActionCard(actions[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildActionCard(actions[2])),
            const SizedBox(width: 10),
            Expanded(child: _buildActionCard(actions[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(_QuickActionItem item) {
    return PawCoHoverCard(
      backgroundColor: PawCoColors.surface,
      borderColor: PawCoColors.border,
      padding: const EdgeInsets.all(18),
      margin: EdgeInsets.zero,
      onTap: item.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 22, color: item.accentColor),
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: item.accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: PawCoColors.inkSecondary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityImpactCard(bool isDesktop) {
    return PawCoHoverCard(
      backgroundColor: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 18,
        vertical: 20,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '1,480+',
                          style: GoogleFonts.fraunces(
                            fontSize: isDesktop ? 32 : 26,
                            fontWeight: FontWeight.w700,
                            color: PawCoColors.forest,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'animales ayudados este mes en el AMB',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: PawCoColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const PawCoAnimatedProgressBar(
                      value: 0.82,
                      height: 8,
                      progressColor: PawCoColors.forest,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Meta mensual al 82% • 185 bultos de concentrado entregados',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: PawCoColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 55,
                width: 1,
                color: PawCoColors.border,
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: PawCoColors.terracottaLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.crisis_alert,
                        color: PawCoColors.terracottaDark,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '6 Alertas Activas',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: PawCoColors.terracottaDark,
                            ),
                          ),
                          Text(
                            'En Floridablanca y Girón',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: PawCoColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: PawCoColors.borderLight, height: 1),
          const SizedBox(height: 12),
          // Municipios cubiertos
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: const [
              PawCoBadge(label: 'Bucaramanga', icon: Icons.location_on_outlined),
              PawCoBadge(label: 'Floridablanca', icon: Icons.location_on_outlined),
              PawCoBadge(label: 'Girón', icon: Icons.location_on_outlined),
              PawCoBadge(label: 'Piedecuesta', icon: Icons.location_on_outlined),
              PawCoBadge(
                label: 'Metas 100% Auditadas',
                icon: Icons.verified_user_outlined,
                backgroundColor: PawCoColors.terracottaLight,
                textColor: PawCoColors.terracottaDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransparencySection(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      decoration: BoxDecoration(
        color: PawCoColors.sandLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PawCoColors.border),
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
                child: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transparencia Total',
                      style: GoogleFonts.fraunces(
                        fontSize: isDesktop ? 22 : 18,
                        fontWeight: FontWeight.w700,
                        color: PawCoColors.ink,
                      ),
                    ),
                    Text(
                      '¿Por qué creamos PawCol Web y Móvil?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: PawCoColors.forest,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PawCoColors.borderLight),
            ),
            child: Text(
              'Sabemos que muchas personas de buen corazón en Bucaramanga y en toda Colombia quieren ayudar, pero frecuentemente no donan por temor a que su dinero se pierda o no sea destinado realmente a los animales afectados.\n\n'
              'PawCol nació específicamente para erradicar esa duda y garantizar al 100% que cada aporte llegue a metas concretas y verificables: compra directa de bultos de concentrado, pago de facturas de hospitalización veterinaria, cirugías de urgencia y esterilizaciones en fundaciones auditadas del Área Metropolitana.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: PawCoColors.ink,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Tres pilares visuales
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              final pilares = [
                _PillarItem(
                  icon: Icons.track_changes,
                  title: '1. Metas con Propósito Específico',
                  description:
                      'Nada de cuentas genéricas. Donas a bultos exactos de comida o a la factura de la clínica veterinaria.',
                ),
                _PillarItem(
                  icon: Icons.verified,
                  title: '2. Fundaciones Verificadas del AMB',
                  description:
                      'Albergues y rescatistas visitados presencialmente con personería y trayectoria real en Santander.',
                ),
                _PillarItem(
                  icon: Icons.photo_camera_back_outlined,
                  title: '3. Evidencia y Veeduría Abierta',
                  description:
                      'Facturas visibles, fotos de entrega de alimento y voluntariado abierto para que compruebes todo en persona.',
                ),
              ];

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: pilares.map((p) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: _buildPillarCard(p),
                      ),
                    );
                  }).toList(),
                );
              }

              return Column(
                children: pilares.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildPillarCard(p),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPillarCard(_PillarItem p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PawCoColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PawCoColors.sageLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(p.icon, color: PawCoColors.forest, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            p.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: PawCoColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            p.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: PawCoColors.muted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCreatorSection(bool isDesktop) {
    return PawCoHoverCard(
      backgroundColor: Colors.white,
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar / Foto estilizada del creador
          Container(
            width: isDesktop ? 90 : 70,
            height: isDesktop ? 90 : 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [PawCoColors.forest, PawCoColors.sage],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: PawCoColors.forest.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'SL',
                style: GoogleFonts.fraunces(
                  color: Colors.white,
                  fontSize: isDesktop ? 32 : 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Sergio Lejarde',
                      style: GoogleFonts.fraunces(
                        fontSize: isDesktop ? 22 : 18,
                        fontWeight: FontWeight.w700,
                        color: PawCoColors.ink,
                      ),
                    ),
                    const PawCoBadge(
                      label: 'Ingeniero de Sistemas e Informática (24 años)',
                      backgroundColor: PawCoColors.sageLight,
                      textColor: PawCoColors.forest,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Fundador y Desarrollador de PawCol • Bucaramanga, Santander',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: PawCoColors.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Soy un joven ingeniero de 24 años apasionado por la tecnología y comprometido de corazón con el bienestar animal.\n\n'
                  'Al ver de cerca las dificultades que viven a diario los refugios en Bucaramanga, Floridablanca, Girón y Piedecuesta, y la desconfianza ciudadana hacia los canales tradicionales de donación, decidí poner mis conocimientos en ingeniería de software para crear una plataforma transparente, accesible y comunitaria.\n\n'
                  'PawCol es mi aporte para demostrar que con honestidad, diseño y tecnología podemos salvar cientos de vidas.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: PawCoColors.ink,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _buildPillTag(Icons.code, 'Desarrollo Flutter & Web'),
                    _buildPillTag(Icons.favorite, 'Amor por los animales'),
                    _buildPillTag(Icons.location_city, 'Orgullo Santandereano'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: PawCoColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PawCoColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: PawCoColors.forest),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: PawCoColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PawCoColors.slateBlueLight.withValues(alpha: 0.5),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PawCoColors.slateBlueLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PawCoColors.slateBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.handshake_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voluntariado en Fundaciones del AMB',
                      style: GoogleFonts.fraunces(
                        fontSize: isDesktop ? 22 : 18,
                        fontWeight: FontWeight.w700,
                        color: PawCoColors.ink,
                      ),
                    ),
                    Text(
                      '¿No tienes dinero para donar? ¡Tus manos y tu tiempo salvan vidas!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: PawCoColors.slateBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Las fundaciones y refugios de Bucaramanga, Floridablanca, Girón y Piedecuesta necesitan voluntarios para pasear perritos, baños, limpieza de albergues, transporte al veterinario y difusión de fotos para adopción.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: PawCoColors.ink,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: PawCoColors.slateBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _showVolunteerModal,
            icon: const Icon(Icons.assignment_ind_outlined, size: 20),
            label: Text(
              'Postularme como Voluntario Solidario 💙',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MODELOS AUXILIARES Y MODAL DE VOLUNTARIADO
// ============================================================================

class _QuickActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color accentColor;
  final VoidCallback onTap;

  _QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.accentColor,
    required this.onTap,
  });
}

class _PillarItem {
  final IconData icon;
  final String title;
  final String description;

  _PillarItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// Modal interactivo para inscribirse como voluntario en refugios del AMB
class _VolunteerApplicationModal extends StatefulWidget {
  final VoidCallback onSuccess;

  const _VolunteerApplicationModal({required this.onSuccess});

  @override
  State<_VolunteerApplicationModal> createState() => _VolunteerApplicationModalState();
}

class _VolunteerApplicationModalState extends State<_VolunteerApplicationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _availabilityController = TextEditingController();

  String _selectedCity = 'Bucaramanga';
  final Set<String> _selectedRoles = {'Paseo y socialización de peluditos'};

  final List<String> _cities = [
    'Bucaramanga',
    'Floridablanca',
    'Girón',
    'Piedecuesta',
    'Todo el AMB',
  ];

  final List<String> _availableRoles = [
    'Paseo y socialización de peluditos',
    'Jornadas de baño y limpieza en refugio',
    'Hogar de paso temporal',
    'Transporte solidario (veterinario)',
    'Fotografía y difusión para adopción',
  ];

  bool _isSubmitting = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona al menos un rol de voluntariado')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Preparar mensaje para WhatsApp directo de coordinación
    final rolesString = _selectedRoles.join(', ');
    final message = '¡Hola equipo PawCol! Me gustaría postularme como voluntario en el AMB:\n'
        '• Nombre: ${_nameController.text.trim()}\n'
        '• Municipio: $_selectedCity\n'
        '• Roles de interés: $rolesString\n'
        '• Disponibilidad: ${_availabilityController.text.trim()}';

    final uri = Uri.parse('https://wa.me/573160000000?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Si falla la apertura de WhatsApp, igualmente registramos el éxito en UI
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      widget.onSuccess();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PawCoColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Postulación de Voluntariado AMB',
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: PawCoColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tu tiempo ayuda a que los perritos y gatitos de los refugios reciban cariño y cuidados.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: PawCoColors.muted,
                ),
              ),
              const SizedBox(height: 18),

              // Roles seleccionables
              Text(
                '¿En qué actividades te gustaría participar?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: PawCoColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableRoles.map((role) {
                  final isSelected = _selectedRoles.contains(role);
                  return FilterChip(
                    label: Text(role),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedRoles.add(role);
                        } else {
                          _selectedRoles.remove(role);
                        }
                      });
                    },
                    selectedColor: PawCoColors.sageLight,
                    checkmarkColor: PawCoColors.forest,
                    backgroundColor: PawCoColors.surfaceMuted,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? PawCoColors.forest : PawCoColors.ink,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? PawCoColors.forest : PawCoColors.border,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Municipio
              Text(
                'Municipio de preferencia en el AMB',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: PawCoColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined, color: PawCoColors.forest),
                ),
                items: _cities.map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCity = val);
                },
              ),
              const SizedBox(height: 14),

              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  hintText: 'Ej. Carolina Gómez',
                  prefixIcon: Icon(Icons.person_outline, color: PawCoColors.forest),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingresa tu nombre completo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // WhatsApp / Teléfono
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Número de WhatsApp',
                  hintText: 'Ej. 316 123 4567',
                  prefixIcon: Icon(Icons.chat_bubble_outline, color: PawCoColors.forest),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 7) {
                    return 'Ingresa un número de contacto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Disponibilidad
              TextFormField(
                controller: _availabilityController,
                decoration: const InputDecoration(
                  labelText: 'Disponibilidad horaria',
                  hintText: 'Ej. Sábados en la mañana, domingos...',
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: PawCoColors.forest),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Cuéntanos tu disponibilidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),

              // Botón de Envío
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PawCoColors.forest,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Enviar Postulación y Coordinar por WhatsApp 💙',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
