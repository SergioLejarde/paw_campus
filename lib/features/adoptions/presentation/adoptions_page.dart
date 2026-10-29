import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme.dart';
import '../../../core/presentation/pawco_design_system.dart';
import '../data/pets_repository.dart';
import 'my_pets_page.dart';

/// Provider que carga las mascotas aprobadas desde Supabase (con fallback semilla)
final petsProvider = FutureProvider.autoDispose<List<Pet>>((ref) async {
  final repo = PetsRepository();
  return repo.fetchApprovedPets();
});

class AdoptionsPage extends ConsumerStatefulWidget {
  const AdoptionsPage({super.key});

  @override
  ConsumerState<AdoptionsPage> createState() => _AdoptionsPageState();
}

class _AdoptionsPageState extends ConsumerState<AdoptionsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filtro activo por píldora (Mockup 2)
  String _selectedPill = '🐾 Todos';

  // Conjunto de mascotas favoritas en estado local interactivo
  final Set<String> _favoritePetIds = {'seed-luna-bga'};

  static const List<String> _filterPills = [
    '🐾 Todos',
    '🐕 Perros',
    '🐈 Gatos',
    '🐾 Cachorros (<1 año)',
    '📍 Bucaramanga',
    'Floridablanca',
    'Girón',
    'Piedecuesta',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Pet> _filterPets(List<Pet> pets) {
    return pets.where((pet) {
      // 1. Filtro por píldora seleccionada
      if (_selectedPill == '🐕 Perros') {
        if (!pet.species.toLowerCase().contains('perro')) return false;
      } else if (_selectedPill == '🐈 Gatos') {
        if (!pet.species.toLowerCase().contains('gato')) return false;
      } else if (_selectedPill == '🐾 Cachorros (<1 año)') {
        if (pet.age > 1) return false;
      } else if (_selectedPill == '📍 Bucaramanga') {
        if (pet.city.toLowerCase() != 'bucaramanga') return false;
      } else if (_selectedPill == 'Floridablanca') {
        if (pet.city.toLowerCase() != 'floridablanca') return false;
      } else if (_selectedPill == 'Girón') {
        if (pet.city.toLowerCase() != 'girón' && pet.city.toLowerCase() != 'giron') {
          return false;
        }
      } else if (_selectedPill == 'Piedecuesta') {
        if (pet.city.toLowerCase() != 'piedecuesta') return false;
      }

      // 2. Filtro por búsqueda de texto
      if (_searchQuery.isNotEmpty) {
        final matchName = pet.name.toLowerCase().contains(_searchQuery);
        final matchDesc = pet.description.toLowerCase().contains(_searchQuery);
        final matchCity = pet.city.toLowerCase().contains(_searchQuery);
        final matchNeigh = (pet.neighborhood ?? '').toLowerCase().contains(_searchQuery);
        final matchSpecies = pet.species.toLowerCase().contains(_searchQuery);
        final matchSize = pet.size.toLowerCase().contains(_searchQuery);
        if (!matchName && !matchDesc && !matchCity && !matchNeigh && !matchSpecies && !matchSize) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _toggleFavorite(String petId, String petName) {
    setState(() {
      if (_favoritePetIds.contains(petId)) {
        _favoritePetIds.remove(petId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$petName eliminado de tus favoritos'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _favoritePetIds.add(petId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡$petName guardado en tus favoritos! ❤️'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  User? _getCurrentUser() {
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petsProvider);
    final user = _getCurrentUser();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: PawCoColors.forest.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, color: PawCoColors.forest, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'PawCol Adopciones',
              style: GoogleFonts.fraunces(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: PawCoColors.ink,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inicia sesión para gestionar tus publicaciones 🐾'),
                  ),
                );
                context.push('/login');
              } else {
                context.push('/my-pets');
              }
            },
            icon: const Icon(Icons.inventory_2_outlined, size: 18, color: PawCoColors.forest),
            label: Text(
              'Mis publicaciones',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: PawCoColors.forest,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(petsProvider.future),
        child: petsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: PawCoColors.forest),
          ),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: PawCoColors.terracotta),
                  const SizedBox(height: 12),
                  Text(
                    'Error cargando mascotas:\n$e',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(color: PawCoColors.ink),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PawCoColors.forest,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => ref.refresh(petsProvider.future),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
          data: (allPets) {
            final filteredPets = _filterPets(allPets);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 16,
                vertical: 12,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado Editorial (Mockup 2: "Find a companion")
                      _buildEditorialHeader(),
                      const SizedBox(height: 18),

                      // Buscador Integrado
                      _buildSearchBar(),
                      const SizedBox(height: 14),

                      // Chips redondeados estilo píldora (Mockup 2)
                      _buildPillFilters(),
                      const SizedBox(height: 22),

                      // Contador de resultados y reset si aplica
                      _buildResultsCount(filteredPets.length),
                      const SizedBox(height: 14),

                      // Grid Responsive de Mascotas (2 cols móvil, 3 tablet, 4 desktop)
                      if (filteredPets.isEmpty)
                        _buildEmptyState()
                      else
                        _buildResponsiveGrid(filteredPets),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: PawCoColors.forest,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: () async {
          final currentUser = _getCurrentUser();
          if (currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inicia sesión para dar en adopción una mascota 🐾'),
              ),
            );
            context.push('/login');
            return;
          }

          await context.push('/pets/new');
          ref.invalidate(petsProvider);
          ref.invalidate(myPetsProvider);
        },
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          'Dar en adopción',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ===========================================================================
  // ENCABEZADO EDITORIAL
  // ===========================================================================
  Widget _buildEditorialHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: PawCoColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PawCoColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PawCoBadge(
                  label: 'ADOPCIÓN RESPONSABLE AMB',
                  icon: Icons.favorite,
                  backgroundColor: PawCoColors.terracottaLight,
                  textColor: PawCoColors.terracottaDark,
                ),
                const SizedBox(height: 8),
                Text(
                  'Encuentra un compañero',
                  style: GoogleFonts.fraunces(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: PawCoColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Conoce a los perros, gatos y peluditos rescatados en Bucaramanga, Floridablanca, Girón y Piedecuesta que esperan un hogar amoroso.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: PawCoColors.muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const AnimalSilhouetteCardWatermark(
            width: 85,
            height: 75,
            opacity: 0.45,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BUSCADOR LIMPIO
  // ===========================================================================
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: PawCoColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PawCoColors.border),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, barrio, raza o especie...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: PawCoColors.mutedLight,
          ),
          prefixIcon: const Icon(Icons.search, color: PawCoColors.forest),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ===========================================================================
  // CHIPS REDONDEADOS ESTILO PÍLDORA (MOCKUP 2)
  // ===========================================================================
  Widget _buildPillFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filterPills.map((pill) {
          final isSelected = _selectedPill == pill;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                pill,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : PawCoColors.inkSecondary,
                ),
              ),
              selected: isSelected,
              selectedColor: PawCoColors.forest,
              backgroundColor: PawCoColors.surface,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? PawCoColors.forest : PawCoColors.border,
                  width: 1.2,
                ),
              ),
              onSelected: (_) {
                setState(() {
                  _selectedPill = pill;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===========================================================================
  // CONTADOR DE RESULTADOS
  // ===========================================================================
  Widget _buildResultsCount(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count ${count == 1 ? "compañero disponible" : "compañeros disponibles"}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: PawCoColors.muted,
          ),
        ),
        if (_selectedPill != '🐾 Todos' || _searchQuery.isNotEmpty)
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedPill = '🐾 Todos';
                _searchController.clear();
              });
            },
            child: Text(
              'Limpiar filtros',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: PawCoColors.forest,
              ),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // GRID RESPONSIVE DE MASCOTAS (MOCKUP 2)
  // ===========================================================================
  Widget _buildResponsiveGrid(List<Pet> pets) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = 2; // Por defecto móvil: 2 columnas como Mockup 2
        if (width >= 1050) {
          columns = 4; // Desktop
        } else if (width >= 650) {
          columns = 3; // Tablet
        }

        const double spacing = 14.0;
        final itemWidth = (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: pets.map((pet) {
            return SizedBox(
              width: itemWidth,
              child: _buildMockup2PetCard(pet),
            );
          }).toList(),
        );
      },
    );
  }

  // ===========================================================================
  // TARJETA DE MASCOTA CON BORDES DE 20PX, CORAZÓN Y TIPOGRAFÍA EDITORIAL
  // ===========================================================================
  Widget _buildMockup2PetCard(Pet pet) {
    final isFavorite = _favoritePetIds.contains(pet.id);

    return PawCoHoverCard(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      onTap: () => context.push('/pet/${pet.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Foto con bordes redondeados (20px arriba) + Botón interactivo de corazón
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: AspectRatio(
                  aspectRatio: 1.05,
                  child: pet.photoUrl.isNotEmpty
                      ? Image.network(
                          pet.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderPhoto(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: PawCoColors.background,
                              child: const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: PawCoColors.forest,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : _buildPlaceholderPhoto(),
                ),
              ),

              // Botón de Corazón (Favorito interactivo en estado local)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.38),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _toggleFavorite(pet.id, pet.name),
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? PawCoColors.terracotta : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Píldora de especie/tamaño sutil en la esquina inferior izquierda de la foto
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    pet.species,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: PawCoColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Información de la Mascota: Nombre + Edad + Municipio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre en tipografía editorial + edad (Luna • 2 años)
                Text(
                  '${pet.name} • ${pet.age == 1 ? "1 año" : "${pet.age} años"}',
                  style: GoogleFonts.fraunces(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: PawCoColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Subtítulo con tamaño y municipio (Bucaramanga • Cabecera)
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: PawCoColors.forest,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '${pet.city}${pet.neighborhood != null && pet.neighborhood!.isNotEmpty ? " • ${pet.neighborhood}" : ""}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: PawCoColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Container(
      color: PawCoColors.sageMuted,
      child: const Center(
        child: Icon(
          Icons.pets,
          size: 40,
          color: PawCoColors.sage,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: PawCoColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PawCoColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 52, color: PawCoColors.mutedLight),
          const SizedBox(height: 14),
          Text(
            'No encontramos peluditos con estos filtros',
            style: GoogleFonts.fraunces(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: PawCoColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Prueba seleccionando otro municipio o limpiando la búsqueda.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: PawCoColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: PawCoColors.forest,
              side: const BorderSide(color: PawCoColors.forest),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              setState(() {
                _selectedPill = '🐾 Todos';
                _searchController.clear();
              });
            },
            child: const Text('Ver todas las mascotas'),
          ),
        ],
      ),
    );
  }
}
