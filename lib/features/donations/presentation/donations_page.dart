import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/directory_entry.dart';

class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  static const String wompiLink = 'https://checkout.wompi.co/l/IMjZp7';

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  int _selectedView = 0; // 0: Directorio 24/7, 1: Donaciones Wompi

  // Filtros del Directorio
  String _selectedCategory = 'Todos';
  String _selectedMunicipality = 'Todo AMB';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  Future<void> _launchExternalUrl(String url, String errorMessage) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  Future<void> _openWompi() async {
    await _launchExternalUrl(
      DonationsPage.wompiLink,
      'No se pudo abrir la pasarela de donación Wompi.',
    );
  }

  Future<void> _callPhone(String phoneUrl) async {
    await _launchExternalUrl(
      phoneUrl,
      'No se pudo iniciar la llamada telefónica.',
    );
  }

  Future<void> _openWhatsApp(String whatsappUrl) async {
    await _launchExternalUrl(
      whatsappUrl,
      'No se pudo abrir WhatsApp.',
    );
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<DirectoryEntry> _filterEntries(List<DirectoryEntry> all) {
    return all.where((entry) {
      // Filtro por categoría
      if (_selectedCategory != 'Todos') {
        if (_selectedCategory == 'Urgencias 24/7') {
          if (!entry.is24Hours && entry.category != DirectoryCategory.veterinary24h) {
            return false;
          }
        } else if (_selectedCategory == 'Fundaciones') {
          if (entry.category != DirectoryCategory.foundation) return false;
        } else if (_selectedCategory == 'Líneas Oficiales') {
          if (entry.category != DirectoryCategory.emergencyLine) return false;
        } else if (_selectedCategory == 'Bienestar') {
          if (entry.category != DirectoryCategory.welfare) return false;
        } else if (entry.category != _selectedCategory) {
          return false;
        }
      }

      // Filtro por municipio
      if (_selectedMunicipality != 'Todo AMB') {
        if (entry.municipality != _selectedMunicipality &&
            entry.municipality != DirectoryMunicipality.metropolitana) {
          return false;
        }
      }

      // Filtro por búsqueda de texto
      if (_searchQuery.isNotEmpty) {
        final matchName = entry.name.toLowerCase().contains(_searchQuery);
        final matchDesc = entry.description.toLowerCase().contains(_searchQuery);
        final matchAddr = entry.address.toLowerCase().contains(_searchQuery);
        final matchNeigh = (entry.neighborhood ?? '').toLowerCase().contains(_searchQuery);
        final matchMun = entry.municipality.toLowerCase().contains(_searchQuery);
        if (!matchName && !matchDesc && !matchAddr && !matchNeigh && !matchMun) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              '💚 PawCo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Text(
              'Ayuda & Directorio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Conmutador superior estilo Segmented Control
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Theme.of(context).cardColor,
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment<int>(
                    value: 0,
                    icon: Icon(Icons.local_hospital_outlined),
                    label: Text('Directorio 24/7 (AMB)'),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    icon: Icon(Icons.favorite_outline),
                    label: Text('Donaciones Wompi'),
                  ),
                ],
                selected: {_selectedView},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedView = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.comfortable,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // Contenido conmutado
          Expanded(
            child: _selectedView == 0
                ? _buildDirectoryView(context)
                : _buildDonationsView(context),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // VISTA 1: DIRECTORIO 24/7 Y ENTIDADES DEL ÁREA METROPOLITANA
  // ===========================================================================
  Widget _buildDirectoryView(BuildContext context) {
    final filtered = _filterEntries(DirectoryEntry.curatedEntries);

    final categories = [
      'Todos',
      'Urgencias 24/7',
      'Fundaciones',
      'Líneas Oficiales',
      'Bienestar',
    ];

    final municipalities = [
      'Todo AMB',
      DirectoryMunicipality.bucaramanga,
      DirectoryMunicipality.floridablanca,
      DirectoryMunicipality.giron,
      DirectoryMunicipality.piedecuesta,
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Banner introductorio
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE6FFFA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF99F6E4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D9488),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Red de Atención Inmediata en Bucaramanga',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Veterinarias con urgencias nocturnas, refugios y líneas oficiales de rescate en el Área Metropolitana.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF134E4A),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Barra de búsqueda por texto
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, barrio o servicio...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF0D9488)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        const SizedBox(height: 14),

        // Filtro por Municipio
        const Text(
          'Municipio:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: municipalities.map((mun) {
              final isSelected = _selectedMunicipality == mun;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(mun == 'Todo AMB' ? '📍 $mun' : mun),
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
        const SizedBox(height: 10),

        // Filtro por Categoría
        const Text(
          'Categoría:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat),
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
                      _selectedCategory = cat;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Contador de resultados
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${filtered.length} ${filtered.length == 1 ? "entidad disponible" : "entidades disponibles"}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            if (_selectedCategory != 'Todos' ||
                _selectedMunicipality != 'Todo AMB' ||
                _searchQuery.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'Todos';
                    _selectedMunicipality = 'Todo AMB';
                    _searchController.clear();
                  });
                },
                child: const Text('Limpiar filtros', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Lista de Entidades
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Icon(Icons.search_off, size: 48, color: Color(0xFF94A3B8)),
                const SizedBox(height: 12),
                const Text(
                  'No encontramos resultados para tu búsqueda',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Intenta cambiar el municipio o la categoría seleccionada.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'Todos';
                      _selectedMunicipality = 'Todo AMB';
                      _searchController.clear();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Mostrar todas'),
                ),
              ],
            ),
          )
        else
          ...filtered.map((entry) => _buildEntryCard(context, entry)),
      ],
    );
  }

  Widget _buildEntryCard(BuildContext context, DirectoryEntry entry) {
    Color categoryBg;
    Color categoryFg;

    switch (entry.category) {
      case DirectoryCategory.veterinary24h:
        categoryBg = const Color(0xFFE0F2FE);
        categoryFg = const Color(0xFF0369A1);
        break;
      case DirectoryCategory.foundation:
        categoryBg = const Color(0xFFFEF3C7);
        categoryFg = const Color(0xFFB45309);
        break;
      case DirectoryCategory.emergencyLine:
        categoryBg = const Color(0xFFFFE4E6);
        categoryFg = const Color(0xFFBE123C);
        break;
      case DirectoryCategory.welfare:
      default:
        categoryBg = const Color(0xFFCCFBF1);
        categoryFg = const Color(0xFF0F766E);
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Categoría + Badges (24H, Municipio)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: categoryBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          entry.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: categoryFg,
                          ),
                        ),
                      ),
                      if (entry.is24Hours)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time_filled, size: 12, color: Color(0xFF15803D)),
                              SizedBox(width: 3),
                              Text(
                                '24 HORAS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '📍 ${entry.municipality}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Nombre de la entidad
            Text(
              entry.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),

            // Barrio y Dirección con botón de copiar
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 15, color: Color(0xFF0D9488)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${entry.neighborhood != null ? "${entry.neighborhood!} • " : ""}${entry.address}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: Color(0xFF64748B)),
                  tooltip: 'Copiar dirección',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _copyToClipboard(
                    '${entry.name} - ${entry.address}, ${entry.municipality}',
                    'Dirección copiada al portapapeles 📋',
                  ),
                ),
              ],
            ),

            if (entry.openHours != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    entry.openHours!,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),
            // Descripción
            Text(
              entry.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),

            // Botones de acción rápida
            Row(
              children: [
                // Botón Llamar
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.phone, size: 16),
                    label: Text(
                      'Llamar (${entry.phone})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => _callPhone(entry.telUrl),
                  ),
                ),
                const SizedBox(width: 8),

                // Botón WhatsApp (si aplica)
                if (entry.whatsapp != null || entry.cleanWhatsapp.length >= 10)
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF16A34A),
                        side: const BorderSide(color: Color(0xFF86EFAC)),
                        backgroundColor: const Color(0xFFF0FDF4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text(
                        'WhatsApp',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _openWhatsApp(entry.whatsappUrl),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // VISTA 2: DONACIONES Y APOYO SOLIDARIO (WOMPI + QR)
  // ===========================================================================
  Widget _buildDonationsView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFCCFBF1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism,
                  size: 44,
                  color: Color(0xFF0D9488),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Apoya la labor de PawCo 💚',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tus donaciones salvan vidas directamente en Santander. Financiamos cirugías veterinarias urgentes, alimentos para hogares de paso y jornadas de esterilización comunitaria.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),

              // Tarjeta de QR Wompi
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, color: Color(0xFF0D9488), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Escanea o toca para donar vía Wompi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _openWompi,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                          ),
                          child: QrImageView(
                            data: DonationsPage.wompiLink,
                            size: 210,
                            version: QrVersions.auto,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SelectableText(
                        DonationsPage.wompiLink,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botón donar con Wompi
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text(
                    'Donar en línea con Wompi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _openWompi,
                ),
              ),

              const SizedBox(height: 10),
              TextButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copiar enlace directo de donación'),
                onPressed: () => _copyToClipboard(
                  DonationsPage.wompiLink,
                  'Enlace Wompi copiado al portapapeles 📋',
                ),
              ),

              const SizedBox(height: 24),

              // Tarjetas explicativas de impacto
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '¿A dónde van tus aportes?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildImpactItem(
                icon: Icons.emergency,
                iconColor: const Color(0xFFE11D48),
                bgColor: const Color(0xFFFFE4E6),
                title: 'Atención Médica Urgente',
                description:
                    'Cubrimos cirugías, exámenes y hospitalización para animales atropellados o maltratados rescatados en el AMB.',
              ),
              const SizedBox(height: 10),

              _buildImpactItem(
                icon: Icons.pets,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
                title: 'Alimento y Hogares de Paso',
                description:
                    'Compramos concentrado y vacunas para los peluditos en recuperación antes de ser entregados en adopción responsable.',
              ),
              const SizedBox(height: 10),

              _buildImpactItem(
                icon: Icons.medical_services_outlined,
                iconColor: const Color(0xFF0D9488),
                bgColor: const Color(0xFFCCFBF1),
                title: 'Jornadas de Esterilización',
                description:
                    'Frenamos la sobrepoblación y el abandono esterilizando hembras y machos en sectores vulnerables de Bucaramanga y Santander.',
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFF64748B), size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PawCo es una iniciativa comunitaria transparente y sin ánimo de lucro al servicio del bienestar animal en Colombia.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
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

  Widget _buildImpactItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
