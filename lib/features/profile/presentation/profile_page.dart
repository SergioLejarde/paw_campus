import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../profile/data/profile_repository.dart';
import '../../profile/domain/profile.dart';

/// Provider que carga el perfil del usuario actual
final currentProfileProvider =
    FutureProvider.autoDispose<UserProfile?>((ref) async {
  final repo = ProfileRepository();
  return repo.getCurrentProfile();
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error cargando perfil:\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (profile) {
          if (user == null) {
            return const Center(
              child: Text('No hay usuario autenticado'),
            );
          }

          // Si aún no hay fila en profiles, mostrar datos básicos del auth
          final displayEmail = profile?.email ?? user.email ?? 'Sin correo';
          final displayName = profile?.name ?? 'Sin nombre configurado';
          final displayPhone = profile?.phone ?? 'Sin teléfono';
          final photoUrl = profile?.photoUrl;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  displayEmail,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Teléfono: $displayPhone',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),

                // Botón editar perfil
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile/edit');
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar perfil'),
                ),

                const SizedBox(height: 24),

                // Botón cerrar sesión
                ElevatedButton.icon(
                  onPressed: () async {
                    // 🔧 Cierre sin AuthRepository (por ahora)
                    await Supabase.instance.client.auth.signOut();

                    if (!context.mounted) return;
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
