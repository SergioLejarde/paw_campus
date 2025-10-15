// lib/features/adoptions/presentation/adoptions_page.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../adoptions/data/pets_repository.dart';

final petsProvider = FutureProvider.autoDispose((ref) async {
  final repo = PetsRepository();
  return repo.fetchApprovedPets();
});

class AdoptionsPage extends ConsumerWidget {
  const AdoptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('🐾 Adopciones')),
      body: petsAsync.when(
        data: (pets) {
          if (pets.isEmpty) {
            return const Center(
              child: Text('No hay mascotas disponibles aún 🐶'),
            );
          }

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(pet.photoUrl),
                  ),
                  title: Text('${pet.name} — ${pet.species} (${pet.age} años)'),
                  subtitle: Text(pet.description),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
