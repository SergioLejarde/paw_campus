import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paw_campus/app/theme.dart';
import 'package:paw_campus/core/presentation/pawco_design_system.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../adoptions/data/pets_repository.dart';

/// Provider que obtiene las mascotas del usuario autenticado
final myPetsProvider = FutureProvider.autoDispose((ref) async {
  final repo = PetsRepository();
  return repo.fetchMyPets();
});

class MyPetsPage extends ConsumerWidget {
  const MyPetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(myPetsProvider);
    User? user;
    try {
      user = Supabase.instance.client.auth.currentUser;
    } catch (_) {
      user = null;
    }

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
                    '🐶 Mis Mascotas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (user?.email != null)
                  Flexible(
                    child: Text(
                      user!.email!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: PawCoColors.lilacGlow,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: petsAsync.when(
              data: (pets) {
                if (pets.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                              color: PawCoColors.cottonLilac,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.pets_rounded,
                              size: 40,
                              color: PawCoColors.plum,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Aún no has registrado mascotas 🐾',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: PawCoColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: PawCoColors.plum,
                  onRefresh: () async => ref.refresh(myPetsProvider.future),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      final isPending = pet.status == 'pending';

                      return PawCoHoverCard(
                        borderRadius: 18,
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 12),
                        onTap: () => context.push('/pet/${pet.id}'),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                width: 52,
                                height: 52,
                                child: pet.photoUrl.isNotEmpty
                                    ? Image.network(
                                        pet.photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: PawCoColors.cottonLilac,
                                          child: const Icon(
                                            Icons.pets_rounded,
                                            color: PawCoColors.plum,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: PawCoColors.cottonLilac,
                                        child: const Icon(
                                          Icons.pets_rounded,
                                          color: PawCoColors.plum,
                                        ),
                                      ),
                              ),
                            ),
                            title: Text(
                              pet.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                color: PawCoColors.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${pet.species} • ${pet.age} años\n${pet.description}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: PawCoColors.muted,
                              ),
                            ),
                            isThreeLine: true,
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isPending
                                    ? PawCoColors.softMalva
                                    : PawCoColors.cottonLilac,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isPending ? 'Pendiente' : 'Aprobada',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: isPending
                                      ? PawCoColors.terracottaDark
                                      : PawCoColors.plum,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: PawCoColors.plum),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '⚠️ Error cargando tus mascotas:\n$e',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(color: PawCoColors.error),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
