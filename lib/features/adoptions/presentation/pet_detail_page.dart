// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:paw_campus/core/presentation/app_feedback.dart';

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
      appBar: AppBar(
        title: const Text('Detalle de Mascota'),
      ),
      body: petFuture.when(
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
                  'Error cargando la mascota:\n$e',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (pet) {
          if (pet == null) {
            return const Center(child: Text('Mascota no encontrada'));
          }

          final user = Supabase.instance.client.auth.currentUser;
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
            'approved' => const Color(0xFF0D9488),
            'pending' => const Color(0xFFF59E0B),
            'rejected' => const Color(0xFFE11D48),
            'adopted' => Colors.purple,
            _ => Colors.blueGrey,
          };

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======================
                // FOTO PRINCIPAL
                // ======================
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: pet.photoUrl.isNotEmpty
                      ? Image.network(
                          pet.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFE2E8F0),
                            child: const Center(
                              child: Icon(Icons.pets, size: 64, color: Colors.grey),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Center(
                            child: Icon(Icons.pets, size: 64, color: Colors.grey),
                          ),
                        ),
                ),

                // ======================
                // INFORMACIÓN Y DETALLES
                // ======================
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              pet.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Chips de datos clave
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.pets, size: 16),
                            label: Text(pet.species),
                          ),
                          Chip(
                            avatar: const Icon(Icons.cake_outlined, size: 16),
                            label: Text('${pet.age} ${pet.age == 1 ? "año" : "años"}'),
                          ),
                          Chip(
                            avatar: const Icon(Icons.straighten, size: 16),
                            label: Text('Tamaño ${pet.size}'),
                          ),
                          Chip(
                            avatar: const Icon(Icons.location_on_outlined, size: 16),
                            label: Text(
                              '${pet.city}${pet.neighborhood != null && pet.neighborhood!.isNotEmpty ? " (${pet.neighborhood})" : ""}',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        'Sobre esta mascota',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pet.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFF334155),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ======================
                      // CONTACTO WHATSAPP REAL
                      // ======================
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.chat, size: 22),
                          label: const Text(
                            'Contactar para adoptar vía WhatsApp',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            final supabase = Supabase.instance.client;

                            final response = await supabase
                                .from('profiles')
                                .select('phone')
                                .eq('id', pet.createdBy)
                                .maybeSingle();

                            final rawPhone = response?['phone']?.toString().trim();

                            if (rawPhone == null || rawPhone.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'El rescatista/dueño aún no tiene teléfono registrado.',
                                  ),
                                ),
                              );
                              return;
                            }

                            // Limpiar número y agregar prefijo Colombia si tiene 10 dígitos (e.g. 3001234567)
                            String cleanPhone = rawPhone.replaceAll(RegExp(r'\D'), '');
                            if (cleanPhone.length == 10 && !cleanPhone.startsWith('57')) {
                              cleanPhone = '57$cleanPhone';
                            }

                            final uri = Uri.parse(
                              'https://wa.me/$cleanPhone?text=Hola,%20vi%20a%20${Uri.encodeComponent(pet.name)}%20en%20PawCol%20y%20me%20gustar%C3%ADa%20adoptarlo.',
                            );

                            final launched = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );

                            if (!launched) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No se pudo abrir WhatsApp.'),
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
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blueGrey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],

                      // ======================
                      // ACCIONES ADMIN
                      // ======================
                      if (isAdmin) ...[
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFCD34D)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.admin_panel_settings, color: Color(0xFFB45309)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Acciones de Administrador',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB45309),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0D9488),
                                      ),
                                      icon: const Icon(Icons.check, size: 18),
                                      onPressed: () async {
                                        try {
                                          AppFeedback.showLoadingDialog(
                                            context,
                                            message: 'Aprobando mascota...',
                                          );
                                          await PetsRepository().updatePetStatus(
                                            pet.id,
                                            'approved',
                                          );

                                          if (!context.mounted) return;

                                          AppFeedback.hideLoadingDialog(context);
                                          AppFeedback.showSuccess(
                                            context,
                                            'Mascota aprobada correctamente',
                                          );

                                          Navigator.pop(context);
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          AppFeedback.hideLoadingDialog(context);
                                          AppFeedback.showError(context, e);
                                        }
                                      },
                                      label: const Text('Aprobar'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFE11D48),
                                      ),
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () async {
                                        try {
                                          AppFeedback.showLoadingDialog(
                                            context,
                                            message: 'Rechazando mascota...',
                                          );
                                          await PetsRepository().updatePetStatus(
                                            pet.id,
                                            'rejected',
                                          );

                                          if (!context.mounted) return;

                                          AppFeedback.hideLoadingDialog(context);
                                          AppFeedback.showSuccess(
                                            context,
                                            'Mascota rechazada',
                                          );

                                          Navigator.pop(context);
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          AppFeedback.hideLoadingDialog(context);
                                          AppFeedback.showError(context, e);
                                        }
                                      },
                                      label: const Text('Rechazar'),
                                    ),
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
          );
        },
      ),
    );
  }
}

// ======================
// PROVIDER
// ======================
final _petByIdProvider = FutureProvider.family.autoDispose<Pet?, String>((
  ref,
  id,
) async {
  return PetsRepository().getPetById(id);
});
