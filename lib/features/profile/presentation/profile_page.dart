import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:paw_campus/app/theme.dart';
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Mi Perfil'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                decoration: BoxDecoration(
                  color: PawCoColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: PawCoColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: PawCoColors.ink.withValues(alpha: 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 34),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: PawCoColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: PawCoColors.border),
                        ),
                        child: const Icon(
                          Icons.pets_rounded,
                          size: 40,
                          color: PawCoColors.forest,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Bienvenido a PawCol',
                        style: GoogleFonts.fraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: PawCoColors.ink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Comunidad animalista de Bucaramanga y Colombia',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: PawCoColors.forest,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Estás navegando en Modo Invitado. Puedes consultar mascotas, animales perdidos, donaciones auditadas y denuncias libremente. Para publicar y gestionar tus mascotas, inicia sesión.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: PawCoColors.inkSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/login'),
                          icon: const Icon(Icons.login_rounded, size: 18),
                          label: const Text(
                            'Iniciar sesión',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: PawCoColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => context.push('/register'),
                          icon: const Icon(Icons.person_add_outlined, size: 18, color: PawCoColors.ink),
                          label: const Text(
                            'Crear cuenta nueva',
                            style: TextStyle(
                              color: PawCoColors.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
              style: const TextStyle(color: PawCoColors.error),
            ),
          ),
        ),
        data: (profile) {
          final displayEmail = profile?.email ?? user.email ?? 'Sin correo';
          final displayName = (profile?.name != null && profile!.name!.trim().isNotEmpty)
              ? profile.name!
              : (user.email?.split('@').first ?? 'Usuario PawCol');
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
                    Container(
                      decoration: BoxDecoration(
                        color: PawCoColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: PawCoColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: PawCoColors.surfaceMuted,
                              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: (photoUrl == null || photoUrl.isEmpty)
                                  ? const Icon(Icons.person_outline_rounded, size: 42, color: PawCoColors.forest)
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              displayName,
                              style: GoogleFonts.fraunces(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: PawCoColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayEmail,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: PawCoColors.inkSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                Chip(
                                  avatar: const Icon(Icons.location_on_outlined, size: 15, color: PawCoColors.forest),
                                  label: Text(displayCity),
                                ),
                                Chip(
                                  avatar: const Icon(Icons.phone_outlined, size: 15, color: PawCoColors.forest),
                                  label: Text(displayPhone),
                                ),
                                if (isAdmin)
                                  const Chip(
                                    backgroundColor: Color(0xFFFEF3C7),
                                    avatar: Icon(Icons.verified_user, size: 15, color: Color(0xFFD97706)),
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
                                  side: const BorderSide(color: PawCoColors.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => context.push('/profile/edit'),
                                icon: const Icon(Icons.edit_outlined, size: 17, color: PawCoColors.ink),
                                label: const Text(
                                  'Editar perfil',
                                  style: TextStyle(color: PawCoColors.ink, fontWeight: FontWeight.w600),
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
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDE68A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.admin_panel_settings, color: Color(0xFFB45309), size: 24),
                          ),
                          title: const Text(
                            'Panel de Administración',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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
                    Container(
                      decoration: BoxDecoration(
                        color: PawCoColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: PawCoColors.border),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: PawCoColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.pets_rounded, color: PawCoColors.forest, size: 20),
                        ),
                        title: const Text(
                          'Mis mascotas publicadas',
                          style: TextStyle(fontWeight: FontWeight.w600),
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
                          foregroundColor: PawCoColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                          ref.invalidate(currentProfileProvider);
                          if (!context.mounted) return;
                          context.go('/');
                        },
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text(
                          'Cerrar sesión',
                          style: TextStyle(fontWeight: FontWeight.w700),
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
