import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsProvider);
    final myPetsAsync = ref.watch(myPetsProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🐾 Adopciones'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pets), text: 'Mascotas disponibles'),
              Tab(icon: Icon(Icons.account_circle), text: 'Mis mascotas'),
            ],
          ),
          actions: [
            if (user != null) ...[
              IconButton(
                tooltip: 'Mi perfil',
                icon: const Icon(Icons.person),
                onPressed: () {
                  context.push('/profile');
                },
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
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
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
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

            // 🐕 TAB 2: Mis mascotas creadas
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
                  onRefresh: () async =>
                      ref.refresh(myPetsProvider.future),
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
                          onTap: () =>
                              context.push('/pet/${pet.id}'),
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
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
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
              MaterialPageRoute(
                builder: (context) => const AddPetPage(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
