import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:paw_campus/app/theme.dart';
import 'package:paw_campus/core/presentation/pawco_design_system.dart';
import 'package:paw_campus/features/profile/data/profile_repository.dart';
import 'package:paw_campus/features/profile/domain/profile.dart';

/// Provider que carga el perfil del usuario actual
final currentProfileProvider = FutureProvider.autoDispose<UserProfile?>((
  ref,
) async {
  final repo = ProfileRepository();
  return repo.getCurrentProfile();
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  User? _safeCurrentUser() {
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = _safeCurrentUser();
    final profileAsync = ref.watch(currentProfileProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 860;
    final isMobileShell = screenWidth < 860;
    final isCompact = screenWidth < 360;

    Widget buildHeader(String subtitle) {
      return PawColAuroraWaveHeader(
        contentPadding: EdgeInsets.fromLTRB(
          isDesktop ? 36 : 16,
          isDesktop ? 28 : 20,
          isDesktop ? 36 : 16,
          18,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: PawCoColors.lilacGlow.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 14,
                        color: PawCoColors.amberGlow,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Cuenta PawCol • Santander',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                PawColGradientText(
                  'Mi Perfil',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isDesktop ? 34 : 26,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isDesktop ? 14.5 : 13,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ==========================================
    // 👤 MODO INVITADO (Sin sesión iniciada)
    // ==========================================
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildHeader(
                'Gestiona tus adopciones, reportes y participación en la red PawCol.',
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isCompact ? 14 : 24,
                  20,
                  isCompact ? 14 : 24,
                  isMobileShell ? 120 : 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: PawCoFadeSlide(
                      child: Container(
                        decoration: BoxDecoration(
                          color: PawCoColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: PawCoColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: PawCoColors.plum.withValues(alpha: 0.06),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 18 : 26,
                            vertical: isCompact ? 26 : 34,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: PawCoColors.cottonLilac,
                                  shape: BoxShape.circle,
                                ),
                                child: SizedBox(
                                  width: 68,
                                  height: 68,
                                  child: SvgPicture.asset(
                                    'assets/vectors/pawcol_rescuer_pets.svg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Bienvenido a PawCol',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: PawCoColors.ink,
                                  letterSpacing: -0.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Comunidad animalista de Bucaramanga y Colombia',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: PawCoColors.plum,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
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
                                child: PawColPrimarySaaSButton(
                                  label: 'Iniciar sesión',
                                  icon: Icons.login_rounded,
                                  onTap: () => context.push('/login'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: PawCoColors.border,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () => context.push('/register'),
                                  icon: const Icon(
                                    Icons.person_add_outlined,
                                    size: 18,
                                    color: PawCoColors.plum,
                                  ),
                                  label: Text(
                                    'Crear cuenta nueva',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: PawCoColors.ink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
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
              ),
            ],
          ),
        ),
      );
    }

    // ==========================================
    // 👤 USUARIO AUTENTICADO
    // ==========================================
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeader(
              'Tu panel personal de bienestar animal, adopciones y trazabilidad.',
            ),
            profileAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: CircularProgressIndicator(color: PawCoColors.plum),
                ),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error cargando tu perfil:\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: PawCoColors.error),
                  ),
                ),
              ),
              data: (profile) {
                final displayEmail =
                    profile?.email ?? user.email ?? 'Sin correo';
                final displayName =
                    (profile?.name != null && profile!.name!.trim().isNotEmpty)
                    ? profile.name!
                    : (user.email?.split('@').first ?? 'Usuario PawCol');
                final displayPhone =
                    (profile?.phone != null &&
                        profile!.phone!.trim().isNotEmpty)
                    ? profile.phone!
                    : 'Sin teléfono configurado';
                final displayCity = profile?.city ?? 'Bucaramanga';
                final photoUrl = profile?.photoUrl;
                final isAdmin =
                    (profile?.isAdmin == true) ||
                    (user.email?.endsWith('@admin.com') ?? false);

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    isMobileShell ? 120 : 48,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        children: [
                          // Tarjeta de perfil principal
                          Container(
                            decoration: BoxDecoration(
                              color: PawCoColors.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: PawCoColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: PawCoColors.plum.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 44,
                                    backgroundColor: PawCoColors.cottonLilac,
                                    backgroundImage:
                                        photoUrl != null && photoUrl.isNotEmpty
                                        ? NetworkImage(photoUrl)
                                        : null,
                                    child: (photoUrl == null || photoUrl.isEmpty)
                                        ? const Icon(
                                            Icons.person_outline_rounded,
                                            size: 42,
                                            color: PawCoColors.plum,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    displayName,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: PawCoColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    displayEmail,
                                    textAlign: TextAlign.center,
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
                                      PawCoBadge(
                                        label: displayCity,
                                        icon: Icons.location_on_outlined,
                                        backgroundColor:
                                            PawCoColors.cottonLilac,
                                        textColor: PawCoColors.plum,
                                      ),
                                      PawCoBadge(
                                        label: displayPhone,
                                        icon: Icons.phone_outlined,
                                        backgroundColor: PawCoColors.softMalva,
                                        textColor: PawCoColors.terracottaDark,
                                      ),
                                      if (isAdmin)
                                        const PawCoBadge(
                                          label: 'Administrador',
                                          icon: Icons.verified_user,
                                          backgroundColor: Color(0xFFFEF3C7),
                                          textColor: Color(0xFFB45309),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: PawCoColors.border,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          context.push('/profile/edit'),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 17,
                                        color: PawCoColors.plum,
                                      ),
                                      label: Text(
                                        'Editar perfil',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: PawCoColors.ink,
                                          fontWeight: FontWeight.w700,
                                        ),
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
                                color: PawCoColors.softMalva,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: PawCoColors.malva.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.admin_panel_settings_rounded,
                                      color: PawCoColors.plum,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    'Panel de Administración',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: PawCoColors.ink,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Aprobar mascotas pendientes y gestionar denuncias SOS.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      color: PawCoColors.inkSecondary,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: PawCoColors.plum,
                                  ),
                                  onTap: () => context.push('/admin'),
                                ),
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
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: PawCoColors.border),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: PawCoColors.cottonLilac,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.pets_rounded,
                                    color: PawCoColors.plum,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  'Mis mascotas publicadas',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  'Revisa el estado de tus mascotas en adopción',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    color: PawCoColors.muted,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: PawCoColors.plum,
                                ),
                                onTap: () => context.push('/my-pets'),
                              ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () async {
                                await Supabase.instance.client.auth.signOut();
                                ref.invalidate(currentProfileProvider);
                                if (!context.mounted) return;
                                context.go('/');
                              },
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: Text(
                                'Cerrar sesión',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                ),
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
          ],
        ),
      ),
    );
  }
}
