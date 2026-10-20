import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  String _selectedMunicipality = '📍 Todo AMB';
  String _selectedSpecies = '🐾 Todas';

  static const List<String> _municipalities = [
    '📍 Todo AMB',
    'Bucaramanga',
    'Floridablanca',
    'Girón',
    'Piedecuesta',
  ];

  static const List<String> _speciesOptions = [
    '🐾 Todas',
    'Perro',
    'Gato',
    'Otro',
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
      // 1. Filtro por Municipio
      if (_selectedMunicipality != '📍 Todo AMB') {
        if (pet.city.toLowerCase() != _selectedMunicipality.toLowerCase()) {
          return false;
        }
      }

      // 2. Filtro por Especie
      if (_selectedSpecies != '🐾 Todas') {
        if (_selectedSpecies == 'Otro') {
          final s = pet.species.toLowerCase();
          if (s == 'perro' || s == 'gato') {
            return false;
          }
        } else {
          if (pet.species.toLowerCase() != _selectedSpecies.toLowerCase()) {
            return false;
          }
        }
      }

      // 3. Filtro por texto (Nombre, descripción, barrio o ciudad)
      if (_searchQuery.isNotEmpty) {
        final matchName = pet.name.toLowerCase().contains(_searchQuery);
        final matchDesc = pet.description.toLowerCase().contains(_searchQuery);
        final matchCity = pet.city.toLowerCase().contains(_searchQuery);
        final matchNeigh = (pet.neighborhood ?? '').toLowerCase().contains(_searchQuery);
        if (!matchName && !matchDesc && !matchCity && !matchNeigh) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedMunicipality = '📍 Todo AMB';
      _selectedSpecies = '🐾 Todas';
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petsProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              '🐾 PawCo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Text(
              'Adopciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFF64748B),
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
            icon: const Icon(Icons.inventory_2_outlined, size: 18),
            label: const Text(
              'Mis publicaciones',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(petsProvider.future),
        child: petsAsync.when(
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
                    'Error cargando mascotas:\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
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

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              children: [
                // Barra de búsqueda por texto
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar peludito por nombre o barrio...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF0D9488)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filtro 1: Chips de Municipio
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _municipalities.map((mun) {
                      final isSelected = _selectedMunicipality == mun;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(mun),
                          selected: isSelected,
                          selectedColor: const Color(0xFFCCFBF1),
                          checkmarkColor: const Color(0xFF0D9488),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF334155),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedMunicipality = mun;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 6),

                // Filtro 2: Chips de Especie
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _speciesOptions.map((species) {
                      final isSelected = _selectedSpecies == species;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(species),
                          selected: isSelected,
                          selectedColor: const Color(0xFFFEF3C7),
                          checkmarkColor: const Color(0xFFD97706),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFFB45309) : const Color(0xFF334155),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedSpecies = species;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),

                // Contador de peluditos y limpiar filtros
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredPets.length} ${filteredPets.length == 1 ? "peludito esperando un hogar" : "peluditos esperando un hogar"} 🏡',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if (_selectedMunicipality != '📍 Todo AMB' ||
                        _selectedSpecies != '🐾 Todas' ||
                        _searchQuery.isNotEmpty)
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text('Limpiar filtros', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Estado vacío cuando los filtros no devuelven nada
                if (filteredPets.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(28),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF3C7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pets,
                            size: 46,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay peluditos que coincidan con estos filtros',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Prueba seleccionando otro municipio o eliminando los términos de búsqueda.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Ver todas las mascotas'),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredPets.map((pet) => _buildPetCard(context, pet)),

                const SizedBox(height: 60), // Margen inferior para el FAB
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final currentUser = Supabase.instance.client.auth.currentUser;
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
        icon: const Icon(Icons.add),
        label: const Text('Dar en adopción'),
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, Pet pet) {
    Color speciesBg;
    Color speciesFg;
    IconData speciesIcon;

    final lowerSpecies = pet.species.toLowerCase();
    if (lowerSpecies.contains('gato')) {
      speciesBg = const Color(0xFFFEF3C7);
      speciesFg = const Color(0xFFB45309);
      speciesIcon = Icons.pets;
    } else if (lowerSpecies.contains('perro')) {
      speciesBg = const Color(0xFFCCFBF1);
      speciesFg = const Color(0xFF0F766E);
      speciesIcon = Icons.pets;
    } else {
      speciesBg = const Color(0xFFEDE9FE);
      speciesFg = const Color(0xFF6D28D9);
      speciesIcon = Icons.cruelty_free;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/pet/${pet.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto de la mascota con placeholder cálido
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 110,
                  height: 120,
                  child: pet.photoUrl.isNotEmpty
                      ? Image.network(
                          pet.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderPhoto(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          },
                        )
                      : _buildPlaceholderPhoto(),
                ),
              ),
              const SizedBox(width: 14),

              // Información del peludito
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila superior: Nombre + Badge Especie
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: speciesBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(speciesIcon, size: 12, color: speciesFg),
                              const SizedBox(width: 4),
                              Text(
                                pet.species,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: speciesFg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Badges de Municipio y Ubicación
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFF0D9488),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${pet.city}${pet.neighborhood != null && pet.neighborhood!.isNotEmpty ? " • ${pet.neighborhood}" : ""}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0D9488),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Chips de Edad y Tamaño
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${pet.age} ${pet.age == 1 ? "año" : "años"}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Tamaño ${pet.size}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Descripción
                    Text(
                      pet.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Container(
      color: const Color(0xFFFEF3C7),
      child: const Center(
        child: Icon(
          Icons.pets,
          size: 38,
          color: Color(0xFFD97706),
        ),
      ),
    );
  }
}
