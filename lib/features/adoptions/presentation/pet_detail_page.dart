import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../adoptions/data/pets_repository.dart';

class PetDetailPage extends ConsumerWidget {
  final String petId;

  const PetDetailPage({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petFuture = ref.watch(_petByIdProvider(petId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Mascota'),
      ),
      body: petFuture.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error cargando la mascota:\n$e',
            textAlign: TextAlign.center,
          ),
        ),
        data: (pet) {
          if (pet == null) {
            return const Center(child: Text('Mascota no encontrada'));
          }

          final user = Supabase.instance.client.auth.currentUser;
          final isOwner = user?.id == pet.createdBy;
          final isAdmin = user?.email?.endsWith('@admin.com') ?? false;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto grande
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image.network(
                    pet.photoUrl,
                    fit: BoxFit.cover,
                  ),
                ),

                // Información
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        '${pet.species} • ${pet.age} años',
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        pet.description,
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 20),

                      if (isOwner)
                        Text(
                          'Estado: ${pet.status.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Botón de contacto (WhatsApp)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.chat),
                        label: const Text('Contactar para adoptar'),
                        onPressed: () async {
                          final supabase =
                              Supabase.instance.client;

                          final response = await supabase
                              .from('profiles')
                              .select('phone')
                              .eq('id', pet.createdBy)
                              .maybeSingle();

                          final phone = response?['phone'];

                          if (phone == null ||
                              phone.toString().isEmpty) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'El dueño no tiene teléfono registrado',
                                ),
                              ),
                            );
                            return;
                          }

                          final whatsappUrl =
                              'https://wa.me/$phone?text=Hola, quiero adoptar a ${pet.name}';

                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content:
                                  Text('Abrir WhatsApp: $whatsappUrl'),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Botones del Administrador
                      if (isAdmin)
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                await PetsRepository()
                                    .updatePetStatus(
                                        pet.id, 'approved');

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Mascota aprobada ✔️'),
                                  ),
                                );

                                Navigator.pop(context);
                              },
                              child: const Text('Aprobar'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                await PetsRepository()
                                    .updatePetStatus(
                                        pet.id, 'rejected');

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Mascota rechazada ❌'),
                                  ),
                                );

                                Navigator.pop(context);
                              },
                              child: const Text('Rechazar'),
                            ),
                          ],
                        ),
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

final _petByIdProvider =
    FutureProvider.family.autoDispose<Pet?, String>((ref, id) async {
  return PetsRepository().getPetById(id);
});
