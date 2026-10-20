import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/pets_repository.dart';
import 'my_pets_page.dart';

/// Provider que carga las mascotas aprobadas desde Supabase
final petsProvider = FutureProvider.autoDispose<List<Pet>>((ref) async {
  final repo = PetsRepository();
  return repo.fetchApprovedPets();
});

class AdoptionsPage extends ConsumerWidget {
  const AdoptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              '🐾 PawCo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Text(
              'Adopciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          if (user != null)
            TextButton.icon(
              onPressed: () => context.push('/my-pets'),
              icon: const Icon(Icons.inventory_2_outlined, size: 18),
              label: const Text(
                'Mis publicaciones',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(petsProvider.future),
        child: petsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Color(0xFFE11D48)),
                  const SizedBox(height: 12),
                  Text(
                    'Error cargando mascotas:\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.refresh(petsProvider.future),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
          data: (pets) {
            if (pets.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEF3C7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.pets,
                              size: 54,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay mascotas disponibles aún 🐶',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '¡Sé el primero en publicar una mascota en adopción!',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/pet/${pet.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: pet.photoUrl.isNotEmpty
                                  ? Image.network(
                                      pet.photoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0xFFE2E8F0),
                                        child: const Icon(Icons.pets, color: Colors.grey),
                                      ),
                                    )
                                  : Container(
                                      color: const Color(0xFFE2E8F0),
                                      child: const Icon(Icons.pets, color: Colors.grey),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pet.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCCFBF1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        pet.species,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F766E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${pet.age} ${pet.age == 1 ? "año" : "años"} • Tamaño ${pet.size}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: Color(0xFF0D9488),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        '${pet.city}${pet.neighborhood != null && pet.neighborhood!.isNotEmpty ? " • ${pet.neighborhood}" : ""}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF0D9488),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  pet.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final currentUser = Supabase.instance.client.auth.currentUser;
          if (currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inicia sesión para dar en adopción una mascota 🐾'),
              ),
            );
            context.push('/login');
            return;
          }

          await context.push('/pets/new');
          ref.invalidate(petsProvider);
          ref.invalidate(myPetsProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Dar en adopción'),
      ),
    );
  }
}
