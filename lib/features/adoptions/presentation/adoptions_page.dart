import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/pets_repository.dart';
import 'add_pet_page.dart';

/// Provider que carga las mascotas aprobadas desde Supabase
final petsProvider = FutureProvider.autoDispose((ref) async {
  final repo = PetsRepository();
  return repo.fetchApprovedPets();
});

/// Provider que carga las mascotas creadas por el usuario autenticado
final myPetsProvider = FutureProvider.autoDispose((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  final response = await Supabase.instance.client
      .from('pets')
      .select()
      .eq('created_by', user.id)
      .order('created_at', ascending: false);
  return response.map((item) => Pet.fromJson(item)).toList();
});

class AdoptionsPage extends ConsumerWidget {
  const AdoptionsPage({super.key});

  static const String _wompiLink = 'https://checkout.wompi.co/l/IMjZp7';

  Future<void> _openWompi(BuildContext context) async {
    final uri = Uri.parse(_wompiLink);

    // Abre en navegador externo (mejor para Wompi).
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el link de donación.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsProvider);
    final myPetsAsync = ref.watch(myPetsProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return DefaultTabController(
      length: 3, // ✅ ahora son 3 tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🐾 Adopciones'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pets), text: 'Mascotas disponibles'),
              Tab(icon: Icon(Icons.volunteer_activism), text: 'Donar'),
              Tab(icon: Icon(Icons.account_circle), text: 'Mis publicaciones'),
            ],
          ),
          actions: [
            if (user != null) ...[
              IconButton(
                tooltip: 'Mi perfil',
                icon: const Icon(Icons.person),
                onPressed: () => context.push('/profile'),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Text(
                    user.email ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        body: TabBarView(
          children: [
            // 🐶 TAB 1: Mascotas aprobadas (disponibles)
            petsAsync.when(
              data: (pets) {
                if (pets.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay mascotas disponibles aún 🐶',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(petsProvider.future),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          onTap: () => context.push('/pet/${pet.id}'),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(pet.photoUrl),
                            radius: 26,
                          ),
                          title: Text(
                            pet.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${pet.species} • ${pet.age} años\n${pet.description}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '⚠️ Error cargando mascotas:\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),

            // 💚 TAB 2: Donaciones (QR + link Wompi)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Apoya a PawCampus 💚',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Escanea el QR o tócala para abrir el link de donación.',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openWompi(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: QrImageView(
                          data: _wompiLink,
                          version: QrVersions.auto,
                          size: 220,
                          gapless: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _openWompi(context),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Abrir link de Wompi'),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _wompiLink,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            // 🐕 TAB 3: Mis mascotas creadas
            myPetsAsync.when(
              data: (myPets) {
                if (myPets.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aún no has registrado ninguna mascota 🐾',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(myPetsProvider.future),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: myPets.length,
                    itemBuilder: (context, index) {
                      final pet = myPets[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          onTap: () => context.push('/pet/${pet.id}'),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(pet.photoUrl),
                            radius: 24,
                          ),
                          title: Text(pet.name),
                          subtitle: Text(
                            'Estado: ${pet.status.toUpperCase()}\n'
                            '${pet.species} • ${pet.age} años',
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '⚠️ Error cargando tus mascotas:\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ➕ Botón flotante: agregar nueva mascota
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPetPage()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
