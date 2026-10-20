import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/adoptions/presentation/adoptions_page.dart';
import '../features/donations/presentation/donations_page.dart';
import '../features/lost_pets/presentation/lost_pets_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/sos/presentation/sos_page.dart';

/// Provider reactivo para controlar la pestaña activa de navegación principal
final mainNavIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainNavIndexProvider);

    final List<Widget> pages = [
      const AdoptionsPage(),
      const LostPetsPage(),
      const SosPage(),
      const DonationsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(mainNavIndexProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Adopciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_searching_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Perdidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined, color: Color(0xFFE11D48)),
            selectedIcon: Icon(Icons.campaign, color: Color(0xFFE11D48)),
            label: 'SOS Denuncias',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism),
            label: 'Ayuda 24/7',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
