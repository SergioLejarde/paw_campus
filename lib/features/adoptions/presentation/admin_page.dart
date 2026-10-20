import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:paw_campus/core/presentation/app_feedback.dart';
import '../../adoptions/data/pets_repository.dart';

/// Provider que obtiene todas las mascotas pendientes
final pendingPetsProvider = FutureProvider.autoDispose((ref) async {
  final repo = PetsRepository();
  return repo.fetchPendingPets();
});

class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(pendingPetsProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración 🛠️'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  user.email ?? '',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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
                'No hay mascotas pendientes por aprobar 🐶',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(pendingPetsProvider.future),
            child: ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    /// 👉 **Navegación al detalle**
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
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,

                    /// Acciones rápidas para aprobar/rechazar
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            await _updatePetStatus(context, pet.id, 'approved');
                            ref.invalidate(pendingPetsProvider);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () async {
                            await _updatePetStatus(context, pet.id, 'rejected');
                            ref.invalidate(pendingPetsProvider);
                          },
                        ),
                      ],
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
              '⚠️ Error cargando mascotas:\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      ),
    );
  }

  /// Función auxiliar para aprobar/rechazar
  Future<void> _updatePetStatus(
    BuildContext context,
    String petId,
    String newStatus,
  ) async {
    final repo = PetsRepository();
    try {
      AppFeedback.showLoadingDialog(
        context,
        message: 'Actualizando estado de la mascota...',
      );
      await repo.updatePetStatus(petId, newStatus);
      if (!context.mounted) return;
      AppFeedback.hideLoadingDialog(context);
      AppFeedback.showSuccess(
        context,
        newStatus == 'approved'
            ? 'Mascota aprobada correctamente'
            : 'Mascota rechazada correctamente',
      );
    } catch (e) {
      if (context.mounted) {
        AppFeedback.hideLoadingDialog(context);
        AppFeedback.showError(context, e);
      }
    }
  }
}
