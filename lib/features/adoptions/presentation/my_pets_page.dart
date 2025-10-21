import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../adoptions/data/pets_repository.dart';

/// Provider que obtiene las mascotas del usuario autenticado
final myPetsProvider = FutureProvider.autoDispose((ref) async {
  final repo = PetsRepository();
  return repo.fetchMyPets();
});

class MyPetsPage extends ConsumerWidget {
  const MyPetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(myPetsProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐶 Mis Mascotas'),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  user.email ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
      body: petsAsync.when(
        data: (pets) {
          if (pets.isEmpty) {
            return const Center(
              child: Text(
                'Aún no has registrado mascotas 🐾',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(myPetsProvider.future),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                final isPending = pet.status == 'pending';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
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
                    trailing: Chip(
                      label: Text(
                        isPending ? 'Pendiente' : 'Aprobada',
                        style: TextStyle(
                          color: isPending ? Colors.orange : Colors.green,
                        ),
                      ),
                      backgroundColor:
                          isPending ? Colors.orange[50] : Colors.green[50],
                    ),
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
    );
  }
}
