import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme.dart';
import '../../../core/presentation/pawco_design_system.dart';
import '../domain/directory_entry.dart';
import '../domain/donation_campaign.dart';

/// Centro geográfico del Área Metropolitana de Bucaramanga para el mapa
const _bucaramangaCenter = LatLng(7.1193, -73.1227);

/// Página de Fundaciones Aliadas, Metas de Donación con Causa y Voluntariado
class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  static const String wompiLink = 'https://checkout.wompi.co/l/IMjZp7';

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  // Sección 1: Filtro de Metas
  String _selectedCampaignCategory = 'Todas';

  // Sección 2: Donación directa
  int _donationFrequency = 0; // 0: Única vez, 1: Mensual (Padrino)
  int? _selectedPresetAmount = 120000;
  final TextEditingController _customAmountController = TextEditingController();
  bool _isCustomAmount = false;
  String _selectedFoundationBeneficiary =
      'Todas las fundaciones del AMB (Donde más se necesite)';

  // Sección 3: Directorio y Mapa
  int _directoryViewMode = 0; // 0: Vista Lista, 1: Vista Mapa
  String _selectedDirectoryCategory = 'Todos';
  String _selectedMunicipality = 'Todo AMB';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final MapController _mapController = MapController();
  DirectoryEntry? _selectedMapEntry;

  static const List<Map<String, dynamic>> _presetDonationAmounts = [
    {
      'amount': 20000,
      'label': '\$20.000',
      'impact': 'Cubre 3 días de alimento para un rescatado',
      'icon': Icons.rice_bowl_outlined,
    },
    {
      'amount': 50000,
      'label': '\$50.000',
      'impact': 'Aporta a consulta médica y desparasitación',
      'icon': Icons.medical_services_outlined,
    },
    {
      'amount': 120000,
      'label': '\$120.000',
      'impact': 'Compra 1 bulto completo de concentrado (25kg)',
      'icon': Icons.inventory_2_outlined,
    },
    {
      'amount': 200000,
      'label': '\$200.000',
      'impact': 'Cubre 1 día de hospitalización veterinaria',
      'icon': Icons.local_hospital_outlined,
    },
    {
      'amount': 350000,
      'label': '\$350.000',
      'impact': 'Apadrina un rescate completo por un mes',
      'icon': Icons.favorite_outline,
    },
  ];

  static const List<String> _foundationOptions = [
    'Todas las fundaciones del AMB (Donde más se necesite)',
    'Fundación Corazón Animal (Bucaramanga)',
    'Refugio Huellitas Felices (Girón)',
    'Fundación Amor Callejero (Piedecuesta)',
    'Fundación Adopta un Amigo (Floridablanca)',
    'Fondo de Cirugías y Urgencias 24/7',
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
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _launchExternalUrl(String url, String errorMessage) async {
    final uri = Uri.parse(url);
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    await _launchExternalUrl(phoneUrl, 'No se pudo iniciar la llamada.');
  }

  Future<void> _openWhatsApp(String whatsappUrl) async {
    await _launchExternalUrl(whatsappUrl, 'No se pudo abrir WhatsApp.');
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

  List<DonationCampaign> _filterCampaigns(List<DonationCampaign> all) {
    if (_selectedCampaignCategory == 'Todas') return all;
    return all.where((c) {
      if (_selectedCampaignCategory.contains('Comida')) {
        return c.category == CampaignCategory.foodBags;
      }
      if (_selectedCampaignCategory.contains('Hospitalización')) {
        return c.category == CampaignCategory.hospitalizationSurgery;
      }
      if (_selectedCampaignCategory.contains('Esterilización')) {
        return c.category == CampaignCategory.sterilization;
      }
      return c.category == _selectedCampaignCategory;
    }).toList();
  }

  List<DirectoryEntry> _filterDirectory(List<DirectoryEntry> all) {
    return all.where((entry) {
      if (_selectedDirectoryCategory != 'Todos') {
        if (_selectedDirectoryCategory == 'Veterinarias 24/7' ||
            _selectedDirectoryCategory == 'Urgencias 24/7') {
          if (!entry.is24Hours &&
              entry.category != DirectoryCategory.veterinary24h) {
            return false;
          }
        } else if (_selectedDirectoryCategory == 'Fundaciones') {
          if (entry.category != DirectoryCategory.foundation) return false;
        } else if (_selectedDirectoryCategory == 'Líneas Oficiales') {
          if (entry.category != DirectoryCategory.emergencyLine) return false;
        } else if (_selectedDirectoryCategory == 'Bienestar') {
          if (entry.category != DirectoryCategory.welfare) return false;
        }
      }

      if (_selectedMunicipality != 'Todo AMB') {
        if (entry.municipality != _selectedMunicipality &&
            entry.municipality != DirectoryMunicipality.metropolitana) {
          return false;
        }
      }

      if (_searchQuery.isNotEmpty) {
        final matchName = entry.name.toLowerCase().contains(_searchQuery);
        final matchDesc =
            entry.description.toLowerCase().contains(_searchQuery);
        final matchAddr = entry.address.toLowerCase().contains(_searchQuery);
        final matchNeigh =
            (entry.neighborhood ?? '').toLowerCase().contains(_searchQuery);
        final matchMun =
            entry.municipality.toLowerCase().contains(_searchQuery);
        if (!matchName &&
            !matchDesc &&
            !matchAddr &&
            !matchNeigh &&
            !matchMun) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isMobileShell = screenWidth < 860;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===============================================================
            // HERO AURORA HÍBRIDA + ESCUDO VECTORIAL DE TRANSPARENCIA 100%
            // ===============================================================
            PawColAuroraWaveHeader(
              contentPadding: EdgeInsets.fromLTRB(
                isDesktop ? 32 : 16,
                MediaQuery.of(context).padding.top + (isDesktop ? 24 : 16),
                isDesktop ? 32 : 16,
                18,
              ),
              waveHeight: 54,
              child: _buildAuroraHeaderContent(context, isDesktop),
            ),

            // ===============================================================
            // ZONA MARFIL-LILA PASTEL (#FAF6F9): METAS, WOMPI Y DIRECTORIO
            // ===============================================================
            Padding(
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
                      // SECCIÓN 1: METAS DE ALIMENTO, HOSPITALIZACIÓN Y CIRUGÍA
                      _buildVerifiedCausesSection(
                        context,
                        isDesktop,
                        screenWidth,
                      ),
                      const SizedBox(height: 38),

                      // SECCIÓN 2: DONACIÓN DIRECTA CON PROPÓSITO
                      _buildDirectDonationSection(context, screenWidth),
                      const SizedBox(height: 38),

                      // SECCIÓN 3: FUNDACIONES Y DIRECTORIO 24/7
                      _buildFoundationsDirectorySection(context, isDesktop),
                      SizedBox(height: isMobileShell ? 120 : 64),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // CABECERA AURORA VIOLETA 2
  // ===========================================================================
  Widget _buildAuroraHeaderContent(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    Icons.volunteer_activism_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'PawCol Donaciones',
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
                onTap: () => _showDonationQrModal(context, null),
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
                        Icons.qr_code_2_rounded,
                        size: 17,
                        color: PawCoColors.lilacGlow,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'QR Directo',
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
                        color: PawCoColors.amberGlow.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      '✨ TRANSPARENCIA Y SOLIDARIDAD SANTANDER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: PawCoColors.amberGlow,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  PawColGradientText(
                    'Apoya Nuestras Causas y Alianzas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isDesktop ? 34 : 25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cada aporte transforma el destino de un animal rescatado en Bucaramanga, Floridablanca, Girón y Piedecuesta. Metas verificadas con facturas y alianzas con refugios.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      color: Colors.white.withValues(alpha: 0.84),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  PawColRealBadgeButton(
                    label: 'Aportar Bultos de Concentrado',
                    onTap: _openWompi,
                  ),
                ],
              ),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 24),
              SvgPicture.asset(
                'assets/vectors/pawcol_shield.svg',
                width: 118,
                height: 118,
                fit: BoxFit.contain,
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // SECCIÓN 1: METAS DE ALIMENTO, HOSPITALIZACIÓN Y CIRUGÍA
  // ===========================================================================
  Widget _buildVerifiedCausesSection(
    BuildContext context,
    bool isDesktop,
    double screenWidth,
  ) {
    final filteredCampaigns =
        _filterCampaigns(DonationCampaign.activeCampaigns);

    final filterOptions = [
      'Todas',
      '🥣 Bultos de Comida',
      '🏥 Hospitalización Mascotas',
      '✂️ Esterilización',
    ];

    final mobileCardWidth =
        math.min(316.0, math.max(260.0, screenWidth - 40.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apoya Nuestras Causas Verificadas',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: PawCoColors.ink,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Campañas activas con metas claras, facturas auditadas y seguimiento público',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: PawCoColors.muted,
          ),
        ),
        const SizedBox(height: 14),

        // Filtro de categorías
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filterOptions.map((opt) {
              final isSelected = _selectedCampaignCategory == opt;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    opt,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color:
                          isSelected ? Colors.white : PawCoColors.inkSecondary,
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
                    ),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedCampaignCategory = opt;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        if (isDesktop)
          PawCoResponsiveGrid(
            maxWidth: 1200,
            children: List.generate(filteredCampaigns.length, (i) {
              return PawCoFadeSlide(
                delay: Duration(milliseconds: i * 50),
                child: _buildCampaignCard(context, filteredCampaigns[i]),
              );
            }),
          )
        else
          SizedBox(
            height: 452,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: filteredCampaigns.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: mobileCardWidth,
                  child: _buildCampaignCard(context, filteredCampaigns[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCampaignCard(BuildContext context, DonationCampaign campaign) {
    return PawCoHoverCard(
      borderRadius: 22,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: SizedBox(
                  height: 158,
                  width: double.infinity,
                  child: Image.network(
                    campaign.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: PawCoColors.cottonLilac,
                      child: const Center(
                        child: Icon(
                          Icons.pets_rounded,
                          size: 48,
                          color: PawCoColors.plum,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PawCoBadge(
                    label: campaign.category,
                    backgroundColor: Colors.white.withValues(alpha: 0.94),
                    textColor: PawCoColors.plum,
                    fontSize: 10.5,
                  ),
                ),
              ),
              if (campaign.verifiedInvoiceCode != null)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: PawCoColors.auroraStart.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: PawCoColors.lilacGlow.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 12,
                          color: PawCoColors.amberGlow,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Factura #${campaign.verifiedInvoiceCode}',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: PawCoColors.malva,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${campaign.municipality} • ${campaign.foundationName}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: PawCoColors.plum,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  campaign.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: PawCoColors.ink,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  campaign.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: PawCoColors.muted,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                PawCoAnimatedProgressBar(
                  value: campaign.progressRatio,
                  height: 9,
                  progressColor: PawCoColors.malva,
                  backgroundColor: PawCoColors.cottonLilac,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${campaign.progressPercentage}% de ${campaign.formattedTargetShort}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: PawCoColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${campaign.daysLeft} días',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: PawCoColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PawCoColors.malva,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.favorite_rounded, size: 16),
                    label: Text(
                      'Donar a esta meta',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () =>
                        _showCampaignDonationModal(context, campaign),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECCIÓN 2: DONACIÓN DIRECTA CON PROPÓSITO
  // ===========================================================================
  Widget _buildDirectDonationSection(BuildContext context, double screenWidth) {
    final isCompact = screenWidth < 390;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 16 : 24),
      decoration: BoxDecoration(
        color: PawCoColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: PawCoColors.border),
        boxShadow: [
          BoxShadow(
            color: PawCoColors.plum.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Donación Directa con Propósito',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: PawCoColors.ink,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Elige el impacto directo que deseas generar en la salud y alimentación animal',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: PawCoColors.muted,
            ),
          ),
          const SizedBox(height: 16),

          // Selector de Frecuencia adaptable incluso a 320px
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: PawCoColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PawCoColors.border),
              ),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  _buildFrequencyTab(
                    0,
                    'Única vez',
                    Icons.card_giftcard_rounded,
                  ),
                  _buildFrequencyTab(
                    1,
                    'Mensual (Padrino)',
                    Icons.all_inclusive_rounded,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Grid de montos predefinidos
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isWide = width >= 650;
              final cardWidth = isWide ? (width - 16) / 2 : width;

              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  ..._presetDonationAmounts.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final int amount = item['amount'] as int;
                    final bool isSelected =
                        !_isCustomAmount && _selectedPresetAmount == amount;
                    final useMalva = idx.isOdd;

                    return SizedBox(
                      width: cardWidth,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPresetAmount = amount;
                            _isCustomAmount = false;
                            _customAmountController.clear();
                          });
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? PawCoColors.sageMuted
                                : PawCoColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? PawCoColors.plum
                                  : PawCoColors.border,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? PawCoColors.plum
                                      : (useMalva
                                          ? PawCoColors.softMalva
                                          : PawCoColors.cottonLilac),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  size: 20,
                                  color: isSelected
                                      ? Colors.white
                                      : (useMalva
                                          ? PawCoColors.terracottaDark
                                          : PawCoColors.plum),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['label'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: PawCoColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['impact'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: isSelected
                                            ? PawCoColors.plum
                                            : PawCoColors.muted,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: PawCoColors.malva,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Tarjeta personalizada: "$ Otro monto libre"
                  SizedBox(
                    width: cardWidth,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isCustomAmount = true;
                          _selectedPresetAmount = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _isCustomAmount
                              ? PawCoColors.sageMuted
                              : PawCoColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _isCustomAmount
                                ? PawCoColors.plum
                                : PawCoColors.border,
                            width: _isCustomAmount ? 2.0 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _isCustomAmount
                                    ? PawCoColors.plum
                                    : PawCoColors.softMalva,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: _isCustomAmount
                                    ? Colors.white
                                    : PawCoColors.terracottaDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _isCustomAmount
                                  ? TextField(
                                      controller: _customAmountController,
                                      keyboardType: TextInputType.number,
                                      autofocus: true,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 4),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        hintText: 'Ingresa valor en COP...',
                                        prefixText: '\$ ',
                                      ),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: PawCoColors.ink,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    )
                                  : Text(
                                      '\$ Otro monto libre',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: PawCoColors.ink,
                                      ),
                                    ),
                            ),
                            if (_isCustomAmount)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: PawCoColors.malva,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          Text(
            '¿A qué fundación o causa deseas destinar tu aporte?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: PawCoColors.inkSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: PawCoColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PawCoColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFoundationBeneficiary,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: PawCoColors.plum,
                ),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: PawCoColors.ink,
                  fontWeight: FontWeight.w600,
                ),
                items: _foundationOptions.map((opt) {
                  return DropdownMenuItem(
                    value: opt,
                    child: Text(opt, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedFoundationBeneficiary = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Botones Wompi + QR adaptables a 320px
          LayoutBuilder(
            builder: (context, constraints) {
              final stackButtons = constraints.maxWidth < 440;

              final wompiBtn = SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PawCoColors.plum,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(
                    'Donar Ahora con Wompi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: _openWompi,
                ),
              );

              final qrBtn = SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PawCoColors.plum,
                    side: const BorderSide(
                      color: PawCoColors.plum,
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                  label: Text(
                    'Ver QR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () => _showDonationQrModal(context, null),
                ),
              );

              if (stackButtons) {
                return Column(
                  children: [
                    wompiBtn,
                    const SizedBox(height: 10),
                    qrBtn,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 7, child: wompiBtn),
                  const SizedBox(width: 12),
                  Expanded(flex: 4, child: qrBtn),
                ],
              );
            },
          ),
          const SizedBox(height: 10),

          Center(
            child: TextButton.icon(
              icon: const Icon(
                Icons.copy_rounded,
                size: 15,
                color: PawCoColors.muted,
              ),
              label: Text(
                'Copiar enlace directo de pasarela Wompi',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: PawCoColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => _copyToClipboard(
                DonationsPage.wompiLink,
                'Enlace Wompi copiado al portapapeles 📋',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyTab(int index, String title, IconData icon) {
    final isSelected = _donationFrequency == index;
    return InkWell(
      onTap: () => setState(() => _donationFrequency = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? PawCoColors.plum : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : PawCoColors.muted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : PawCoColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SECCIÓN 3: FUNDACIONES Y DIRECTORIO 24/7
  // ===========================================================================
  Widget _buildFoundationsDirectorySection(
    BuildContext context,
    bool isDesktop,
  ) {
    final filtered = _filterDirectory(DirectoryEntry.curatedEntries);

    final categories = [
      'Todos',
      'Veterinarias 24/7',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fundaciones Aliadas y Directorio 24/7',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: PawCoColors.ink,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Centros veterinarios, albergues de rescate y líneas oficiales en Bucaramanga y AMB',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: PawCoColors.muted,
          ),
        ),
        const SizedBox(height: 16),

        // Buscador + Selector Lista/Mapa adaptable desde 320px
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 430;
            final searchBox = Container(
              decoration: BoxDecoration(
                color: PawCoColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PawCoColors.border),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar clínica, albergue, barrio...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: PawCoColors.mutedLight,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: PawCoColors.plum,
                  ),
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

            final viewSwitcher = Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: PawCoColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PawCoColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildViewModeButton(
                    0,
                    Icons.format_list_bulleted_rounded,
                    'Lista',
                  ),
                  _buildViewModeButton(1, Icons.map_outlined, 'Mapa'),
                ],
              ),
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  searchBox,
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: viewSwitcher,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: searchBox),
                const SizedBox(width: 12),
                viewSwitcher,
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedDirectoryCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(
                    cat,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? PawCoColors.plum
                          : PawCoColors.inkSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: PawCoColors.cottonLilac,
                  backgroundColor: PawCoColors.surface,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? PawCoColors.sage : PawCoColors.border,
                    ),
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedDirectoryCategory = cat),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: municipalities.map((muni) {
              final isSelected = _selectedMunicipality == muni;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(
                    muni == 'Todo AMB' ? '📍 Todo AMB' : muni,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color:
                          isSelected ? Colors.white : PawCoColors.inkSecondary,
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
                    ),
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedMunicipality = muni),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        _directoryViewMode == 0
            ? _buildDirectoryList(filtered, isDesktop)
            : _buildDirectoryMap(filtered),
      ],
    );
  }

  Widget _buildViewModeButton(int index, IconData icon, String label) {
    final isSelected = _directoryViewMode == index;
    return InkWell(
      onTap: () => setState(() => _directoryViewMode = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? PawCoColors.plum : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : PawCoColors.muted,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : PawCoColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryList(List<DirectoryEntry> entries, bool isDesktop) {
    if (entries.isEmpty) {
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
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: PawCoColors.mutedLight,
            ),
            const SizedBox(height: 12),
            Text(
              'No se encontraron entidades con estos filtros',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: PawCoColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Prueba seleccionando otro municipio o término de búsqueda',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: PawCoColors.muted,
              ),
            ),
          ],
        ),
      );
    }

    if (isDesktop) {
      return PawCoResponsiveGrid(
        maxWidth: 1200,
        children: entries.map((entry) => _buildDirectoryCard(entry)).toList(),
      );
    }

    return Column(
      children: entries.map((entry) => _buildDirectoryCard(entry)).toList(),
    );
  }

  Widget _buildDirectoryCard(DirectoryEntry entry) {
    final isFoundation = entry.category == DirectoryCategory.foundation;

    return PawCoHoverCard(
      borderRadius: 20,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isFoundation
                      ? PawCoColors.softMalva
                      : entry.is24Hours
                          ? PawCoColors.cottonLilac
                          : PawCoColors.slateBlueLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFoundation
                      ? Icons.volunteer_activism_rounded
                      : entry.is24Hours
                          ? Icons.local_hospital_rounded
                          : Icons.shield_outlined,
                  color: isFoundation
                      ? PawCoColors.terracottaDark
                      : entry.is24Hours
                          ? PawCoColors.plum
                          : PawCoColors.slateBlue,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: PawCoColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '📍 ${entry.municipality}${entry.neighborhood != null ? " • ${entry.neighborhood}" : ""}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PawCoColors.plum,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (entry.is24Hours)
            const PawCoBadge(
              label: '24 HORAS',
              icon: Icons.access_time_filled,
              backgroundColor: Color(0xFFDCFCE7),
              textColor: Color(0xFF15803D),
              fontSize: 10,
            )
          else if (isFoundation)
            const PawCoBadge(
              label: 'VOLUNTARIOS',
              icon: Icons.favorite,
              backgroundColor: PawCoColors.softMalva,
              textColor: PawCoColors.terracottaDark,
              fontSize: 10,
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 14,
                color: PawCoColors.muted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  entry.address,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: PawCoColors.inkSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: PawCoColors.muted,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),

          // Botones de acción adaptables a 320px
          LayoutBuilder(
            builder: (context, constraints) {
              final stackActions = isFoundation && constraints.maxWidth < 310;
              final contactBtn = OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: PawCoColors.plum,
                  side: const BorderSide(color: PawCoColors.plum),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                ),
                icon: const Icon(Icons.info_outline_rounded, size: 16),
                label: Text(
                  'Ver / Contactar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () => _showEntryDetailsModal(context, entry),
              );

              if (!isFoundation) {
                return SizedBox(width: double.infinity, child: contactBtn);
              }

              final volunteerBtn = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawCoColors.malva,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                ),
                icon: const Icon(Icons.volunteer_activism_rounded, size: 16),
                label: Text(
                  'Ser Voluntario',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () => _showVolunteerModal(context, entry),
              );

              if (stackActions) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    contactBtn,
                    const SizedBox(height: 8),
                    volunteerBtn,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: contactBtn),
                  const SizedBox(width: 8),
                  Expanded(child: volunteerBtn),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryMap(List<DirectoryEntry> entries) {
    return Container(
      height: 460,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PawCoColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _bucaramangaCenter,
              initialZoom: 12.5,
              minZoom: 9.0,
              maxZoom: 18.0,
              onTap: (_, __) {
                setState(() => _selectedMapEntry = null);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'co.pawco.app',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: entries.where((e) => e.hasCoordinates).map((entry) {
                  final isSelected = _selectedMapEntry?.id == entry.id;
                  final isFoundation =
                      entry.category == DirectoryCategory.foundation;
                  final pinColor = isFoundation
                      ? PawCoColors.malva
                      : entry.is24Hours
                          ? PawCoColors.plum
                          : PawCoColors.slateBlue;

                  return Marker(
                    point: LatLng(entry.latitude!, entry.longitude!),
                    width: isSelected ? 52 : 42,
                    height: isSelected ? 52 : 42,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedMapEntry = entry);
                        _mapController.move(
                          LatLng(entry.latitude!, entry.longitude!),
                          14.5,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: pinColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isFoundation
                                ? Icons.volunteer_activism_rounded
                                : entry.is24Hours
                                    ? Icons.local_hospital_rounded
                                    : Icons.shield_rounded,
                            color: Colors.white,
                            size: isSelected ? 24 : 18,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          if (_selectedMapEntry != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedMapEntry!.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: PawCoColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_selectedMapEntry!.municipality} • ${_selectedMapEntry!.address}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: PawCoColors.muted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.phone_rounded,
                          color: PawCoColors.plum,
                        ),
                        onPressed: () => _callPhone(_selectedMapEntry!.telUrl),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chat_rounded,
                          color: Color(0xFF25D366),
                        ),
                        onPressed: () =>
                            _openWhatsApp(_selectedMapEntry!.whatsappUrl),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () =>
                            setState(() => _selectedMapEntry = null),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MODALES: QR, DETALLES Y VOLUNTARIADO
  // ===========================================================================
  void _showDonationQrModal(BuildContext context, DonationCampaign? campaign) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PawCoColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  campaign != null
                      ? 'Aporte a Meta Auditada'
                      : 'Donación Directa PawCol',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: PawCoColors.ink,
                  ),
                ),
                if (campaign != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    campaign.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: PawCoColors.muted,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PawCoColors.border, width: 2),
                  ),
                  child: QrImageView(
                    data: DonationsPage.wompiLink,
                    size: 200,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Escanea desde tu app bancaria (Bancolombia, Nequi, Daviplata o PSE) o usa el botón directo:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: PawCoColors.muted,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PawCoColors.plum,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(
                      'Pagar en línea con Wompi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _openWompi();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copiar enlace de Wompi'),
                  onPressed: () {
                    _copyToClipboard(
                      DonationsPage.wompiLink,
                      'Enlace copiado al portapapeles 📋',
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCampaignDonationModal(
    BuildContext context,
    DonationCampaign campaign,
  ) {
    _showDonationQrModal(context, campaign);
  }

  void _showEntryDetailsModal(BuildContext context, DirectoryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PawCoColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  entry.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: PawCoColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: PawCoColors.malva,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${entry.municipality} • ${entry.neighborhood ?? ""}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: PawCoColors.plum,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  entry.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: PawCoColors.muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (entry.openHours != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: PawCoColors.inkSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry.openHours!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: PawCoColors.inkSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PawCoColors.plum,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.call_rounded, size: 18),
                        label: const Text('Llamar'),
                        onPressed: () => _callPhone(entry.telUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                        label: const Text('WhatsApp'),
                        onPressed: () => _openWhatsApp(entry.whatsappUrl),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVolunteerModal(BuildContext context, DirectoryEntry entry) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: PawCoColors.softMalva,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volunteer_activism_rounded,
                    size: 36,
                    color: PawCoColors.malva,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Voluntariado en ${entry.name}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: PawCoColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¡Tu tiempo y cariño marcan la diferencia! Puedes apoyar en jornadas de baño, paseo, alimentación o difusión de casos de adopción.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: PawCoColors.muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.chat_rounded),
                    label: Text(
                      'Contactar por WhatsApp',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      final url =
                          'https://wa.me/${entry.cleanWhatsapp.startsWith("57") ? entry.cleanWhatsapp : "57${entry.cleanWhatsapp}"}?text=Hola%20${Uri.encodeComponent(entry.name)},%20deseo%20postularme%20como%20voluntario%20a%20través%20de%20la%20comunidad%20PawCol%20🐾';
                      _openWhatsApp(url);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
