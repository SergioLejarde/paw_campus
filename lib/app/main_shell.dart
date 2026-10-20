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

/// 🐾 Shell principal de PawCo con navegación adaptable:
/// - Web / Tablet horizontal (>= 860px): Barra superior de aplicación web moderna (_WebTopNavBar)
/// - Móvil (< 860px): Barra inferior estilizada (NavigationBar) con 6 destinos
/// - Fondo enriquecido con siluetas artísticas reconocibles de perros y gatos
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainNavIndexProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 860;

    final List<Widget> pages = [
      const OverviewPage(), // 0: Inicio, Quiénes Somos y Voluntariado
      const AdoptionsPage(), // 1: Adopciones
      const LostPetsPage(), // 2: Perdidos & Mapa
      const DonationsPage(), // 3: Fundaciones & Donar
      const SosPage(), // 4: Denunciar SOS
      const ProfilePage(), // 5: Mi Perfil
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
                child: IndexedStack(
                  index: currentIndex,
                  children: pages,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(color: PawCoColors.border, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) {
                  ref.read(mainNavIndexProvider.notifier).state = index;
                },
                backgroundColor: Colors.white,
                elevation: 0,
                indicatorColor: PawCoColors.sageLight,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home, color: PawCoColors.forest),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.pets_outlined),
                    selectedIcon: Icon(Icons.pets, color: PawCoColors.forest),
                    label: 'Adoptar',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.location_on_outlined),
                    selectedIcon: Icon(Icons.location_on, color: PawCoColors.forest),
                    label: 'Perdidos',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.volunteer_activism_outlined),
                    selectedIcon: Icon(Icons.volunteer_activism, color: PawCoColors.forest),
                    label: 'Donar',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.campaign_outlined, color: PawCoColors.terracotta),
                    selectedIcon: Icon(Icons.campaign, color: PawCoColors.terracottaDark),
                    label: 'SOS',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person, color: PawCoColors.forest),
                    label: 'Perfil',
                  ),
                ],
              ),
            ),
    );
  }
}

/// 💻 Barra de Navegación Superior para Web y Escritorio (>= 860px)
class _WebTopNavBar extends StatelessWidget {
  final int currentIndex;
  final WidgetRef ref;

  const _WebTopNavBar({
    required this.currentIndex,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: PawCoColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // --- LOGO Y MARCA ---
          InkWell(
            onTap: () => ref.read(mainNavIndexProvider.notifier).state = 0,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PawCoColors.forest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.pets, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'PawCo',
                    style: GoogleFonts.fraunces(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: PawCoColors.forest,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const PawCoBadge(
                    label: 'Bucaramanga & AMB',
                    icon: Icons.location_city,
                    backgroundColor: PawCoColors.sageLight,
                    textColor: PawCoColors.forest,
                    fontSize: 11,
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // --- PESTAÑAS HORIZONTALES MODERNAS ---
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavButton(
                index: 0,
                label: 'Inicio & Nosotros',
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
              ),
              const SizedBox(width: 6),
              _buildNavButton(
                index: 1,
                label: 'Adopciones',
                icon: Icons.pets_outlined,
                activeIcon: Icons.pets,
              ),
              const SizedBox(width: 6),
              _buildNavButton(
                index: 2,
                label: 'Perdidos & Mapa',
                icon: Icons.location_on_outlined,
                activeIcon: Icons.location_on,
              ),
              const SizedBox(width: 6),
              _buildNavButton(
                index: 3,
                label: 'Fundaciones & Donar',
                icon: Icons.volunteer_activism_outlined,
                activeIcon: Icons.volunteer_activism,
              ),
              const SizedBox(width: 6),
              _buildNavButton(
                index: 4,
                label: 'Denunciar SOS',
                icon: Icons.campaign_outlined,
                activeIcon: Icons.campaign,
                isSos: true,
              ),
            ],
          ),

          const Spacer(),

          // --- ACCIONES RÁPIDAS DERECHA ---
          Row(
            children: [
              // Botón Donar Ahora
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawCoColors.forest,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () => ref.read(mainNavIndexProvider.notifier).state = 3,
                icon: const Icon(Icons.favorite, size: 16, color: Colors.white),
                label: Text(
                  'Donar Ahora',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Botón Mi Perfil
              InkWell(
                onTap: () => ref.read(mainNavIndexProvider.notifier).state = 5,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: currentIndex == 5 ? PawCoColors.sageLight : PawCoColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: currentIndex == 5 ? PawCoColors.forest : PawCoColors.border,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18,
                        color: currentIndex == 5 ? PawCoColors.forest : PawCoColors.inkSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Mi Perfil',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: currentIndex == 5 ? FontWeight.w700 : FontWeight.w600,
                          color: currentIndex == 5 ? PawCoColors.forest : PawCoColors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
        ? (isSos ? PawCoColors.terracottaLight : PawCoColors.sageLight)
        : Colors.transparent;

    final textColor = isSelected
        ? (isSos ? PawCoColors.terracottaDark : PawCoColors.forest)
        : (isSos ? PawCoColors.terracotta : PawCoColors.inkSecondary);

    final borderColor = isSelected
        ? (isSos ? PawCoColors.terracotta.withValues(alpha: 0.4) : PawCoColors.sage.withValues(alpha: 0.4))
        : (isSos ? PawCoColors.terracottaLight : Colors.transparent);

    return InkWell(
      onTap: () => ref.read(mainNavIndexProvider.notifier).state = index,
      borderRadius: BorderRadius.circular(20),
      hoverColor: isSos ? PawCoColors.terracottaLight.withValues(alpha: 0.4) : PawCoColors.surfaceMuted,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 17,
              color: textColor,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
