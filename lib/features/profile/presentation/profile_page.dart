import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:paw_campus/features/profile/data/profile_repository.dart';
import 'package:paw_campus/features/profile/domain/profile.dart';

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
    final user = Supabase.instance.client.auth.currentUser;
    final profileAsync = ref.watch(currentProfileProvider);

    // ==========================================
    // 👤 MODO INVITADO (Sin sesión iniciada)
    // ==========================================
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          color: Color(0xFFCCFBF1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 54,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '¡Bienvenido a PawCo!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Comunidad animalista de Bucaramanga y Colombia 🐾',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D9488),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Estás navegando en Modo Invitado. Puedes consultar mascotas, animales perdidos y denuncias libremente. Para publicar y gestionar tus mascotas, inicia sesión.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/login'),
                          icon: const Icon(Icons.login),
                          label: const Text(
                            'Iniciar sesión',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0D9488)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => context.push('/register'),
                          icon: const Icon(Icons.person_add_outlined, color: Color(0xFF0D9488)),
                          label: const Text(
                            'Crear cuenta nueva',
                            style: TextStyle(
                              color: Color(0xFF0D9488),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
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

    // ==========================================
    // 👤 USUARIO AUTENTICADO
    // ==========================================
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Error cargando tu perfil:\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFE11D48)),
            ),
          ),
        ),
        data: (profile) {
          final displayEmail = profile?.email ?? user.email ?? 'Sin correo';
          final displayName = (profile?.name != null && profile!.name!.trim().isNotEmpty)
              ? profile.name!
              : (user.email?.split('@').first ?? 'Usuario PawCo');
          final displayPhone = (profile?.phone != null && profile!.phone!.trim().isNotEmpty)
              ? profile.phone!
              : 'Sin teléfono configurado';
          final displayCity = profile?.city ?? 'Bucaramanga';
          final photoUrl = profile?.photoUrl;
          final isAdmin = (profile?.isAdmin == true) ||
              (user.email?.endsWith('@admin.com') ?? false);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    // Tarjeta de perfil principal
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: const Color(0xFFCCFBF1),
                              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: (photoUrl == null || photoUrl.isEmpty)
                                  ? const Icon(Icons.person, size: 50, color: Color(0xFF0D9488))
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayEmail,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                Chip(
                                  avatar: const Icon(Icons.location_on, size: 16, color: Color(0xFF0D9488)),
                                  label: Text(displayCity),
                                ),
                                Chip(
                                  avatar: const Icon(Icons.phone, size: 16, color: Color(0xFF0D9488)),
                                  label: Text(displayPhone),
                                ),
                                if (isAdmin)
                                  const Chip(
                                    backgroundColor: Color(0xFFFEF3C7),
                                    avatar: Icon(Icons.verified_user, size: 16, color: Color(0xFFD97706)),
                                    label: Text(
                                      'Administrador',
                                      style: TextStyle(
                                        color: Color(0xFFD97706),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF0D9488)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => context.push('/profile/edit'),
                                icon: const Icon(Icons.edit, size: 18, color: Color(0xFF0D9488)),
                                label: const Text(
                                  'Editar perfil',
                                  style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==========================================
                    // 🛠️ PANEL DE ADMINISTRADOR (Si aplica)
                    // ==========================================
                    if (isAdmin) ...[
                      Card(
                        color: const Color(0xFFFFFBEB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFFDE68A), width: 1.5),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDE68A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.admin_panel_settings, color: Color(0xFFB45309), size: 28),
                          ),
                          title: const Text(
                            'Panel de Administración 🛠️',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          subtitle: const Text(
                            'Aprobar o rechazar mascotas en adopción pendientes.',
                            style: TextStyle(fontSize: 13, color: Color(0xFFB45309)),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Color(0xFFB45309)),
                          onTap: () => context.push('/admin'),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ==========================================
                    // 🐾 MIS MASCOTAS PUBLICADAS
                    // ==========================================
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFCCFBF1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.pets, color: Color(0xFF0D9488)),
                        ),
                        title: const Text(
                          'Mis mascotas publicadas',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Revisa el estado de tus mascotas en adopción'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/my-pets'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==========================================
                    // 🚪 CERRAR SESIÓN
                    // ==========================================
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFE11D48),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                          ref.invalidate(currentProfileProvider);
                          if (!context.mounted) return;
                          context.go('/');
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Cerrar sesión',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
