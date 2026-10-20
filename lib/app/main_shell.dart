import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/adoptions/presentation/adoptions_page.dart';
import '../features/donations/presentation/donations_page.dart';
import '../features/profile/presentation/profile_page.dart';

/// Provider reactivo para controlar la pestaña activa de navegación principal
final mainNavIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainNavIndexProvider);

    final List<Widget> pages = [
      const AdoptionsPage(),
      const _LostPetsPlaceholderView(),
      const _SosPlaceholderView(),
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

/// Vista previa / placeholder para el módulo de Mascotas Perdidas (Fase 3)
class _LostPetsPlaceholderView extends StatelessWidget {
  const _LostPetsPlaceholderView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 Perdidos y Encontrados'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        size: 48,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Módulo Perdidos y Mapa',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bucaramanga • Floridablanca • Girón • Piedecuesta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D9488),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Próximamente en Fase 3:\n'
                      'Podrás publicar alertas inmediatas de mascotas extraviadas o avistadas, '
                      'explorar el mapa interactivo con OpenStreetMap y contactar directamente vía WhatsApp.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Chip(
                      backgroundColor: const Color(0xFFCCFBF1),
                      avatar: const Icon(Icons.build_circle_outlined, size: 18, color: Color(0xFF0F766E)),
                      label: const Text(
                        'Preparado para Fase 3',
                        style: TextStyle(
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Vista de emergencia y rutas oficiales de denuncia de maltrato en Colombia (Fase 2)
class _SosPlaceholderView extends StatelessWidget {
  const _SosPlaceholderView();

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Color(0xFFE11D48)),
            SizedBox(width: 8),
            Text('🚨 SOS Maltrato Animal'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDA4AF)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFFE11D48), size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Protección Animal en Colombia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9F1239),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'El maltrato animal es un delito sancionado por la Ley 1774 de 2016.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF881337),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFE4E6),
                  child: Icon(Icons.phone_in_talk, color: Color(0xFFE11D48)),
                ),
                title: const Text(
                  'Línea 123 — Emergencias y Policía Nacional',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Para casos en flagrancia o peligro inminente de vida.'),
                trailing: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                  ),
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Llamar'),
                  onPressed: () => _makeCall('123'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFEF3C7),
                  child: Icon(Icons.gavel, color: Color(0xFFD97706)),
                ),
                title: const Text(
                  'Fiscalía General — Grupo GELMA (Línea 122)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Grupo Especial para la Lucha Contra el Maltrato Animal.'),
                trailing: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                  ),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Denunciar'),
                  onPressed: () => _openLink('https://sicecon.fiscalia.gov.co/denuncia/LlenarFormulario'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.add_alert_outlined, color: Color(0xFF0D9488), size: 36),
                    const SizedBox(height: 10),
                    const Text(
                      'Reporte Ciudadano PawCo (Fase 2)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'En la Fase 2 podrás radicar reportes con fotos, ubicación en Bucaramanga y opción de denuncia anónima.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
