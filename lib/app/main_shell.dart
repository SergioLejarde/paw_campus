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

/// 🐾 Shell principal de PawCol con navegación adaptable y transiciones smooth:
/// - Web / Tablet horizontal (>= 860px): Barra superior minimalista y responsiva (_WebTopNavBar)
/// - Móvil (< 860px): Barra inferior limpia (NavigationBar) con 6 destinos
/// - Transiciones suaves (AnimatedSwitcher) al navegar entre módulos
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainNavIndexProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 860;

    final List<Widget> pages = [
      const OverviewPage(key: ValueKey('page_overview')), // 0: Inicio & Nosotros
      const AdoptionsPage(key: ValueKey('page_adoptions')), // 1: Adopciones
      const LostPetsPage(key: ValueKey('page_lost_pets')), // 2: Perdidos & Mapa
      const DonationsPage(key: ValueKey('page_donations')), // 3: Fundaciones & Donar
      const SosPage(key: ValueKey('page_sos')), // 4: Denunciar SOS
      const ProfilePage(key: ValueKey('page_profile')), // 5: Mi Perfil
    ];

    return Scaffold(
      backgroundColor: PawCoColors.background,
      body: AnimalSilhouetteBackground(
        child: Column(
          children: [
            if (isDesktop) _WebTopNavBar(currentIndex: currentIndex, ref: ref),
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
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: PawCoColors.border, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) {
                    ref.read(mainNavIndexProvider.notifier).state = index;
                  },
                  backgroundColor: Colors.white,
                  elevation: 0,
                  indicatorColor: PawCoColors.surfaceMuted,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home, color: PawCoColors.ink),
                      label: 'Inicio',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.pets_outlined),
                      selectedIcon: Icon(Icons.pets, color: PawCoColors.ink),
                      label: 'Adoptar',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.location_on_outlined),
                      selectedIcon: Icon(Icons.location_on, color: PawCoColors.ink),
                      label: 'Perdidos',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.volunteer_activism_outlined),
                      selectedIcon: Icon(Icons.volunteer_activism, color: PawCoColors.ink),
                      label: 'Donar',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.campaign_outlined, color: PawCoColors.terracotta),
                      selectedIcon: Icon(Icons.campaign, color: PawCoColors.terracottaDark),
                      label: 'SOS',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person, color: PawCoColors.ink),
                      label: 'Perfil',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// 💻 Barra de Navegación Superior Minimalista y Responsiva para Web y Escritorio (>= 860px)
class _WebTopNavBar extends StatelessWidget {
  final int currentIndex;
  final WidgetRef ref;

  const _WebTopNavBar({
    required this.currentIndex,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompactDesktop = width < 1120;

    return Container(
      height: 68,
      padding: EdgeInsets.symmetric(horizontal: isCompactDesktop ? 16 : 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: PawCoColors.border, width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            children: [
              // --- LOGO Y MARCA ---
              InkWell(
                onTap: () => ref.read(mainNavIndexProvider.notifier).state = 0,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: PawCoColors.ink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.pets, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'PawCol',
                        style: GoogleFonts.fraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: PawCoColors.ink,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (!isCompactDesktop) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: PawCoColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: PawCoColors.border),
                          ),
                          child: Text(
                            'Bucaramanga & AMB',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: PawCoColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // --- PESTAÑAS HORIZONTALES ADAPTABLES ---
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildNavButton(
                          index: 0,
                          label: isCompactDesktop ? 'Inicio' : 'Inicio & Nosotros',
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home,
                        ),
                        const SizedBox(width: 4),
                        _buildNavButton(
                          index: 1,
                          label: 'Adopciones',
                          icon: Icons.pets_outlined,
                          activeIcon: Icons.pets,
                        ),
                        const SizedBox(width: 4),
                        _buildNavButton(
                          index: 2,
                          label: isCompactDesktop ? 'Perdidos' : 'Perdidos & Mapa',
                          icon: Icons.location_on_outlined,
                          activeIcon: Icons.location_on,
                        ),
                        const SizedBox(width: 4),
                        _buildNavButton(
                          index: 3,
                          label: isCompactDesktop ? 'Fundaciones' : 'Fundaciones & Donar',
                          icon: Icons.volunteer_activism_outlined,
                          activeIcon: Icons.volunteer_activism,
                        ),
                        const SizedBox(width: 4),
                        _buildNavButton(
                          index: 4,
                          label: isCompactDesktop ? 'SOS' : 'Denunciar SOS',
                          icon: Icons.campaign_outlined,
                          activeIcon: Icons.campaign,
                          isSos: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // --- ACCIONES RÁPIDAS DERECHA ---
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PawCoColors.forest,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompactDesktop ? 12 : 16,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => ref.read(mainNavIndexProvider.notifier).state = 3,
                    icon: const Icon(Icons.favorite_border, size: 15, color: Colors.white),
                    label: Text(
                      isCompactDesktop ? 'Donar' : 'Donar Ahora',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => ref.read(mainNavIndexProvider.notifier).state = 5,
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: currentIndex == 5 ? PawCoColors.surfaceMuted : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: currentIndex == 5 ? PawCoColors.ink : PawCoColors.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 17,
                            color: currentIndex == 5 ? PawCoColors.ink : PawCoColors.inkSecondary,
                          ),
                          if (!isCompactDesktop) ...[
                            const SizedBox(width: 6),
                            Text(
                              'Mi Perfil',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: currentIndex == 5 ? FontWeight.w600 : FontWeight.w500,
                                color: currentIndex == 5 ? PawCoColors.ink : PawCoColors.inkSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    bool isSos = false,
  }) {
    final isSelected = currentIndex == index;

    final bgColor = isSelected
        ? (isSos ? PawCoColors.terracottaLight : PawCoColors.surfaceMuted)
        : Colors.transparent;

    final textColor = isSelected
        ? (isSos ? PawCoColors.terracottaDark : PawCoColors.ink)
        : (isSos ? PawCoColors.terracottaDark : PawCoColors.muted);

    final borderColor = isSelected
        ? (isSos ? PawCoColors.terracotta.withValues(alpha: 0.3) : PawCoColors.border)
        : Colors.transparent;

    return InkWell(
      onTap: () => ref.read(mainNavIndexProvider.notifier).state = index,
      borderRadius: BorderRadius.circular(10),
      hoverColor: PawCoColors.surfaceMuted.withValues(alpha: 0.6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuart,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 16,
              color: textColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
