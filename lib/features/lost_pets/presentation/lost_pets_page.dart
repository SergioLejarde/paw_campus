import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme.dart';
import '../../../core/presentation/app_feedback.dart';
import '../../../core/presentation/pawco_design_system.dart';
import '../data/lost_pets_repository.dart';

/// Centro geográfico del Área Metropolitana de Bucaramanga
const _bucaramangaCenter = LatLng(7.1160, -73.1190);

class LostPetsPage extends ConsumerStatefulWidget {
  const LostPetsPage({super.key});

  @override
  ConsumerState<LostPetsPage> createState() => _LostPetsPageState();
}

class _LostPetsPageState extends ConsumerState<LostPetsPage> {
  // 0: Vista Lista, 1: Vista Mapa Interactivo
  int _viewMode = 0;

  // Filtros
  String _selectedTypeFilter = 'all'; // 'all', 'lost', 'found'
  String _selectedMunicipality = 'Todos';

  final MapController _mapController = MapController();
  LostPetReport? _selectedMapReport;

  User? _getCurrentUser() {
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lostPetsAsync = ref.watch(activeLostPetsProvider);
    final user = _getCurrentUser();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isMobileShell = screenWidth < 860;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // =================================================================
          // CABECERA AURORA VIOLETA 2 + SELECTOR DE VISTA LISTA / MAPA
          // =================================================================
          PawColAuroraWaveHeader(
            contentPadding: EdgeInsets.fromLTRB(
              isDesktop ? 32 : 16,
              MediaQuery.of(context).padding.top + (isDesktop ? 18 : 12),
              isDesktop ? 32 : 16,
              10,
            ),
            waveHeight: 34,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                        Icons.location_searching_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '📍 Perdidos y Encontrados',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: isDesktop ? 22 : 18,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: PawCoColors.lilacGlow,
                      ),
                      tooltip: 'Actualizar reportes',
                      onPressed: () => ref.invalidate(activeLostPetsProvider),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Conmutador tipo cápsula Glassmorphism adaptable desde 320px
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: PawCoColors.lilacGlow.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildAuroraViewSegment(
                          index: 0,
                          icon: Icons.format_list_bulleted_rounded,
                          label: 'Lista de Alertas',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildAuroraViewSegment(
                          index: 1,
                          icon: Icons.map_rounded,
                          label: 'Mapa Interactivo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Barra de Filtros Rápidos (Tipo y Municipio)
          _buildFilterBar(),

          // Contenido: Lista o Mapa Interactivo
          Expanded(
            child: lostPetsAsync.when(
              data: (reports) {
                final filtered = reports.where((r) {
                  if (_selectedTypeFilter == 'lost' && !r.isLost) return false;
                  if (_selectedTypeFilter == 'found' && !r.isFound) {
                    return false;
                  }
                  if (_selectedMunicipality != 'Todos' &&
                      r.municipality.toLowerCase() !=
                          _selectedMunicipality.toLowerCase()) {
                    return false;
                  }
                  return true;
                }).toList();

                if (_viewMode == 0) {
                  return _buildListView(
                    filtered,
                    user,
                    isDesktop,
                    isMobileShell,
                  );
                } else {
                  return _buildMapView(filtered, isMobileShell);
                }
              },
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
                        'Error al cargar reportes: $e',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: PawCoColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PawCoColors.plum,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => ref.invalidate(activeLostPetsProvider),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
          icon: const Icon(Icons.add_location_alt_rounded, size: 20),
          label: Text(
            'Reportar Mascota',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          onPressed: () => _handleReportButtonClick(context, user),
        ),
      ),
    );
  }

  Widget _buildAuroraViewSegment({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _viewMode == index;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _viewMode = index;
          _selectedMapReport = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [PawCoColors.orchid, PawCoColors.malva],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: Colors.white.withValues(alpha: isSelected ? 1.0 : 0.78),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color:
                      Colors.white.withValues(alpha: isSelected ? 1.0 : 0.78),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // BARRA DE FILTROS RÁPIDOS
  // ===========================================================================
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTypeFilterChip(
                  label: 'Todos',
                  value: 'all',
                  activeColor: PawCoColors.plum,
                ),
                const SizedBox(width: 6),
                _buildTypeFilterChip(
                  label: '🔴 Perdidos',
                  value: 'lost',
                  activeColor: PawCoColors.malva,
                ),
                const SizedBox(width: 6),
                _buildTypeFilterChip(
                  label: '🟢 Encontrados',
                  value: 'found',
                  activeColor: const Color(0xFF059669),
                ),
                const SizedBox(width: 12),
                Container(height: 22, width: 1, color: PawCoColors.border),
                const SizedBox(width: 12),
                ...[
                  'Todos',
                  'Bucaramanga',
                  'Floridablanca',
                  'Girón',
                  'Piedecuesta',
                ].map(
                  (muni) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(
                        muni == 'Todos' ? '📍 Todo AMB' : muni,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: _selectedMunicipality == muni
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: _selectedMunicipality == muni
                              ? Colors.white
                              : PawCoColors.inkSecondary,
                        ),
                      ),
                      selected: _selectedMunicipality == muni,
                      selectedColor: PawCoColors.plum,
                      backgroundColor: PawCoColors.surface,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _selectedMunicipality == muni
                              ? PawCoColors.plum
                              : PawCoColors.border,
                        ),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedMunicipality = muni;
                        });
                        if (_viewMode == 1) {
                          _centerMapOnMunicipality(muni);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilterChip({
    required String label,
    required String value,
    required Color activeColor,
  }) {
    final isSelected = _selectedTypeFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSelected ? Colors.white : PawCoColors.inkSecondary,
        ),
      ),
      selected: isSelected,
      selectedColor: activeColor,
      backgroundColor: PawCoColors.surface,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? activeColor : PawCoColors.border,
        ),
      ),
      onSelected: (_) {
        setState(() {
          _selectedTypeFilter = value;
        });
      },
    );
  }

  // ===========================================================================
  // VISTA 1: LISTA DE REPORTES
  // ===========================================================================
  Widget _buildListView(
    List<LostPetReport> reports,
    User? currentUser,
    bool isDesktop,
    bool isMobileShell,
  ) {
    if (reports.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: PawCoColors.cottonLilac,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 44,
                  color: PawCoColors.plum,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron alertas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: PawCoColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prueba ajustando los filtros de tipo o municipio, o publica una nueva alerta.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: PawCoColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: PawCoColors.plum,
      onRefresh: () async => ref.refresh(activeLostPetsProvider.future),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 32 : 16,
          8,
          isDesktop ? 32 : 16,
          isMobileShell ? 150 : 96,
        ),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: PawCoFadeSlide(
                delay: Duration(milliseconds: (index % 5) * 45),
                child: _buildLostPetCard(context, report, currentUser),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLostPetCard(
    BuildContext context,
    LostPetReport report,
    User? currentUser,
  ) {
    final isLost = report.isLost;
    final badgeColor = isLost ? PawCoColors.malva : const Color(0xFF059669);
    final badgeBg = isLost ? PawCoColors.softMalva : const Color(0xFFECFDF5);
    final badgeText = isLost ? '🚨 SE BUSCA' : '👀 ENCONTRADO / AVISTADO';

    final isCreatorOrAdmin =
        currentUser != null && (report.createdBy == currentUser.id);

    return PawCoHoverCard(
      borderRadius: 22,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: report.photoUrl != null && report.photoUrl!.isNotEmpty
                    ? Image.network(
                        report.photoUrl!,
                        height: 195,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPhotoPlaceholder(isLost),
                      )
                    : _buildPhotoPlaceholder(isLost),
              ),
              Positioned(
                top: 12,
                left: 12,
                right: 52,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLost
                              ? Icons.warning_rounded
                              : Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            badgeText,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black45,
                  shape: const CircleBorder(),
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    tooltip: 'Opciones de publicación',
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    itemBuilder: (context) => [
                      if (isCreatorOrAdmin)
                        const PopupMenuItem(
                          value: 'resolved',
                          child: Row(
                            children: [
                              Icon(
                                Icons.celebration_rounded,
                                color: PawCoColors.plum,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text('Marcar como ¡Ya apareció! 🎉'),
                              ),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'flag',
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              color: PawCoColors.error,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text('Reportar publicación indebida'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (val) {
                      if (val == 'resolved') {
                        _confirmMarkAsResolved(context, report);
                      } else if (val == 'flag') {
                        _confirmFlagReport(context, report);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.petName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: PawCoColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        report.species,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isLost
                              ? PawCoColors.terracottaDark
                              : const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 15,
                      color: PawCoColors.plum,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${report.neighborhood}, ${report.municipality}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: PawCoColors.inkSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTimeAgo(report.createdAt),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: PawCoColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  report.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: PawCoColors.inkSecondary,
                    height: 1.45,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: PawCoColors.border),
                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final stackBtns = constraints.maxWidth < 300;
                    final waBtn = ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.chat_rounded, size: 17),
                      label: Text(
                        'WhatsApp',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () => _openWhatsApp(context, report),
                    );

                    final mapBtn = OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PawCoColors.plum,
                        side: const BorderSide(color: PawCoColors.plum),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.map_outlined, size: 17),
                      label: Text(
                        'Ver en mapa',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _viewMode = 1;
                          _selectedMapReport = report;
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _mapController.move(report.latLng, 15.0);
                        });
                      },
                    );

                    if (stackBtns) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          waBtn,
                          const SizedBox(height: 8),
                          mapBtn,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(flex: 6, child: waBtn),
                        const SizedBox(width: 10),
                        Expanded(flex: 5, child: mapBtn),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(bool isLost) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isLost ? PawCoColors.softMalva : PawCoColors.cottonLilac,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pets_rounded,
              size: 42,
              color: isLost ? PawCoColors.malva : PawCoColors.plum,
            ),
            const SizedBox(height: 6),
            Text(
              isLost ? 'Mascota perdida' : 'Animalito avistado',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color:
                    isLost ? PawCoColors.terracottaDark : PawCoColors.plum,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // VISTA 2: MAPA INTERACTIVO
  // ===========================================================================
  Widget _buildMapView(List<LostPetReport> reports, bool isMobileShell) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _bucaramangaCenter,
            initialZoom: 12.8,
            minZoom: 9.0,
            maxZoom: 18.0,
            onTap: (_, __) {
              setState(() {
                _selectedMapReport = null;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'co.pawco.app',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: reports.map((report) {
                final isLost = report.isLost;
                final isSelected = _selectedMapReport?.id == report.id;
                final pinColor =
                    isLost ? PawCoColors.malva : const Color(0xFF059669);

                return Marker(
                  point: report.latLng,
                  width: isSelected ? 56 : 46,
                  height: isSelected ? 56 : 46,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMapReport = report;
                      });
                      _mapController.move(report.latLng, 14.5);
                    },
                    child: _buildMapPin(report, pinColor, isSelected),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        Positioned(
          top: 10,
          right: 12,
          child: Column(
            children: [
              _buildMapQuickActionButton(
                icon: Icons.my_location_rounded,
                tooltip: 'Centrar en Bucaramanga',
                onPressed: () => _mapController.move(_bucaramangaCenter, 13.0),
              ),
              const SizedBox(height: 8),
              _buildMapQuickActionButton(
                icon: Icons.add,
                tooltip: 'Acercar',
                onPressed: () {
                  final zoom = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, zoom + 1);
                },
              ),
              const SizedBox(height: 6),
              _buildMapQuickActionButton(
                icon: Icons.remove,
                tooltip: 'Alejar',
                onPressed: () {
                  final zoom = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, zoom - 1);
                },
              ),
            ],
          ),
        ),

        Positioned(
          top: 10,
          left: 12,
          right: 68,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PawCoColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.pin_drop_rounded,
                    size: 16,
                    color: PawCoColors.plum,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${reports.length} reportes en el mapa',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: PawCoColors.ink,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (_selectedMapReport != null)
          Positioned(
            left: 14,
            right: 14,
            bottom: isMobileShell ? 148 : 80,
            child: _buildMapReportFloatingCard(context, _selectedMapReport!),
          ),
      ],
    );
  }

  Widget _buildMapPin(LostPetReport report, Color pinColor, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: pinColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: isSelected ? 3.0 : 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: pinColor.withValues(alpha: 0.45),
            blurRadius: isSelected ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          report.isLost ? Icons.pets_rounded : Icons.search_rounded,
          color: Colors.white,
          size: isSelected ? 26 : 20,
        ),
      ),
    );
  }

  Widget _buildMapQuickActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      elevation: 2,
      shape: const CircleBorder(),
      color: Colors.white,
      child: IconButton(
        icon: Icon(icon, size: 20, color: PawCoColors.plum),
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildMapReportFloatingCard(
    BuildContext context,
    LostPetReport report,
  ) {
    final isLost = report.isLost;
    final badgeColor = isLost ? PawCoColors.malva : const Color(0xFF059669);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: report.photoUrl != null && report.photoUrl!.isNotEmpty
                      ? Image.network(
                          report.photoUrl!,
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 58,
                            height: 58,
                            color: PawCoColors.cottonLilac,
                            child: const Icon(
                              Icons.pets_rounded,
                              color: PawCoColors.plum,
                            ),
                          ),
                        )
                      : Container(
                          width: 58,
                          height: 58,
                          color: PawCoColors.cottonLilac,
                          child: const Icon(
                            Icons.pets_rounded,
                            color: PawCoColors.plum,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isLost ? '🔴 PERDIDO' : '🟢 AVISTADO',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          Text(
                            report.species,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: PawCoColors.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.petName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PawCoColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: PawCoColors.plum,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              '${report.neighborhood}, ${report.municipality}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: PawCoColors.inkSecondary,
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
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedMapReport = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.chat_rounded, size: 16),
                label: Text(
                  'Contactar por WhatsApp',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () => _openWhatsApp(context, report),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _centerMapOnMunicipality(String municipality) {
    final target = switch (municipality.toLowerCase()) {
      'bucaramanga' => const LatLng(7.1193, -73.1227),
      'floridablanca' => const LatLng(7.0622, -73.0864),
      'girón' || 'giron' => const LatLng(7.0684, -73.1698),
      'piedecuesta' => const LatLng(6.9879, -73.0503),
      _ => _bucaramangaCenter,
    };
    _mapController.move(target, 13.5);
  }

  void _handleReportButtonClick(BuildContext context, User? user) {
    if (user == null) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: PawCoColors.plum),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Inicia sesión',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Para publicar un reporte de mascota perdida o encontrada y poder actualizar su estado, debes iniciar sesión o registrarte gratis.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PawCoColors.plum,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/login');
              },
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      );
    } else {
      context.push('/lost-pets/new').then((_) {
        ref.invalidate(activeLostPetsProvider);
      });
    }
  }

  Future<void> _openWhatsApp(BuildContext context, LostPetReport report) async {
    final cleanPhone = report.cleanWhatsappPhone;
    if (cleanPhone.isEmpty) {
      AppFeedback.showError(
        context,
        'No se ha registrado un teléfono de contacto válido.',
      );
      return;
    }

    final message = report.isLost
        ? 'Hola, vi tu reporte en PawCol sobre ${report.petName} (${report.species} en ${report.neighborhood}, ${report.municipality}) y quiero brindarte información.'
        : 'Hola, vi en PawCol que avistaron o encontraron a ${report.petName} (${report.species} en ${report.neighborhood}, ${report.municipality}) y quisiera consultar información.';

    final uri = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        AppFeedback.showError(
          context,
          'No se pudo abrir WhatsApp. Intenta agregando el número $cleanPhone directamente.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppFeedback.showError(
          context,
          'No se pudo conectar con WhatsApp. Número: $cleanPhone',
        );
      }
    }
  }

  Future<void> _confirmMarkAsResolved(
    BuildContext context,
    LostPetReport report,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration_rounded, color: PawCoColors.plum),
            SizedBox(width: 8),
            Flexible(child: Text('¡Ya apareció! 🎉')),
          ],
        ),
        content: Text(
          '¿Deseas marcar la búsqueda de "${report.petName}" como resuelta? El reporte se retirará del mapa activo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PawCoColors.plum,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final repo = ref.read(lostPetsRepositoryProvider);
      await repo.markAsResolved(report.id);
      ref.invalidate(activeLostPetsProvider);
      if (context.mounted) {
        AppFeedback.showSuccess(
          context,
          '¡Excelente noticia! El reporte ha sido marcado como resuelto.',
        );
      }
    }
  }

  Future<void> _confirmFlagReport(
    BuildContext context,
    LostPetReport report,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.flag_rounded, color: PawCoColors.error),
            SizedBox(width: 8),
            Flexible(child: Text('Reportar Publicación')),
          ],
        ),
        content: const Text(
          '¿Consideras que esta publicación contiene información falsa, ofensiva o spam? Se notificará al equipo administrador para su revisión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PawCoColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reportar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final repo = ref.read(lostPetsRepositoryProvider);
      await repo.flagInappropriateReport(report.id);
      ref.invalidate(activeLostPetsProvider);
      if (context.mounted) {
        AppFeedback.showSuccess(
          context,
          'Gracias por tu reporte. El equipo de PawCol revisará esta publicación.',
        );
      }
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes.clamp(1, 59)} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} d';
    }
  }
}
