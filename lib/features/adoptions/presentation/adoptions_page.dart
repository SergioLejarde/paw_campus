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

  // Filtro activo por píldora
  String _selectedPill = '🐾 Todos';

  // Conjunto de mascotas favoritas en estado local interactivo
  final Set<String> _favoritePetIds = {'seed-luna-bga'};

  static const List<String> _speciesPills = [
    '🐾 Todos',
    '🐕 Perros',
    '🐈 Gatos',
    '🐾 Cachorros (<1 año)',
  ];

  static const List<String> _cityPills = [
    '📍 Bucaramanga',
    'Floridablanca',
    'Girón',
    'Piedecuesta',
  ];

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
    final isDesktop = screenWidth >= 1050;
    final isTablet = screenWidth >= 700 && screenWidth < 1050;
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
              // 1. CABECERA COMPACTA "LIENZO CONTINUO" (SIN CORTE OSCURO)
              // ===============================================================
              PawColAuroraWaveHeader(
                isContinuous: true,
                contentPadding: EdgeInsets.fromLTRB(
                  screenWidth >= 900 ? 36 : 16,
                  MediaQuery.of(context).padding.top + (screenWidth >= 900 ? 20 : 12),
                  screenWidth >= 900 ? 36 : 16,
                  14,
                ),
                maxWidth: 1440,
                child: _buildContinuousHeaderContent(context, user, screenWidth),
              ),

              // ===============================================================
              // 2. CUERPO CONTINUO: TOOLBAR UNIFICADO + GRILLA + SIDEBAR
              // ===============================================================
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth >= 900 ? 36 : 16,
                  vertical: 14,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Toolbar Unificado (Buscador + Píldoras en un solo bloque limpio)
                        _buildUnifiedFilterToolbar(screenWidth),
                        const SizedBox(height: 14),

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
                                else if (isDesktop)
                                  // Layout de escritorio amplio (4 cols + sidebar)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildResponsiveGrid(
                                          filteredPets,
                                          columnsCount: 3,
                                        ),
                                      ),
                                      const SizedBox(width: 26),
                                      SizedBox(
                                        width: 310,
                                        child: _buildDesktopSidebar(context, user),
                                      ),
                                    ],
                                  )
                                else
                                  // Layout móvil y tablet fluido
                                  _buildResponsiveGrid(
                                    filteredPets,
                                    columnsCount: isTablet ? 3 : 2,
                                  ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: isMobileShell ? 148 : 80),
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
          onPressed: () => _handleCreatePet(context),
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

  Future<void> _handleCreatePet(BuildContext context) async {
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
  }

  // ===========================================================================
  // 1. CABECERA COMPACTA LIENZO CONTINUO
  // ===========================================================================
  Widget _buildContinuousHeaderContent(
    BuildContext context,
    User? user,
    double screenWidth,
  ) {
    final isWide = screenWidth >= 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila superior: Logo del módulo + Badge + Botón Mis publicaciones
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
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [PawCoColors.orchid, PawCoColors.malva],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth < 360 ? 190 : 280,
                  ),
                  child: Text(
                    'PawCol Adopciones',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: screenWidth < 360 ? 14.5 : 16,
                      color: PawCoColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: PawCoColors.softMalva,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: PawCoColors.malva.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                '💜 ADOPCIÓN RESPONSABLE AMB',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: PawCoColors.terracottaDark,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            Material(
              color: Colors.white,
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
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: PawCoColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: PawCoColors.plum.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 15,
                        color: PawCoColors.plum,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Mis publicaciones',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: PawCoColors.plum,
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
        const SizedBox(height: 12),

        // Título + Subtítulo limpio
        PawColGradientText(
          'Encuentra un compañero',
          colors: const [
            PawCoColors.plum,
            PawCoColors.plumVibrant,
            PawCoColors.malva,
          ],
          style: GoogleFonts.plusJakartaSans(
            fontSize: isWide ? 30 : 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            height: 1.16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Conoce a los perros, gatos y peluditos rescatados en Bucaramanga, Floridablanca, Girón y Piedecuesta que esperan un hogar amoroso y verificado.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: PawCoColors.inkSecondary,
            height: 1.42,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. TOOLBAR UNIFICADO (Buscador + Selector de Especie + Filtro Municipio)
  // ===========================================================================
  Widget _buildUnifiedFilterToolbar(double screenWidth) {
    final isDesktop = screenWidth >= 1050;

    if (isDesktop) {
      // Formato unificado en una sola barra horizontal estilo SaaS moderno
      return Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: PawCoColors.border, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: PawCoColors.plum.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Campo de búsqueda integrado
            Expanded(
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(Icons.search_rounded, color: PawCoColors.plum, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: PawCoColors.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre, barrio, raza o especie...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: PawCoColors.mutedLight,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: () => _searchController.clear(),
                    ),
                ],
              ),
            ),

            Container(
              height: 28,
              width: 1,
              color: PawCoColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),

            // Contenedor scrollable horizontal para los filtros de pastillas
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Segmented selector de especies en pastilla
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: PawCoColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _speciesPills.map((pill) {
                          final isSelected = _selectedPill == pill;
                          return InkWell(
                            borderRadius: BorderRadius.circular(9),
                            onTap: () => setState(() => _selectedPill = pill),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: PawCoColors.plum.withValues(alpha: 0.08),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                pill,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? PawCoColors.plum : PawCoColors.muted,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Filtros de municipios AMB
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _cityPills.map((city) {
                        final isSelected = _selectedPill == city;
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: ChoiceChip(
                            label: Text(city),
                            selected: isSelected,
                            selectedColor: PawCoColors.plum,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected ? PawCoColors.plum : PawCoColors.border,
                            ),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : PawCoColors.inkSecondary,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _selectedPill = isSelected ? '🐾 Todos' : city;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Formato móvil / tablet: Buscador limpio + scroll horizontal de píldoras
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Buscador
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PawCoColors.border, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: PawCoColors.plum.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, barrio, raza o especie...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: PawCoColors.mutedLight,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: PawCoColors.plum, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Píldoras horizontales únicas (sin duplicar categorías circulares)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _filterPills.map((pill) {
              final isSelected = _selectedPill == pill;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(
                    pill,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : PawCoColors.inkSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: PawCoColors.plum,
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isSelected ? PawCoColors.plum : PawCoColors.border,
                    ),
                  ),
                  onSelected: (_) {
                    setState(() => _selectedPill = pill);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 3. BARRA DE RESULTADOS
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
                fontWeight: FontWeight.w800,
                color: PawCoColors.malva,
              ),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // 4. GRILLA RESPONSIVA DE MASCOTAS
  // ===========================================================================
  Widget _buildResponsiveGrid(List<Pet> pets, {int? columnsCount}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = columnsCount ?? 2;
        if (columnsCount == null) {
          if (width < 340) {
            columns = 1;
          } else if (width >= 1100) {
            columns = 4;
          } else if (width >= 700) {
            columns = 3;
          }
        }

        const double spacing = 16.0;
        final itemWidth = (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(pets.length, (index) {
            final pet = pets[index];
            return SizedBox(
              width: itemWidth,
              child: PawCoFadeSlide(
                delay: Duration(milliseconds: (index % 6) * 40),
                child: _buildCleanPetCard(pet),
              ),
            );
          }),
        );
      },
    );
  }

  // ===========================================================================
  // 5. TARJETA DE MASCOTA MODERNA (Estilo SaaS tierno y profesional)
  // ===========================================================================
  Widget _buildCleanPetCard(Pet pet) {
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
          // Imagen con badges superpuestos
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
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
                              color: PawCoColors.surfaceMuted,
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

              // Botón de favoritos
              Positioned(
                top: 9,
                right: 9,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _toggleFavorite(pet.id, pet.name),
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 17,
                        color: isFavorite ? PawCoColors.malva : PawCoColors.plum,
                      ),
                    ),
                  ),
                ),
              ),

              // Píldora de especie
              Positioned(
                bottom: 9,
                left: 9,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(10),
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

          // Información textual de la mascota
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                          fontSize: 12,
                          color: PawCoColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Etiquetas de estado
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildMiniBadge('Tamaño: ${pet.size}', isGreen: false),
                    _buildMiniBadge(
                      pet.status == 'approved' ? 'Verificado AMB' : pet.status,
                      isGreen: true,
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

  Widget _buildMiniBadge(String text, {required bool isGreen}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: isGreen
            ? const Color(0xFFDCFCE7)
            : PawCoColors.softMalva,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isGreen
              ? const Color(0xFF15803D)
              : PawCoColors.terracottaDark,
        ),
      ),
    );
  }

  // ===========================================================================
  // 6. PANEL LATERAL DE ESCRITORIO (Estilo Brace Card + Guía de 3 pasos)
  // ===========================================================================
  Widget _buildDesktopSidebar(BuildContext context, User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tarjeta de Acento Oscura estilo Brace Developers (CTA)
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF220D38),
                Color(0xFF381459),
                Color(0xFF4C1D6E),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: PawCoColors.lilacGlow.withValues(alpha: 0.30),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF220D38).withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [PawCoColors.orchid, PawCoColors.malva],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '¿Rescataste un peludito?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Publícalo gratis en PawCol y encuentra una familia responsable con seguimiento verificado en el AMB.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.82),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: PawCoColors.plum,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _handleCreatePet(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    'Dar en adopción',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Tarjeta "Cómo adoptar en PawCol" (Guía de 3 pasos)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: PawCoColors.border),
            boxShadow: [
              BoxShadow(
                color: PawCoColors.plum.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    color: PawCoColors.plum,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Proceso de Adopción',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: PawCoColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildStepItem(
                number: '1',
                title: 'Elige tu compañero',
                desc: 'Revisa fotos, historia médica, edad y temperamento.',
              ),
              const SizedBox(height: 12),
              _buildStepItem(
                number: '2',
                title: 'Postúlate y conoce',
                desc: 'Conversa con el rescatista o fundación para coordinar visita.',
              ),
              const SizedBox(height: 12),
              _buildStepItem(
                number: '3',
                title: 'Adopción verificada',
                desc: 'Firma de acta responsable y acompañamiento continuo.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required String number,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: PawCoColors.sageLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: PawCoColors.plum,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: PawCoColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: PawCoColors.muted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
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
