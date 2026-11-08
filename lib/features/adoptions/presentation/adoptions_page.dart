import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  // Filtro activo por píldora / categoría circular
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
        if (pet.city.toLowerCase() != 'girón' &&
            pet.city.toLowerCase() != 'giron') {
          return false;
        }
      } else if (_selectedPill == 'Piedecuesta') {
        if (pet.city.toLowerCase() != 'piedecuesta') return false;
      }

      if (_searchQuery.isNotEmpty) {
        final matchName = pet.name.toLowerCase().contains(_searchQuery);
        final matchDesc = pet.description.toLowerCase().contains(_searchQuery);
        final matchCity = pet.city.toLowerCase().contains(_searchQuery);
        final matchNeigh =
            (pet.neighborhood ?? '').toLowerCase().contains(_searchQuery);
        final matchSpecies = pet.species.toLowerCase().contains(_searchQuery);
        final matchSize = pet.size.toLowerCase().contains(_searchQuery);
        if (!matchName &&
            !matchDesc &&
            !matchCity &&
            !matchNeigh &&
            !matchSpecies &&
            !matchSize) {
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
            content: Text('¡$petName guardado en tus favoritos! 💜'),
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
    final isMobileShell = screenWidth < 860;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: PawCoColors.plum,
        onRefresh: () async => ref.refresh(petsProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===============================================================
              // CABECERA VIOLETA PROFUNDO AURORA + ONDA CON SILUETAS LINEALES
              // ===============================================================
              PawColAuroraWaveHeader(
                contentPadding: EdgeInsets.fromLTRB(
                  isDesktop ? 32 : 16,
                  MediaQuery.of(context).padding.top + (isDesktop ? 24 : 16),
                  isDesktop ? 32 : 16,
                  18,
                ),
                waveHeight: 54,
                child: _buildAuroraHeaderContent(context, user, isDesktop),
              ),

              // ===============================================================
              // ZONA MARFIL-LILA PASTEL (#FAF6F9): FILTROS CIRCULARES + GRILLA
              // ===============================================================
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: 8,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selector rápido con iconos circulares tiernos (Lila Algodón y Rosa Malva)
                        _buildCircularQuickCategories(),
                        const SizedBox(height: 16),

                        // Buscador integrado en Blanco Puro con borde Lila
                        _buildSearchBar(),
                        const SizedBox(height: 12),

                        // Píldoras horizontales por especie, edad y municipio AMB
                        _buildPillFilters(),
                        const SizedBox(height: 20),

                        // Contenido reactivo de mascotas
                        petsAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: PawCoColors.plum,
                              ),
                            ),
                          ),
                          error: (e, _) => _buildErrorState(e),
                          data: (allPets) {
                            final filteredPets = _filterPets(allPets);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildResultsCount(filteredPets.length),
                                const SizedBox(height: 14),
                                if (filteredPets.isEmpty)
                                  _buildEmptyState()
                                else
                                  _buildResponsiveGrid(filteredPets),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: isMobileShell ? 148 : 90),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: isMobileShell ? 76 : 0),
        child: FloatingActionButton.extended(
          backgroundColor: PawCoColors.plum,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: PawCoColors.malva.withValues(alpha: 0.55),
              width: 1.2,
            ),
          ),
          onPressed: () async {
            final currentUser = _getCurrentUser();
            if (currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Inicia sesión para dar en adopción una mascota 🐾',
                  ),
                ),
              );
              context.push('/login');
              return;
            }

            await context.push('/pets/new');
            ref.invalidate(petsProvider);
            ref.invalidate(myPetsProvider);
          },
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(
            'Dar en adopción',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CONTENIDO DEL HERO AURORA DE ADOPCIONES
  // ===========================================================================
  Widget _buildAuroraHeaderContent(
    BuildContext context,
    User? user,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra superior interna adaptable desde 320px
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [PawCoColors.orchid, PawCoColors.malva],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'PawCol Adopciones',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Material(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Inicia sesión para gestionar tus publicaciones 🐾',
                        ),
                      ),
                    );
                    context.push('/login');
                  } else {
                    context.push('/my-pets');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: PawCoColors.lilacGlow.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: PawCoColors.lilacGlow,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Mis publicaciones',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Cuerpo editorial + ilustración vectorial en Desktop
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: PawCoColors.malva.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      '💜 ADOPCIÓN RESPONSABLE AMB',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: PawCoColors.lilacGlow,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  PawColGradientText(
                    'Encuentra un compañero',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isDesktop ? 34 : 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conoce a los perros, gatos y peluditos rescatados en Bucaramanga, Floridablanca, Girón y Piedecuesta que esperan un hogar amoroso y verificado.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      color: Colors.white.withValues(alpha: 0.84),
                      height: 1.48,
                    ),
                  ),
                ],
              ),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 24),
              SvgPicture.asset(
                'assets/vectors/pawcol_rescuer_pets.svg',
                width: 175,
                height: 135,
                fit: BoxFit.contain,
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // CATEGORÍAS CIRCULARES INTERACTIVAS (PALETA VIOLETA 2)
  // ===========================================================================
  Widget _buildCircularQuickCategories() {
    final quickItems = [
      (
        label: 'Todos',
        pill: '🐾 Todos',
        icon: Icons.grid_view_rounded,
        malva: false,
      ),
      (
        label: 'Caninos',
        pill: '🐕 Perros',
        icon: Icons.pets_rounded,
        malva: true,
      ),
      (
        label: 'Felinos',
        pill: '🐈 Gatos',
        icon: Icons.cruelty_free_rounded,
        malva: false,
      ),
      (
        label: 'Cachorros',
        pill: '🐾 Cachorros (<1 año)',
        icon: Icons.auto_awesome_rounded,
        malva: true,
      ),
      (
        label: 'Capital',
        pill: '📍 Bucaramanga',
        icon: Icons.location_city_rounded,
        malva: false,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: quickItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: PawColCircularCategoryChip(
              label: item.label,
              icon: item.icon,
              isSelected: _selectedPill == item.pill,
              useMalvaTint: item.malva,
              onTap: () {
                setState(() {
                  _selectedPill = item.pill;
                });
              },
            ),
          );
        }).toList(),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PawCoColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: PawCoColors.plum.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, barrio, raza o especie...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: PawCoColors.mutedLight,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: PawCoColors.plum),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CHIPS REDONDEADOS ESTILO PÍLDORA
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
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : PawCoColors.inkSecondary,
                ),
              ),
              selected: isSelected,
              selectedColor: PawCoColors.plum,
              backgroundColor: PawCoColors.surface,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? PawCoColors.plum : PawCoColors.border,
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
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
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
                fontWeight: FontWeight.w700,
                color: PawCoColors.malva,
              ),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // GRID RESPONSIVE DE MASCOTAS (1 col <340px, 2 móvil, 3 tablet, 4 desktop)
  // ===========================================================================
  Widget _buildResponsiveGrid(List<Pet> pets) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = 2;
        if (width < 340) {
          columns = 1;
        } else if (width >= 1050) {
          columns = 4;
        } else if (width >= 650) {
          columns = 3;
        }

        const double spacing = 14.0;
        final itemWidth = (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(pets.length, (index) {
            final pet = pets[index];
            return SizedBox(
              width: itemWidth,
              child: PawCoFadeSlide(
                delay: Duration(milliseconds: (index % 6) * 45),
                child: _buildVioleta2PetCard(pet),
              ),
            );
          }),
        );
      },
    );
  }

  // ===========================================================================
  // TARJETA DE MASCOTA PALETA VIOLETA 2
  // ===========================================================================
  Widget _buildVioleta2PetCard(Pet pet) {
    final isFavorite = _favoritePetIds.contains(pet.id);

    return PawCoHoverCard(
      borderRadius: 22,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      onTap: () => context.push('/pet/${pet.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: AspectRatio(
                  aspectRatio: 1.08,
                  child: pet.photoUrl.isNotEmpty
                      ? Image.network(
                          pet.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderPhoto(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: PawCoColors.sageMuted,
                              child: const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: PawCoColors.plum,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : _buildPlaceholderPhoto(),
                ),
              ),

              // Botón de Corazón (Rosa Malva activo)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.90),
                  shape: const CircleBorder(),
                  elevation: 1,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _toggleFavorite(pet.id, pet.name),
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: isFavorite
                            ? PawCoColors.malva
                            : PawCoColors.plum,
                      ),
                    ),
                  ),
                ),
              ),

              // Píldora de especie en Lila Algodón
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PawCoColors.border),
                  ),
                  child: Text(
                    pet.species,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: PawCoColors.plum,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${pet.name} • ${pet.age == 1 ? "1 año" : "${pet.age} años"}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: PawCoColors.ink,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: PawCoColors.malva,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${pet.city}${pet.neighborhood != null && pet.neighborhood!.isNotEmpty ? " • ${pet.neighborhood}" : ""}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: PawCoColors.muted,
                          fontWeight: FontWeight.w600,
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
      color: PawCoColors.cottonLilac.withValues(alpha: 0.45),
      child: const Center(
        child: Icon(
          Icons.pets_rounded,
          size: 40,
          color: PawCoColors.plum,
        ),
      ),
    );
  }

  Widget _buildErrorState(Object e) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PawCoColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PawCoColors.border),
      ),
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
            'Error cargando mascotas:\n$e',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: PawCoColors.ink),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: PawCoColors.plum,
              foregroundColor: Colors.white,
            ),
            onPressed: () => ref.refresh(petsProvider.future),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: PawCoColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PawCoColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: PawCoColors.cottonLilac,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 38,
              color: PawCoColors.plum,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No encontramos peluditos con estos filtros',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
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
              foregroundColor: PawCoColors.plum,
              side: const BorderSide(color: PawCoColors.plum),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
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
