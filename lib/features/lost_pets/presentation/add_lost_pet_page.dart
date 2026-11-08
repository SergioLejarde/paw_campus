import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme.dart';
import '../../../core/presentation/app_feedback.dart';
import '../../../core/presentation/pawco_design_system.dart';
import '../data/lost_pets_repository.dart';

class AddLostPetPage extends ConsumerStatefulWidget {
  const AddLostPetPage({super.key});

  @override
  ConsumerState<AddLostPetPage> createState() => _AddLostPetPageState();
}

class _AddLostPetPageState extends ConsumerState<AddLostPetPage> {
  final _formKey = GlobalKey<FormState>();

  String _reportType = 'lost';

  final _nameController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedSpecies = 'Perro';
  String _selectedMunicipality = 'Bucaramanga';

  LatLng _pinLocation = const LatLng(7.1193, -73.1227);
  final MapController _miniMapController = MapController();

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user?.phone != null && user!.phone!.isNotEmpty) {
        _contactPhoneController.text = user.phone!;
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _neighborhoodController.dispose();
    _contactPhoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onMunicipalityChanged(String? newMuni) {
    if (newMuni == null) return;
    setState(() {
      _selectedMunicipality = newMuni;

      final newCenter = switch (newMuni.toLowerCase()) {
        'bucaramanga' => const LatLng(7.1193, -73.1227),
        'floridablanca' => const LatLng(7.0622, -73.0864),
        'girón' || 'giron' => const LatLng(7.0684, -73.1698),
        'piedecuesta' => const LatLng(6.9879, -73.0503),
        _ => const LatLng(7.1193, -73.1227),
      };

      _pinLocation = newCenter;
      _miniMapController.move(newCenter, 14.0);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedImage = file;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'No se pudo seleccionar la imagen: $e');
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      AppFeedback.showError(
        context,
        'Debes tener una sesión activa para publicar.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    AppFeedback.showLoadingDialog(
      context,
      message: 'Publicando alerta en tiempo real...',
    );

    try {
      final repo = ref.read(lostPetsRepositoryProvider);

      String? photoUrl;
      if (_selectedImage != null) {
        photoUrl = await repo.uploadLostPetPhoto(_selectedImage!);
      }

      final petName = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : (_reportType == 'lost' ? 'Mascota perdida' : 'Animalito avistado');

      final newReport = LostPetReport(
        id: 'lost_${DateTime.now().millisecondsSinceEpoch}',
        reportType: _reportType,
        petName: petName,
        species: _selectedSpecies,
        municipality: _selectedMunicipality,
        neighborhood: _neighborhoodController.text.trim(),
        description: _descriptionController.text.trim(),
        photoUrl: photoUrl,
        contactPhone: _contactPhoneController.text.trim(),
        latitude: _pinLocation.latitude,
        longitude: _pinLocation.longitude,
        status: 'active',
        createdBy: user.id,
        createdAt: DateTime.now(),
      );

      await repo.submitReport(newReport);
      ref.invalidate(activeLostPetsProvider);

      if (mounted) {
        AppFeedback.hideLoadingDialog(context);
        AppFeedback.showSuccess(
          context,
          '¡Alerta publicada con éxito! Ya está visible en el mapa y la lista.',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.hideLoadingDialog(context);
        AppFeedback.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLost = _reportType == 'lost';
    final accentColor = isLost ? PawCoColors.malva : const Color(0xFF059669);

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
                      context.go('/lost-pets');
                    }
                  },
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Publicar Alerta de Mascota',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimalSilhouetteBackground(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: PawCoColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: PawCoColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: PawCoColors.plum.withValues(alpha: 0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Qué deseas reportar?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: PawCoColors.ink,
                              ),
                            ),
                            const SizedBox(height: 10),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isNarrow = constraints.maxWidth < 360;
                                final opt1 = _buildTypeOption(
                                  title: 'Se me perdió mi mascota',
                                  subtitle: 'Alerta urgente de búsqueda',
                                  icon: Icons.search_rounded,
                                  typeValue: 'lost',
                                  activeColor: PawCoColors.malva,
                                );
                                final opt2 = _buildTypeOption(
                                  title: 'Vi o encontré un animalito',
                                  subtitle: 'Ayuda comunitaria',
                                  icon: Icons.visibility_rounded,
                                  typeValue: 'found',
                                  activeColor: const Color(0xFF059669),
                                );

                                if (isNarrow) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      opt1,
                                      const SizedBox(height: 10),
                                      opt2,
                                    ],
                                  );
                                }
                                return Row(
                                  children: [
                                    Expanded(child: opt1),
                                    const SizedBox(width: 12),
                                    Expanded(child: opt2),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 22),

                            Text(
                              isLost
                                  ? 'Nombre de tu mascota *'
                                  : 'Nombre o referencia del animalito',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: PawCoColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: isLost
                                    ? 'ej. Max, Luna, Toby'
                                    : 'ej. Perrito criollo sin collar, Gatita blanca',
                                prefixIcon: const Icon(
                                  Icons.pets_rounded,
                                  color: PawCoColors.plum,
                                ),
                              ),
                              validator: (val) {
                                if (isLost &&
                                    (val == null || val.trim().isEmpty)) {
                                  return 'Ingresa el nombre de la mascota perdida';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            Text(
                              'Especie *',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: PawCoColors.ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ['Perro', 'Gato', 'Otro'].map((species) {
                                final isSelected = _selectedSpecies == species;
                                return ChoiceChip(
                                  label: Text(species),
                                  selected: isSelected,
                                  selectedColor: PawCoColors.plum,
                                  backgroundColor: PawCoColors.surface,
                                  showCheckmark: false,
                                  labelStyle: GoogleFonts.plusJakartaSans(
                                    color: isSelected
                                        ? Colors.white
                                        : PawCoColors.inkSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedSpecies = species;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),

                            // Municipio y Barrio adaptables a 320px
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isNarrow = constraints.maxWidth < 380;
                                final muniColumn = Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Municipio *',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: PawCoColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _selectedMunicipality,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'Bucaramanga',
                                          child: Text(
                                            'Bucaramanga',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Floridablanca',
                                          child: Text(
                                            'Floridablanca',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Girón',
                                          child: Text(
                                            'Girón',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Piedecuesta',
                                          child: Text(
                                            'Piedecuesta',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Otro',
                                          child: Text(
                                            'Otro',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                      onChanged: _onMunicipalityChanged,
                                    ),
                                  ],
                                );

                                final neighColumn = Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Barrio / Sector *',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: PawCoColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _neighborhoodController,
                                      decoration: const InputDecoration(
                                        hintText: 'ej. Cabecera, Provenza',
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Ingresa el barrio';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                );

                                if (isNarrow) {
                                  return Column(
                                    children: [
                                      muniColumn,
                                      const SizedBox(height: 14),
                                      neighColumn,
                                    ],
                                  );
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: muniColumn),
                                    const SizedBox(width: 12),
                                    Expanded(child: neighColumn),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 18),

                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              alignment: WrapAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ubicación en el Mapa *',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: PawCoColors.ink,
                                  ),
                                ),
                                Text(
                                  '${_pinLocation.latitude.toStringAsFixed(4)}, ${_pinLocation.longitude.toStringAsFixed(4)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: PawCoColors.plum,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Toca en el mapa para situar el pin exacto donde se perdió o vio el animalito.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: PawCoColors.muted,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Container(
                              height: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: PawCoColors.border),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  FlutterMap(
                                    mapController: _miniMapController,
                                    options: MapOptions(
                                      initialCenter: _pinLocation,
                                      initialZoom: 14.0,
                                      minZoom: 9.0,
                                      maxZoom: 18.0,
                                      onTap: (_, point) {
                                        setState(() {
                                          _pinLocation = point;
                                        });
                                      },
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName: 'co.pawco.app',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: _pinLocation,
                                            width: 48,
                                            height: 48,
                                            child: Icon(
                                              Icons.location_pin,
                                              size: 48,
                                              color: accentColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.92),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Toca para reubicar pin',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: PawCoColors.ink,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            Text(
                              'Teléfono WhatsApp de Contacto *',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: PawCoColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _contactPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'ej. 3151234567',
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  color: PawCoColors.plum,
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Ingresa un número de WhatsApp para contacto';
                                }
                                final clean =
                                    val.replaceAll(RegExp(r'\D'), '');
                                if (clean.length < 10) {
                                  return 'Ingresa un número válido de al menos 10 dígitos';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            Text(
                              'Descripción detallada *',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: PawCoColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: isLost
                                    ? 'Describe señas particulares, collar, color de pelaje, tamaño...'
                                    : 'Describe cómo lo viste, estado de salud aparente, color, si lleva collar...',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().length < 10) {
                                  return 'Ingresa una descripción de al menos 10 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            Text(
                              'Foto de la mascota',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: PawCoColors.ink,
                              ),
                            ),
                            const SizedBox(height: 8),

                            if (_selectedImageBytes != null)
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.memory(
                                      _selectedImageBytes!,
                                      height: 190,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      radius: 18,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _selectedImage = null;
                                            _selectedImageBytes = null;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final stackBtns = constraints.maxWidth < 290;
                                  final galleryBtn = OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: PawCoColors.plum,
                                      side: const BorderSide(
                                        color: PawCoColors.border,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.photo_library_outlined,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Galería',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onPressed: () =>
                                        _pickImage(ImageSource.gallery),
                                  );
                                  final cameraBtn = OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: PawCoColors.plum,
                                      side: const BorderSide(
                                        color: PawCoColors.border,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Cámara',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onPressed: () =>
                                        _pickImage(ImageSource.camera),
                                  );
                                  if (stackBtns) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        galleryBtn,
                                        const SizedBox(height: 10),
                                        cameraBtn,
                                      ],
                                    );
                                  }
                                  return Row(
                                    children: [
                                      Expanded(child: galleryBtn),
                                      const SizedBox(width: 12),
                                      Expanded(child: cameraBtn),
                                    ],
                                  );
                                },
                              ),
                            const SizedBox(height: 28),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PawCoColors.plum,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                ),
                                icon: const Icon(Icons.send_rounded, size: 19),
                                label: Text(
                                  isLost
                                      ? 'Publicar Búsqueda de Mascota'
                                      : 'Publicar Avistamiento',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onPressed:
                                    _isSubmitting ? null : _handleSubmit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String typeValue,
    required Color activeColor,
  }) {
    final isSelected = _reportType == typeValue;

    return InkWell(
      onTap: () {
        setState(() {
          _reportType = typeValue;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.10)
              : PawCoColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : PawCoColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : PawCoColors.plum,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected ? activeColor : PawCoColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: PawCoColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
