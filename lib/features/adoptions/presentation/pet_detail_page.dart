// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paw_campus/app/theme.dart';
import 'package:paw_campus/core/presentation/app_feedback.dart';
import 'package:paw_campus/core/presentation/pawco_design_system.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../adoptions/data/pets_repository.dart';
import '../../profile/presentation/profile_page.dart';

class PetDetailPage extends ConsumerWidget {
  final String petId;

  const PetDetailPage({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petFuture = ref.watch(_petByIdProvider(petId));
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      backgroundColor: PawCoColors.background,
      body: Column(
        children: [
          PawColAuroraWaveHeader(
            contentPadding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 10,
              16,
              12,
            ),
            waveHeight: 40,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/adoptions');
                    }
                  },
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Detalle de Mascota',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: petFuture.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: PawCoColors.plum),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: PawCoColors.malva,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error cargando la mascota:\n$e',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(color: PawCoColors.ink),
                      ),
                    ],
                  ),
                ),
              ),
              data: (pet) {
                if (pet == null) {
                  return Center(
                    child: Text(
                      'Mascota no encontrada',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PawCoColors.ink,
                      ),
                    ),
                  );
                }

                User? user;
                try {
                  user = Supabase.instance.client.auth.currentUser;
                } catch (_) {
                  user = null;
                }
                final isOwner = user?.id == pet.createdBy;
                final userProfile = profileAsync.valueOrNull;
                final isAdmin = (userProfile?.isAdmin == true) ||
                    (user?.email?.endsWith('@admin.com') ?? false);

                final statusLabel = switch (pet.status) {
                  'approved' => 'Aprobada',
                  'pending' => 'Pendiente de aprobación',
                  'rejected' => 'Rechazada',
                  'adopted' => 'Adoptada',
                  _ => pet.status,
                };

                final statusColor = switch (pet.status) {
                  'approved' => PawCoColors.plum,
                  'pending' => const Color(0xFFD97706),
                  'rejected' => PawCoColors.error,
                  'adopted' => PawCoColors.malva,
                  _ => PawCoColors.muted,
                };

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 780),
                      child: PawCoFadeSlide(
                        child: Container(
                          decoration: BoxDecoration(
                            color: PawCoColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: PawCoColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: PawCoColors.plum.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // FOTO PRINCIPAL
                              SizedBox(
                                height: 310,
                                width: double.infinity,
                                child: pet.photoUrl.isNotEmpty
                                    ? Image.network(
                                        pet.photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _buildPhotoFallback(),
                                      )
                                    : _buildPhotoFallback(),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          pet.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: PawCoColors.ink,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(
                                              alpha: 0.12,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: statusColor.withValues(
                                                alpha: 0.45,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            statusLabel,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: statusColor,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Atributos en Lila Algodón y Rosa Malva Suave
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _buildAttrPill(
                                          Icons.pets_rounded,
                                          pet.species,
                                          PawCoColors.cottonLilac,
                                          PawCoColors.plum,
                                        ),
                                        _buildAttrPill(
                                          Icons.cake_outlined,
                                          '${pet.age} ${pet.age == 1 ? "año" : "años"}',
                                          PawCoColors.softMalva,
                                          PawCoColors.terracottaDark,
                                        ),
                                        _buildAttrPill(
                                          Icons.straighten_rounded,
                                          'Tamaño ${pet.size}',
                                          PawCoColors.sageMuted,
                                          PawCoColors.plum,
                                        ),
                                        _buildAttrPill(
                                          Icons.location_on_outlined,
                                          '${pet.city}${pet.neighborhood != null && pet.neighborhood!.isNotEmpty ? " (${pet.neighborhood})" : ""}',
                                          PawCoColors.softMalva,
                                          PawCoColors.terracottaDark,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 22),
                                    Text(
                                      'Sobre esta mascota',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: PawCoColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      pet.description,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.5,
                                        height: 1.55,
                                        color: PawCoColors.inkSecondary,
                                      ),
                                    ),

                                    const SizedBox(height: 26),

                                    // CONTACTO WHATSAPP REAL
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF25D366),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.chat_rounded,
                                          size: 20,
                                        ),
                                        label: Text(
                                          'Contactar para adoptar vía WhatsApp',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onPressed: () async {
                                          final supabase =
                                              Supabase.instance.client;
                                          final response = await supabase
                                              .from('profiles')
                                              .select('phone')
                                              .eq('id', pet.createdBy)
                                              .maybeSingle();

                                          final rawPhone = response?['phone']
                                              ?.toString()
                                              .trim();

                                          if (rawPhone == null ||
                                              rawPhone.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'El rescatista/dueño aún no tiene teléfono registrado.',
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          String cleanPhone = rawPhone
                                              .replaceAll(RegExp(r'\D'), '');
                                          if (cleanPhone.length == 10 &&
                                              !cleanPhone.startsWith('57')) {
                                            cleanPhone = '57$cleanPhone';
                                          }

                                          final uri = Uri.parse(
                                            'https://wa.me/$cleanPhone?text=Hola,%20vi%20a%20${Uri.encodeComponent(pet.name)}%20en%20PawCol%20y%20me%20gustar%C3%ADa%20adoptarlo.',
                                          );

                                          final launched = await launchUrl(
                                            uri,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );

                                          if (!launched) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'No se pudo abrir WhatsApp.',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),

                                    if (isOwner) ...[
                                      const SizedBox(height: 12),
                                      Center(
                                        child: Text(
                                          'Eres el publicador de esta mascota.',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12.5,
                                            color: PawCoColors.muted,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],

                                    if (isAdmin) ...[
                                      const SizedBox(height: 28),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: PawCoColors.sageMuted,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: Border.all(
                                            color: PawCoColors.cottonLilac,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.admin_panel_settings,
                                                  color: PawCoColors.plum,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Acciones de Administrador',
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: PawCoColors.plum,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: [
                                                ElevatedButton.icon(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        PawCoColors.plum,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.check_rounded,
                                                    size: 18,
                                                  ),
                                                  onPressed: () async {
                                                    try {
                                                      AppFeedback
                                                          .showLoadingDialog(
                                                        context,
                                                        message:
                                                            'Aprobando mascota...',
                                                      );
                                                      await PetsRepository()
                                                          .updatePetStatus(
                                                        pet.id,
                                                        'approved',
                                                      );
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      AppFeedback
                                                          .hideLoadingDialog(
                                                        context,
                                                      );
                                                      AppFeedback.showSuccess(
                                                        context,
                                                        'Mascota aprobada correctamente',
                                                      );
                                                      Navigator.pop(context);
                                                    } catch (e) {
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      AppFeedback
                                                          .hideLoadingDialog(
                                                        context,
                                                      );
                                                      AppFeedback.showError(
                                                        context,
                                                        e,
                                                      );
                                                    }
                                                  },
                                                  label: const Text('Aprobar'),
                                                ),
                                                ElevatedButton.icon(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        PawCoColors.error,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.close_rounded,
                                                    size: 18,
                                                  ),
                                                  onPressed: () async {
                                                    try {
                                                      AppFeedback
                                                          .showLoadingDialog(
                                                        context,
                                                        message:
                                                            'Rechazando mascota...',
                                                      );
                                                      await PetsRepository()
                                                          .updatePetStatus(
                                                        pet.id,
                                                        'rejected',
                                                      );
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      AppFeedback
                                                          .hideLoadingDialog(
                                                        context,
                                                      );
                                                      AppFeedback.showSuccess(
                                                        context,
                                                        'Mascota rechazada',
                                                      );
                                                      Navigator.pop(context);
                                                    } catch (e) {
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      AppFeedback
                                                          .hideLoadingDialog(
                                                        context,
                                                      );
                                                      AppFeedback.showError(
                                                        context,
                                                        e,
                                                      );
                                                    }
                                                  },
                                                  label: const Text('Rechazar'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoFallback() {
    return Container(
      color: PawCoColors.cottonLilac.withValues(alpha: 0.4),
      child: const Center(
        child: Icon(Icons.pets_rounded, size: 64, color: PawCoColors.plum),
      ),
    );
  }

  Widget _buildAttrPill(
    IconData icon,
    String text,
    Color bg,
    Color fg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

final _petByIdProvider = FutureProvider.family.autoDispose<Pet?, String>((
  ref,
  id,
) async {
  return PetsRepository().getPetById(id);
});
