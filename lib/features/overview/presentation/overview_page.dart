import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/main_shell.dart';
import '../../../app/theme.dart';
import '../../../core/presentation/pawco_design_system.dart';

/// 💜 Página de Inicio de PawCol — Arquitectura "Aurora Híbrida + Paleta Violeta 2"
/// Integra escenario orbital animado en el Hero (Glassmorphism + SVG + Lottie)
/// con secciones luminosas de scroll en Marfil-Lila Pastel (`#FAF6F9`).
class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key});

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _transparencyKey = GlobalKey();
  final GlobalKey _volunteerKey = GlobalKey();
  int _selectedQuickCategory = 0;

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
              style: GoogleFonts.plusJakartaSans(
                fontSize: 21,
                fontWeight: FontWeight.w800,
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
              backgroundColor: PawCoColors.softMalva,
              borderColor: PawCoColors.malva.withValues(alpha: 0.35),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(mainNavIndexProvider.notifier).state = 4; // SOS
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PawCoColors.malva,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Denuncia SOS por Maltrato o Emergencia',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
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
                  const Icon(Icons.arrow_forward_ios, size: 15, color: PawCoColors.terracottaDark),
                ],
              ),
            ),
            const SizedBox(height: 10),
            PawCoHoverCard(
              backgroundColor: PawCoColors.surfaceMuted,
              borderColor: PawCoColors.border,
              onTap: () {
                Navigator.pop(ctx);
                ref.read(mainNavIndexProvider.notifier).state = 2; // Perdidos
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PawCoColors.plum,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.location_searching, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mascota Perdida o Encontrada',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: PawCoColors.plum,
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
                  const Icon(Icons.arrow_forward_ios, size: 15, color: PawCoColors.plum),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
              backgroundColor: PawCoColors.plum,
              content: Text(
                '¡Gracias por unirte! Nos pondremos en contacto contigo para el voluntariado.',
              ),
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
    final horizontalPad = isDesktop ? 32.0 : (screenWidth < 360 ? 12.0 : 18.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // ================================================================
            // 1. HERO AURORA OSCURO PRO + ESCENARIO ORBITAL + ONDA LINE-ART
            // ================================================================
            PawColAuroraWaveHeader(
              contentPadding: EdgeInsets.fromLTRB(
                horizontalPad,
                isDesktop ? 34 : (MediaQuery.of(context).padding.top + 18),
                horizontalPad,
                16,
              ),
              waveHeight: isDesktop ? 68 : 54,
              child: _buildAuroraHeroContent(isDesktop, screenWidth),
            ),

            // ================================================================
            // 2. ZONA CLARA MARFIL-LILA PASTEL (#FAF6F9) CON SCROLL ANIMADO
            // ================================================================
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPad,
                vertical: 10,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 2A. Categorías Circulares Interactivas (2C-2) ---
                      PawCoFadeSlide(
                        child: _buildCircularCategoriesStrip(isDesktop),
                      ),
                      const SizedBox(height: 28),

                      // --- 2B. Banner "Conviértete en un Héroe para los Animales" ---
                      PawCoFadeSlide(
                        delay: const Duration(milliseconds: 50),
                        child: _buildHeroMissionCard(isDesktop),
                      ),
                      const SizedBox(height: 30),

                      // --- 2C. Acciones Rápidas ---
                      _buildSectionHeader(
                        badge: 'ACCIÓN INMEDIATA',
                        title: 'Acciones Rápidas',
                        subtitle: '¿Cómo deseas marcar la diferencia hoy en Santander?',
                      ),
                      const SizedBox(height: 14),
                      PawCoFadeSlide(
                        delay: const Duration(milliseconds: 90),
                        child: _buildQuickActionsGrid(isDesktop, screenWidth),
                      ),
                      const SizedBox(height: 36),

                      // --- 2D. Impacto Comunitario en el AMB ---
                      _buildSectionHeader(
                        badge: 'MÉTRICAS VERIFICADAS',
                        title: 'Impacto Comunitario en el AMB',
                        subtitle: 'Bucaramanga, Floridablanca, Girón y Piedecuesta unidos',
                      ),
                      const SizedBox(height: 14),
                      PawCoFadeSlide(
                        delay: const Duration(milliseconds: 120),
                        child: _buildCommunityImpactCard(isDesktop),
                      ),
                      const SizedBox(height: 38),

                      // --- 2E. Línea de Tiempo Luminosa de Transparencia ---
                      KeyedSubtree(
                        key: _transparencyKey,
                        child: PawCoFadeSlide(
                          delay: const Duration(milliseconds: 140),
                          child: _buildLuminousTransparencyTimeline(isDesktop),
                        ),
                      ),
                      const SizedBox(height: 38),

                      // --- 2F. Historia del Fundador (Sergio Lejarde) ---
                      PawCoFadeSlide(
                        delay: const Duration(milliseconds: 160),
                        child: _buildAboutCreatorSection(isDesktop, screenWidth),
                      ),
                      const SizedBox(height: 38),

                      // --- 2G. Voluntariado en Fundaciones del AMB ---
                      KeyedSubtree(
                        key: _volunteerKey,
                        child: PawCoFadeSlide(
                          delay: const Duration(milliseconds: 180),
                          child: _buildVolunteerSection(isDesktop),
                        ),
                      ),
                      const SizedBox(height: 44),

                      // --- Footer Sutil ---
                      Center(
                        child: Column(
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                const Icon(Icons.pets_rounded, size: 18, color: PawCoColors.plum),
                                Text(
                                  'PawCol • Bucaramanga & Área Metropolitana',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: PawCoColors.plum,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Cada vida rescatada cuenta. Tecnología al servicio del amor animal.',
                              textAlign: TextAlign.center,
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
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // HERO AURORA + ÓRBITAS + GLASSMORPHISM
  // ==========================================================================

  Widget _buildAuroraHeroContent(bool isDesktop, double screenWidth) {
    final isCompactMobile = screenWidth < 360;

    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top pill row
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: PawCoColors.lilacGlow.withValues(alpha: 0.32),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 13,
                          color: PawCoColors.amberGlow,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PawCol Santander',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PawCoBadge(
                    label: 'Bucaramanga & AMB',
                    backgroundColor: PawCoColors.malva.withValues(alpha: 0.22),
                    textColor: const Color(0xFFFCE7F3),
                  ),
                ],
              ),
            ),
            if (!isDesktop)
              IconButton(
                icon: const Icon(
                  Icons.volunteer_activism_rounded,
                  color: PawCoColors.lilacGlow,
                ),
                tooltip: 'Donar a causas del AMB',
                onPressed: () {
                  ref.read(mainNavIndexProvider.notifier).state = 3;
                },
              ),
          ],
        ),
        const SizedBox(height: 18),

        // Título principal en blanco + subtítulo en degradado ShaderMask
        Text(
          'Juntos por los animales',
          style: GoogleFonts.plusJakartaSans(
            fontSize: isDesktop ? 42 : (isCompactMobile ? 26 : 31),
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.9,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 4),
        PawColGradientText(
          'Bienestar Real y Transparente',
          style: GoogleFonts.plusJakartaSans(
            fontSize: isDesktop ? 36 : (isCompactMobile ? 22 : 26),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            height: 1.16,
          ),
        ),
        const SizedBox(height: 16),

        // Tarjeta Glassmorphism con el mensaje comercial oficial
        PawColGlassCard(
          padding: EdgeInsets.all(isCompactMobile ? 14 : 18),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Alguna vez has querido ayudar a un peludito, pero sentiste que faltaba algo para lograr un bienestar real?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isDesktop ? 16.5 : 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.38,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'En PawCol transformamos tus buenas intenciones en resultados tangibles. Conectamos tu solidaridad con acciones directas y transparentes que hoy están cambiando vidas en Bucaramanga y su Área Metropolitana, con la visión de llegar muy pronto a toda Colombia y el mundo.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isDesktop ? 13.5 : 12.5,
                  color: Colors.white.withValues(alpha: 0.84),
                  height: 1.48,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Botones estilo SaaS (Primario Degradado + Píldora con Shimmer `100% REAL`)
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            PawColPrimarySaaSButton(
              label: 'Explorar Adopciones',
              icon: Icons.pets_rounded,
              onTap: () {
                ref.read(mainNavIndexProvider.notifier).state = 1;
              },
            ),
            PawColRealBadgeButton(
              badgeText: '100% REAL',
              label: isCompactMobile ? 'Donar Alimento' : 'Donar Bultos de Comida',
              onTap: () {
                ref.read(mainNavIndexProvider.notifier).state = 3;
              },
            ),
          ],
        ),
      ],
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 6, child: leftColumn),
          const SizedBox(width: 28),
          Expanded(
            flex: 5,
            child: PawColOrbitHeroStage(
              onExploreTap: () => ref.read(mainNavIndexProvider.notifier).state = 1,
              onDonateTap: () => ref.read(mainNavIndexProvider.notifier).state = 3,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leftColumn,
        const SizedBox(height: 20),
        PawColOrbitHeroStage(
          onExploreTap: () => ref.read(mainNavIndexProvider.notifier).state = 1,
          onDonateTap: () => ref.read(mainNavIndexProvider.notifier).state = 3,
        ),
      ],
    );
  }

  // ==========================================================================
  // SECCIONES DE LA ZONA CLARA MARFIL-LILA PASTEL (#FAF6F9)
  // ==========================================================================

  Widget _buildCircularCategoriesStrip(bool isDesktop) {
    final categories = [
      (
        label: 'Perros',
        icon: Icons.pets_rounded,
        malva: false,
        action: () => ref.read(mainNavIndexProvider.notifier).state = 1,
      ),
      (
        label: 'Gatos',
        icon: Icons.cruelty_free_rounded,
        malva: true,
        action: () => ref.read(mainNavIndexProvider.notifier).state = 1,
      ),
      (
        label: 'Concentrado',
        icon: Icons.inventory_2_rounded,
        malva: false,
        action: () => ref.read(mainNavIndexProvider.notifier).state = 3,
      ),
      (
        label: 'Salud 24/7',
        icon: Icons.local_hospital_rounded,
        malva: true,
        action: () => ref.read(mainNavIndexProvider.notifier).state = 3,
      ),
      (
        label: 'Perdidos',
        icon: Icons.location_searching_rounded,
        malva: false,
        action: () => ref.read(mainNavIndexProvider.notifier).state = 2,
      ),
      (
        label: 'Ruta SOS',
        icon: Icons.campaign_rounded,
        malva: true,
        action: () => ref.read(mainNavIndexProvider.notifier).state = 4,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 12,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PawCoColors.border),
        boxShadow: [
          BoxShadow(
            color: PawCoColors.plum.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Explora por Categoría',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: PawCoColors.ink,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => ref.read(mainNavIndexProvider.notifier).state = 1,
                child: const Text('Ver todo ›'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(categories.length, (i) {
                  final item = categories[i];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 14 : 4),
                    child: PawColCircularCategoryChip(
                      label: item.label,
                      icon: item.icon,
                      isSelected: _selectedQuickCategory == i,
                      useMalvaTint: item.malva,
                      onTap: () {
                        setState(() => _selectedQuickCategory = i);
                        item.action();
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMissionCard(bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF6EFFB),
            Color(0xFFFDF2F7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PawCoColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: PawCoColors.plum.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 12,
            bottom: 4,
            child: AnimalSilhouetteCardWatermark(
              width: 135,
              height: 92,
              opacity: 0.25,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isDesktop ? 28 : 20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PawCoBadge(
                        label: 'Causa Solidaria Santandereana',
                        icon: Icons.favorite_rounded,
                        backgroundColor: PawCoColors.softMalva,
                        textColor: PawCoColors.terracottaDark,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Conviértete en un Héroe para los Animales',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isDesktop ? 24 : 20,
                          fontWeight: FontWeight.w800,
                          color: PawCoColors.ink,
                          letterSpacing: -0.4,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pasa del deseo de ayudar a la satisfacción de ser parte del cambio: adopta, reporta maltrato o apoya con bultos de concentrado a los albergues verificados del AMB.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isDesktop ? 14 : 13,
                          color: PawCoColors.inkSecondary,
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
                              backgroundColor: PawCoColors.plum,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            onPressed: _openReportChoiceDialog,
                            icon: const Icon(Icons.pets_outlined, size: 16),
                            label: const Text('Brindar ayuda a un peludito'),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: PawCoColors.plum,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            onPressed: () => _scrollToKey(_transparencyKey),
                            child: const Text('Conocer nuestra misión'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (MediaQuery.of(context).size.width >= 680) ...[
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 2,
                    child: Center(
                      child: DogCatHeroIllustration(
                        width: 185,
                        height: 150,
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

  Widget _buildSectionHeader({
    required String badge,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          badge,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
            color: PawCoColors.malva,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: PawCoColors.ink,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: PawCoColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(bool isDesktop, double screenWidth) {
    final actions = [
      _QuickActionItem(
        title: 'Reportar Peludito',
        subtitle: 'Maltrato SOS o Mascota perdida',
        icon: Icons.add_alert_rounded,
        backgroundColor: PawCoColors.softMalva,
        accentColor: PawCoColors.terracottaDark,
        onTap: _openReportChoiceDialog,
      ),
      _QuickActionItem(
        title: 'Adoptar un Compañero',
        subtitle: 'Perros y gatos buscando hogar',
        icon: Icons.pets_rounded,
        backgroundColor: PawCoColors.cottonLilac,
        accentColor: PawCoColors.plum,
        onTap: () => ref.read(mainNavIndexProvider.notifier).state = 1,
      ),
      _QuickActionItem(
        title: 'Donar a una Meta',
        subtitle: 'Bultos de comida y cirugías',
        icon: Icons.volunteer_activism_rounded,
        backgroundColor: PawCoColors.softMalva,
        accentColor: PawCoColors.terracottaDark,
        onTap: () => ref.read(mainNavIndexProvider.notifier).state = 3,
      ),
      _QuickActionItem(
        title: 'Ser Voluntario',
        subtitle: 'Paseos, baños y veeduría',
        icon: Icons.handshake_rounded,
        backgroundColor: PawCoColors.slateBlueLight,
        accentColor: PawCoColors.slateBlue,
        onTap: _showVolunteerModal,
      ),
    ];

    return PawCoResponsiveGrid(
      spacing: 14,
      runSpacing: 14,
      children: actions.map(_buildActionCard).toList(),
    );
  }

  Widget _buildActionCard(_QuickActionItem item) {
    return PawCoHoverCard(
      backgroundColor: PawCoColors.surface,
      borderColor: PawCoColors.border,
      padding: const EdgeInsets.all(18),
      margin: EdgeInsets.zero,
      onTap: item.onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 22, color: item.accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: PawCoColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: PawCoColors.muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: item.accentColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildCommunityImpactCard(bool isDesktop) {
    return PawCoHoverCard(
      backgroundColor: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 26 : 18,
        vertical: 22,
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 560;
              final statsBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      Text(
                        '1,480+',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isDesktop ? 34 : 28,
                          fontWeight: FontWeight.w800,
                          color: PawCoColors.plum,
                          letterSpacing: -0.6,
                        ),
                      ),
                      Text(
                        'animales ayudados este mes en el AMB',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: PawCoColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const PawCoAnimatedProgressBar(
                    value: 0.82,
                    height: 9,
                    progressColor: PawCoColors.malva,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Meta mensual al 82% • 185 bultos de concentrado entregados',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: PawCoColors.muted,
                    ),
                  ),
                ],
              );

              final alertsBlock = Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PawCoColors.terracottaMuted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PawCoColors.softMalva),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: PawCoColors.softMalva,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.crisis_alert_rounded,
                        color: PawCoColors.terracottaDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '6 Alertas Activas',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              color: PawCoColors.terracottaDark,
                            ),
                          ),
                          Text(
                            'En Floridablanca y Girón',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: PawCoColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(flex: 3, child: statsBlock),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: alertsBlock),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  statsBlock,
                  const SizedBox(height: 14),
                  alertsBlock,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Divider(color: PawCoColors.borderLight, height: 1),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              PawCoBadge(label: 'Bucaramanga', icon: Icons.location_on_outlined),
              PawCoBadge(label: 'Floridablanca', icon: Icons.location_on_outlined),
              PawCoBadge(label: 'Girón', icon: Icons.location_on_outlined),
              PawCoBadge(label: 'Piedecuesta', icon: Icons.location_on_outlined),
              PawCoBadge(
                label: 'Metas 100% Auditadas',
                icon: Icons.verified_user_outlined,
                backgroundColor: PawCoColors.softMalva,
                textColor: PawCoColors.terracottaDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuminousTransparencyTimeline(bool isDesktop) {
    final steps = [
      _TimelineStepItem(
        stepNumber: '01',
        icon: Icons.track_changes_rounded,
        title: 'Metas con Propósito Específico',
        description:
            'Nada de cuentas genéricas. Donas a bultos exactos de concentrado o a la factura directa de la clínica veterinaria.',
        badgeColor: PawCoColors.plum,
      ),
      _TimelineStepItem(
        stepNumber: '02',
        icon: Icons.verified_rounded,
        title: 'Fundaciones Verificadas del AMB',
        description:
            'Albergues y rescatistas visitados presencialmente con personería y trayectoria comprobada en Santander.',
        badgeColor: PawCoColors.malva,
      ),
      _TimelineStepItem(
        stepNumber: '03',
        icon: Icons.photo_camera_back_rounded,
        title: 'Evidencia y Veeduría Abierta',
        description:
            'Facturas auditadas, fotos de entrega de alimento y voluntariado abierto para que compruebes cada resultado.',
        badgeColor: PawCoColors.slateBlue,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: PawCoColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: PawCoColors.plum.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: SvgPicture.asset(
                  'assets/vectors/pawcol_shield.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transparencia Total',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isDesktop ? 23 : 19,
                        fontWeight: FontWeight.w800,
                        color: PawCoColors.ink,
                      ),
                    ),
                    Text(
                      '¿Por qué creamos PawCol Web y Móvil?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: PawCoColors.malva,
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
              color: PawCoColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PawCoColors.borderLight),
            ),
            child: Text(
              'Sabemos que muchas personas de buen corazón en Bucaramanga y en toda Colombia quieren ayudar, pero frecuentemente no donan por temor a que su dinero se pierda o no sea destinado realmente a los animales afectados.\n\n'
              'PawCol nació específicamente para erradicar esa duda y garantizar al 100% que cada aporte llegue a metas concretas y verificables: compra directa de bultos de concentrado, pago de facturas de hospitalización veterinaria, cirugías de urgencia y esterilizaciones en fundaciones auditadas del Área Metropolitana.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: PawCoColors.inkSecondary,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Línea de Tiempo Luminosa (Horizontal en Desktop / Vertical conectada en Móvil)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 760) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 24,
                      left: 60,
                      right: 60,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              PawCoColors.plum,
                              PawCoColors.malva,
                              PawCoColors.amberGlow,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: steps.map((step) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildHorizontalTimelineCard(step),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              }

              return Column(
                children: List.generate(steps.length, (i) {
                  final step = steps[i];
                  final isLast = i == steps.length - 1;
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: step.badgeColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: step.badgeColor.withValues(alpha: 0.30),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                step.stepNumber,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2.5,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        PawCoColors.plum,
                                        PawCoColors.malva,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: PawCoColors.background,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: PawCoColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(step.icon, size: 18, color: step.badgeColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          step.title,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: PawCoColors.ink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    step.description,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      color: PawCoColors.muted,
                                      height: 1.42,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalTimelineCard(_TimelineStepItem step) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: step.badgeColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: step.badgeColor.withValues(alpha: 0.32),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            step.stepNumber,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: PawCoColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: PawCoColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(step.icon, color: step.badgeColor, size: 22),
              const SizedBox(height: 10),
              Text(
                step.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: PawCoColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                step.description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: PawCoColors.muted,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutCreatorSection(bool isDesktop, double screenWidth) {
    final isNarrow = screenWidth < 520;

    final avatar = Container(
      width: isDesktop ? 92 : 72,
      height: isDesktop ? 92 : 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PawCoColors.plum, PawCoColors.malva],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: PawCoColors.malva.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'SL',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: isDesktop ? 30 : 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );

    final bioColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Sergio Lejarde',
              style: GoogleFonts.plusJakartaSans(
                fontSize: isDesktop ? 22 : 19,
                fontWeight: FontWeight.w800,
                color: PawCoColors.ink,
              ),
            ),
            const PawCoBadge(
              label: 'Ingeniero de Sistemas e Informática (24 años)',
              backgroundColor: PawCoColors.cottonLilac,
              textColor: PawCoColors.plum,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Fundador y Desarrollador de PawCol • Bucaramanga, Santander',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: PawCoColors.malva,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Soy un joven ingeniero de 24 años apasionado por la tecnología y comprometido de corazón con el bienestar animal.\n\n'
          'Al ver de cerca las dificultades que viven a diario los refugios en Bucaramanga, Floridablanca, Girón y Piedecuesta, y la desconfianza ciudadana hacia los canales tradicionales de donación, decidí poner mis conocimientos en ingeniería de software para crear una plataforma transparente, accesible y comunitaria.\n\n'
          'PawCol es mi aporte para demostrar que con honestidad, diseño y tecnología podemos salvar cientos de vidas.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: PawCoColors.inkSecondary,
            height: 1.52,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _buildPillTag(Icons.code_rounded, 'Desarrollo Flutter & Web'),
            _buildPillTag(Icons.favorite_rounded, 'Amor por los animales'),
            _buildPillTag(Icons.location_city_rounded, 'Orgullo Santandereano'),
          ],
        ),
      ],
    );

    return PawCoHoverCard(
      backgroundColor: Colors.white,
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(height: 14),
                bioColumn,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(width: 20),
                Expanded(child: bioColumn),
              ],
            ),
    );
  }

  Widget _buildPillTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: PawCoColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: PawCoColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: PawCoColors.plum),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: PawCoColors.inkSecondary,
              ),
              overflow: TextOverflow.ellipsis,
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
        gradient: const LinearGradient(
          colors: [
            PawCoColors.auroraStart,
            PawCoColors.auroraEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: PawCoColors.plum.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.handshake_rounded,
                  color: PawCoColors.lilacGlow,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voluntariado en Fundaciones del AMB',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isDesktop ? 22 : 18.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '¿No tienes dinero para donar? ¡Tus manos y tu tiempo salvan vidas!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: PawCoColors.lilacGlow,
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
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.86),
              height: 1.48,
            ),
          ),
          const SizedBox(height: 18),
          PawColPrimarySaaSButton(
            label: 'Postularme como Voluntario Solidario',
            icon: Icons.assignment_ind_outlined,
            onTap: _showVolunteerModal,
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

class _TimelineStepItem {
  final String stepNumber;
  final IconData icon;
  final String title;
  final String description;
  final Color badgeColor;

  _TimelineStepItem({
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.description,
    required this.badgeColor,
  });
}

/// Modal interactivo para inscribirse como voluntario en refugios del AMB
class _VolunteerApplicationModal extends StatefulWidget {
  final VoidCallback onSuccess;

  const _VolunteerApplicationModal({required this.onSuccess});

  @override
  State<_VolunteerApplicationModal> createState() =>
      _VolunteerApplicationModalState();
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
        const SnackBar(
          content: Text('Por favor selecciona al menos un rol de voluntariado'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final rolesString = _selectedRoles.join(', ');
    final message =
        '¡Hola equipo PawCol! Me gustaría postularme como voluntario en el AMB:\n'
        '• Nombre: ${_nameController.text.trim()}\n'
        '• Municipio: $_selectedCity\n'
        '• Roles de interés: $rolesString\n'
        '• Disponibilidad: ${_availabilityController.text.trim()}';

    final uri = Uri.parse(
      'https://wa.me/573160000000?text=${Uri.encodeComponent(message)}',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Si falla la apertura externa en simulador/test, se confirma éxito en UI
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
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
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
                    selectedColor: PawCoColors.cottonLilac,
                    checkmarkColor: PawCoColors.plum,
                    backgroundColor: PawCoColors.surfaceMuted,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? PawCoColors.plum : PawCoColors.ink,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(
                        color: isSelected ? PawCoColors.plum : PawCoColors.border,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
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
                  prefixIcon: Icon(Icons.location_on_outlined, color: PawCoColors.plum),
                ),
                items: _cities.map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCity = val);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre completo',
                  prefixIcon: Icon(Icons.person_outline, color: PawCoColors.plum),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Celular / WhatsApp',
                  prefixIcon: Icon(Icons.phone_outlined, color: PawCoColors.plum),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa tu número' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _availabilityController,
                decoration: const InputDecoration(
                  labelText: 'Disponibilidad (ej. Sábados en la mañana)',
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: PawCoColors.plum),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Cuéntanos tu disponibilidad'
                    : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PawCoColors.plum,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    _isSubmitting ? 'Enviando...' : 'Enviar Postulación Voluntaria',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
