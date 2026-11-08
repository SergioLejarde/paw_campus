import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/presentation/pawco_design_system.dart';
import '../features/adoptions/presentation/adoptions_page.dart';
import '../features/donations/presentation/donations_page.dart';
import '../features/lost_pets/presentation/lost_pets_page.dart';
import '../features/overview/presentation/overview_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/sos/presentation/sos_page.dart';
import 'theme.dart';

/// Provider reactivo para controlar la pestaña activa de navegación principal
final mainNavIndexProvider = StateProvider<int>((ref) => 0);

/// 💜 Shell principal de PawCol ("Aurora Híbrida + Paleta Violeta 2"):
/// - Web / Escritorio (>= 860px): Barra superior estilo SaaS moderno sobre fondo Aurora
///   con indicador activo inferior en degradado Lila-Malva e insignias luminosas.
/// - Móvil (< 860px): Barra de navegación inferior flotante tipo cápsula con cristal
///   esmerilado (`BackdropFilter`), 100% libre de overflow desde `320px`.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainNavIndexProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 860;

    final List<Widget> pages = const [
      OverviewPage(key: ValueKey('page_overview')), // 0: Inicio & Nosotros
      AdoptionsPage(key: ValueKey('page_adoptions')), // 1: Adopciones
      LostPetsPage(key: ValueKey('page_lost_pets')), // 2: Perdidos & Mapa
      DonationsPage(key: ValueKey('page_donations')), // 3: Fundaciones & Donar
      SosPage(key: ValueKey('page_sos')), // 4: Denunciar SOS
      ProfilePage(key: ValueKey('page_profile')), // 5: Mi Perfil
    ];

    return Scaffold(
      backgroundColor: PawCoColors.background,
      body: AnimalSilhouetteBackground(
        child: Column(
          children: [
            if (isDesktop) _WebSaaSTopNavBar(currentIndex: currentIndex, ref: ref),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  scaffoldBackgroundColor: Colors.transparent,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutQuart,
                  switchOutCurve: Curves.easeInQuart,
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(0.0, 0.012),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(currentIndex),
                    child: pages[currentIndex],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : _MobileFloatingCapsuleNavBar(
              currentIndex: currentIndex,
              onSelect: (index) {
                ref.read(mainNavIndexProvider.notifier).state = index;
              },
            ),
    );
  }
}

/// 📱 Barra de navegación inferior flotante tipo cápsula (Móvil `< 860px`)
class _MobileFloatingCapsuleNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _MobileFloatingCapsuleNavBar({
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isUltraCompact = screenWidth < 360;

    final items = const [
      _CapsuleNavSpec(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Inicio',
      ),
      _CapsuleNavSpec(
        icon: Icons.pets_outlined,
        activeIcon: Icons.pets_rounded,
        label: 'Adoptar',
      ),
      _CapsuleNavSpec(
        icon: Icons.location_on_outlined,
        activeIcon: Icons.location_on_rounded,
        label: 'Perdidos',
      ),
      _CapsuleNavSpec(
        icon: Icons.volunteer_activism_outlined,
        activeIcon: Icons.volunteer_activism_rounded,
        label: 'Donar',
      ),
      _CapsuleNavSpec(
        icon: Icons.campaign_outlined,
        activeIcon: Icons.campaign_rounded,
        label: 'SOS',
        isAccent: true,
      ),
      _CapsuleNavSpec(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Perfil',
      ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isUltraCompact ? 8 : 14,
          4,
          isUltraCompact ? 8 : 14,
          10,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 66,
              padding: EdgeInsets.symmetric(horizontal: isUltraCompact ? 4 : 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: PawCoColors.border,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: PawCoColors.plum.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(items.length, (index) {
                  final spec = items[index];
                  final isSelected = currentIndex == index;
                  final activeBg = spec.isAccent
                      ? PawCoColors.malva
                      : PawCoColors.plum;
                  final idleColor = spec.isAccent
                      ? PawCoColors.terracottaDark
                      : PawCoColors.muted;

                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onSelect(index),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 2,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSelected
                                      ? (isUltraCompact ? 8 : 11)
                                      : 6,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? activeBg
                                      : (spec.isAccent
                                          ? PawCoColors.softMalva
                                              .withValues(alpha: 0.55)
                                          : Colors.transparent),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  isSelected ? spec.activeIcon : spec.icon,
                                  size: isUltraCompact ? 18 : 20,
                                  color: isSelected ? Colors.white : idleColor,
                                ),
                              ),
                              const SizedBox(height: 3),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  spec.label,
                                  maxLines: 1,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: isUltraCompact ? 9.5 : 10.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? (spec.isAccent
                                            ? PawCoColors.terracottaDark
                                            : PawCoColors.plum)
                                        : idleColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CapsuleNavSpec {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isAccent;

  const _CapsuleNavSpec({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isAccent = false,
  });
}

/// 💻 Barra de Navegación Superior Estilo SaaS Moderno (Web / Escritorio `>= 860px`)
/// Propuesta v3 "Lienzo Continuo": Cristal esmerilado claro (`BackdropFilter`),
/// marca `{PawCol}` en Morado Mora y acentos Malva sin cortes oscuros artificiales.
class _WebSaaSTopNavBar extends StatelessWidget {
  final int currentIndex;
  final WidgetRef ref;

  const _WebSaaSTopNavBar({
    required this.currentIndex,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompactDesktop = width < 1140;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 68,
          padding: EdgeInsets.symmetric(horizontal: isCompactDesktop ? 16 : 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            border: const Border(
              bottom: BorderSide(
                color: PawCoColors.border,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: PawCoColors.plum.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Row(
                children: [
                  // --- LOGO SAAS `{PawCol}` ---
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => ref.read(mainNavIndexProvider.notifier).state = 0,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [PawCoColors.orchid, PawCoColors.malva],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(
                                Icons.pets_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                                children: const [
                                  TextSpan(
                                    text: '{',
                                    style: TextStyle(color: PawCoColors.orchid),
                                  ),
                                  TextSpan(
                                    text: 'PawCol',
                                    style: TextStyle(color: PawCoColors.ink),
                                  ),
                                  TextSpan(
                                    text: '}',
                                    style: TextStyle(color: PawCoColors.malva),
                                  ),
                                ],
                              ),
                            ),
                            if (!isCompactDesktop) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: PawCoColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: PawCoColors.border,
                                  ),
                                ),
                                child: Text(
                                  'COL • AMB',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: PawCoColors.plum,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // --- PESTAÑAS HORIZONTALES CON INDICADOR EN DEGRADADO ---
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildSaaSNavItem(
                              index: 0,
                              label: isCompactDesktop ? 'Inicio' : 'Inicio & Nosotros',
                              icon: Icons.home_outlined,
                              activeIcon: Icons.home_rounded,
                            ),
                            const SizedBox(width: 6),
                            _buildSaaSNavItem(
                              index: 1,
                              label: 'Adopciones',
                              icon: Icons.pets_outlined,
                              activeIcon: Icons.pets_rounded,
                            ),
                            const SizedBox(width: 6),
                            _buildSaaSNavItem(
                              index: 2,
                              label: isCompactDesktop ? 'Perdidos' : 'Perdidos & Mapa',
                              icon: Icons.location_on_outlined,
                              activeIcon: Icons.location_on_rounded,
                            ),
                            const SizedBox(width: 6),
                            _buildSaaSNavItem(
                              index: 3,
                              label: isCompactDesktop ? 'Donar' : 'Fundaciones & Donar',
                              icon: Icons.volunteer_activism_outlined,
                              activeIcon: Icons.volunteer_activism_rounded,
                            ),
                            const SizedBox(width: 6),
                            _buildSaaSNavItem(
                              index: 4,
                              label: isCompactDesktop ? 'SOS' : 'Denunciar SOS',
                              icon: Icons.campaign_outlined,
                              activeIcon: Icons.campaign_rounded,
                              isSos: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // --- ACCIONES RÁPIDAS DERECHA ESTILO BRACE / SAAS ---
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón píldora Donar con degradado Malva
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [PawCoColors.plumVibrant, PawCoColors.malva],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: PawCoColors.malva.withValues(alpha: 0.30),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => ref.read(mainNavIndexProvider.notifier).state = 3,
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isCompactDesktop ? 13 : 17,
                                vertical: 9,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.favorite_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isCompactDesktop ? 'Donar' : 'Donar Ahora',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => ref.read(mainNavIndexProvider.notifier).state = 5,
                          borderRadius: BorderRadius.circular(999),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 8.5,
                            ),
                            decoration: BoxDecoration(
                              color: currentIndex == 5
                                  ? PawCoColors.surfaceMuted
                                  : PawCoColors.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: currentIndex == 5
                                    ? PawCoColors.plum
                                    : PawCoColors.border,
                                width: 1.1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 17,
                                  color: currentIndex == 5
                                      ? PawCoColors.plum
                                      : PawCoColors.inkSecondary,
                                ),
                                if (!isCompactDesktop) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    'Mi Perfil',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: currentIndex == 5
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: currentIndex == 5
                                          ? PawCoColors.plum
                                          : PawCoColors.ink,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaaSNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    bool isSos = false,
  }) {
    final isSelected = currentIndex == index;
    final textColor = isSelected
        ? PawCoColors.plum
        : (isSos
            ? PawCoColors.terracottaDark
            : PawCoColors.inkSecondary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(mainNavIndexProvider.notifier).state = index,
        borderRadius: BorderRadius.circular(12),
        hoverColor: PawCoColors.surfaceMuted.withValues(alpha: 0.6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    size: 16,
                    color: isSelected
                        ? (isSos ? PawCoColors.malva : PawCoColors.plum)
                        : textColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              // Indicador activo inferior en degradado Lila -> Rosa Malva
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 2.5,
                width: isSelected ? 28 : 0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [PawCoColors.plum, PawCoColors.malva],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
