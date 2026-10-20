import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/presentation/app_feedback.dart';
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
  String _selectedMunicipality = 'Todos'; // 'Todos', 'Bucaramanga', etc.

  // Controlador del Mapa OpenStreetMap
  final MapController _mapController = MapController();

  // Reporte seleccionado para tarjeta flotante en el mapa
  LostPetReport? _selectedMapReport;

  @override
  Widget build(BuildContext context) {
    final lostPetsAsync = ref.watch(activeLostPetsProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 Perdidos y Encontrados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar reportes',
            onPressed: () => ref.invalidate(activeLostPetsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Conmutador Superior: Vista Lista vs Vista Mapa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment<int>(
                        value: 0,
                        icon: Icon(Icons.format_list_bulleted_rounded),
                        label: Text('Lista de Alertas'),
                      ),
                      ButtonSegment<int>(
                        value: 1,
                        icon: Icon(Icons.map_rounded),
                        label: Text('Mapa Interactivo'),
                      ),
                    ],
                    selected: {_viewMode},
                    onSelectionChanged: (Set<int> newSelection) {
                      setState(() {
                        _viewMode = newSelection.first;
                        _selectedMapReport = null;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: const Color(0xFF0D9488),
                      selectedForegroundColor: Colors.white,
                      foregroundColor: const Color(0xFF334155),
                      backgroundColor: Colors.white,
                      elevation: 1,
                    ),
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
                // Filtrar reportes en memoria
                final filtered = reports.where((r) {
                  // Filtro por tipo
                  if (_selectedTypeFilter == 'lost' && !r.isLost) return false;
                  if (_selectedTypeFilter == 'found' && !r.isFound) return false;

                  // Filtro por municipio
                  if (_selectedMunicipality != 'Todos' &&
                      r.municipality.toLowerCase() !=
                          _selectedMunicipality.toLowerCase()) {
                    return false;
                  }

                  return true;
                }).toList();

                if (_viewMode == 0) {
                  return _buildListView(filtered, user);
                } else {
                  return _buildMapView(filtered);
                }
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text(
                        'Error al cargar reportes: $e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => ref.invalidate(activeLostPetsProvider),
                        icon: const Icon(Icons.refresh),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text(
          'Reportar Mascota',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => _handleReportButtonClick(context, user),
      ),
    );
  }

  // ===========================================================================
  // BARRA DE FILTROS RÁPIDOS
  // ===========================================================================
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Filtros de Tipo
            _buildTypeFilterChip(
              label: 'Todos',
              value: 'all',
              activeColor: const Color(0xFF0D9488),
            ),
            const SizedBox(width: 6),
            _buildTypeFilterChip(
              label: '🔴 Perdidos',
              value: 'lost',
              activeColor: const Color(0xFFE11D48),
            ),
            const SizedBox(width: 6),
            _buildTypeFilterChip(
              label: '🟢 Encontrados',
              value: 'found',
              activeColor: const Color(0xFF059669),
            ),
            const SizedBox(width: 14),
            Container(height: 24, width: 1, color: const Color(0xFFCBD5E1)),
            const SizedBox(width: 14),

            // Filtros de Municipio
            ...[
              'Todos',
              'Bucaramanga',
              'Floridablanca',
              'Girón',
              'Piedecuesta'
            ].map(
              (muni) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(
                    muni == 'Todos' ? '📍 Todo AMB' : muni,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _selectedMunicipality == muni
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _selectedMunicipality == muni
                          ? Colors.white
                          : const Color(0xFF475569),
                    ),
                  ),
                  selected: _selectedMunicipality == muni,
                  selectedColor: const Color(0xFF0D9488),
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _selectedMunicipality == muni
                          ? const Color(0xFF0D9488)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  onSelected: (selected) {
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
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF334155),
        ),
      ),
      selected: isSelected,
      selectedColor: activeColor,
      backgroundColor: Colors.white,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? activeColor : const Color(0xFFE2E8F0),
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
  Widget _buildListView(List<LostPetReport> reports, User? currentUser) {
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
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No se encontraron alertas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Prueba ajustando los filtros de tipo o municipio, o publica una nueva alerta.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(activeLostPetsProvider.future),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _buildLostPetCard(context, report, currentUser);
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
    final badgeColor =
        isLost ? const Color(0xFFE11D48) : const Color(0xFF059669);
    final badgeBg = badgeColor.withValues(alpha: 0.12);
    final badgeText = isLost ? '🚨 SE BUSCA' : '👀 ENCONTRADO / AVISTADO';

    final isCreatorOrAdmin =
        currentUser != null && (report.createdBy == currentUser.id);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen o cabecera con badge
          Stack(
            children: [
              if (report.photoUrl != null && report.photoUrl!.isNotEmpty)
                Image.network(
                  report.photoUrl!,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPhotoPlaceholder(isLost),
                )
              else
                _buildPhotoPlaceholder(isLost),

              // Badge Tipo de Alerta
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        isLost ? Icons.warning_rounded : Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón de opciones / Reportar indebido
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black45,
                  shape: const CircleBorder(),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                    tooltip: 'Opciones de publicación',
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      if (isCreatorOrAdmin)
                        const PopupMenuItem(
                          value: 'resolved',
                          child: Row(
                            children: [
                              Icon(Icons.celebration_rounded,
                                  color: Color(0xFF0D9488), size: 18),
                              SizedBox(width: 8),
                              Text('Marcar como ¡Ya apareció! 🎉'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'flag',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined,
                                color: Color(0xFFE11D48), size: 18),
                            SizedBox(width: 8),
                            Text('Reportar publicación indebida'),
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

          // Contenido de la tarjeta
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre y Especie
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        report.petName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        report.species,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Ubicación (Municipio y Barrio)
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Color(0xFF0D9488)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${report.neighborhood}, ${report.municipality}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    Text(
                      _formatTimeAgo(report.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Descripción
                Text(
                  report.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Botones de acción: WhatsApp y Ver en Mapa
                Row(
                  children: [
                    // Botón WhatsApp Directo
                    Expanded(
                      flex: 6,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                        ),
                        icon: const Icon(Icons.chat_rounded, size: 18),
                        label: const Text(
                          'WhatsApp',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => _openWhatsApp(context, report),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Botón Ver en el Mapa
                    Expanded(
                      flex: 5,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D9488),
                          side: const BorderSide(color: Color(0xFF0D9488)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text(
                          'Ver en mapa',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          // Cambiar al modo mapa y centrar en el reporte
                          setState(() {
                            _viewMode = 1;
                            _selectedMapReport = report;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _mapController.move(report.latLng, 15.0);
                          });
                        },
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

  Widget _buildPhotoPlaceholder(bool isLost) {
    return Container(
      height: 160,
      width: double.infinity,
      color: isLost ? const Color(0xFFFFF1F2) : const Color(0xFFECFDF5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pets_rounded,
              size: 44,
              color: isLost ? const Color(0xFFFDA4AF) : const Color(0xFF6EE7B7),
            ),
            const SizedBox(height: 6),
            Text(
              isLost ? 'Mascota perdida' : 'Animalito avistado',
              style: TextStyle(
                fontSize: 12,
                color:
                    isLost ? const Color(0xFFE11D48) : const Color(0xFF059669),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // VISTA 2: MAPA INTERACTIVO (OpenStreetMap con flutter_map)
  // ===========================================================================
  Widget _buildMapView(List<LostPetReport> reports) {
    return Stack(
      children: [
        // Mapa OpenStreetMap
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
            // Capa de teselas OpenStreetMap gratuitas
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'co.pawco.app',
              maxZoom: 19,
            ),

            // Capa de Marcadores de Mascotas
            MarkerLayer(
              markers: reports.map((report) {
                final isLost = report.isLost;
                final isSelected = _selectedMapReport?.id == report.id;
                final pinColor =
                    isLost ? const Color(0xFFE11D48) : const Color(0xFF059669);

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

        // Botones flotantes de Centrado Rápido por Municipio en el Mapa
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

        // Indicador de Conteo de Reportes en el Mapa
        Positioned(
          top: 10,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                const Icon(Icons.pin_drop, size: 16, color: Color(0xFF0D9488)),
                const SizedBox(width: 4),
                Text(
                  '${reports.length} reportes en el mapa',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tarjeta flotante inferior al seleccionar un marcador
        if (_selectedMapReport != null)
          Positioned(
            left: 14,
            right: 14,
            bottom: 80,
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
        icon: Icon(icon, size: 20, color: const Color(0xFF334155)),
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
    final badgeColor =
        isLost ? const Color(0xFFE11D48) : const Color(0xFF059669);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Miniatura foto
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: report.photoUrl != null &&
                          report.photoUrl!.isNotEmpty
                      ? Image.network(
                          report.photoUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.pets, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.pets, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),

                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isLost ? '🔴 PERDIDO' : '🟢 AVISTADO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            report.species,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.petName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Color(0xFF0D9488)),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              '${report.neighborhood}, ${report.municipality}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF475569),
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

                // Cerrar tarjeta
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () {
                    setState(() {
                      _selectedMapReport = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Botón rápido de WhatsApp
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.chat_rounded, size: 16),
                label: const Text(
                  'Contactar por WhatsApp',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _openWhatsApp(context, report),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // MÉTODOS DE APOYO
  // ===========================================================================

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
      // Modo invitado: diálogo amigable
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: Color(0xFF0D9488)),
              SizedBox(width: 8),
              Text('Inicia sesión'),
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
                backgroundColor: const Color(0xFF0D9488),
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
        ? 'Hola, vi tu reporte en PawCo sobre ${report.petName} (${report.species} en ${report.neighborhood}, ${report.municipality}) y quiero brindarte información.'
        : 'Hola, vi en PawCo que avistaron o encontraron a ${report.petName} (${report.species} en ${report.neighborhood}, ${report.municipality}) y quisiera consultar información.';

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
            Icon(Icons.celebration, color: Color(0xFF0D9488)),
            SizedBox(width: 8),
            Text('¡Ya apareció! 🎉'),
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
              backgroundColor: const Color(0xFF0D9488),
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
            Icon(Icons.flag_rounded, color: Color(0xFFE11D48)),
            SizedBox(width: 8),
            Text('Reportar Publicación'),
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
              backgroundColor: const Color(0xFFE11D48),
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
          'Gracias por tu reporte. El equipo de PawCo revisará esta publicación.',
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
