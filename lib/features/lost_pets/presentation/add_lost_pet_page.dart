import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/presentation/app_feedback.dart';
import '../data/lost_pets_repository.dart';

class AddLostPetPage extends ConsumerStatefulWidget {
  const AddLostPetPage({super.key});

  @override
  ConsumerState<AddLostPetPage> createState() => _AddLostPetPageState();
}

class _AddLostPetPageState extends ConsumerState<AddLostPetPage> {
  final _formKey = GlobalKey<FormState>();

  // Tipo de Alerta: 'lost' (Perdido) | 'found' (Avistado / Encontrado)
  String _reportType = 'lost';

  // Controladores de texto
  final _nameController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Opciones de selección
  String _selectedSpecies = 'Perro';
  String _selectedMunicipality = 'Bucaramanga';

  // Coordenadas seleccionadas en el mini-mapa
  LatLng _pinLocation = const LatLng(7.1193, -73.1227);
  final MapController _miniMapController = MapController();

  // Foto seleccionada
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Prellenar teléfono del usuario si ya lo tiene configurado en su sesión
    final user = Supabase.instance.client.auth.currentUser;
    if (user?.phone != null && user!.phone!.isNotEmpty) {
      _contactPhoneController.text = user.phone!;
    }
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

      // Actualizar automáticamente la ubicación del pin y centrar el mapa
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
        setState(() {
          _selectedImage = file;
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
    final accentColor =
        isLost ? const Color(0xFFE11D48) : const Color(0xFF059669);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Alerta de Mascota'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de Tipo de Alerta
              const Text(
                '¿Qué deseas reportar?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeOption(
                      title: 'Se me perdió mi mascota',
                      subtitle: 'Alerta urgente de búsqueda',
                      icon: Icons.search_rounded,
                      typeValue: 'lost',
                      activeColor: const Color(0xFFE11D48),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeOption(
                      title: 'Vi o encontré un animalito',
                      subtitle: 'Ayuda comunitaria',
                      icon: Icons.visibility_rounded,
                      typeValue: 'found',
                      activeColor: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nombre de la mascota
              Text(
                isLost
                    ? 'Nombre de tu mascota *'
                    : 'Nombre o referencia del animalito',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: isLost
                      ? 'ej. Max, Luna, Toby'
                      : 'ej. Perrito criollo sin collar, Gatita blanca',
                  prefixIcon: const Icon(Icons.pets, color: Color(0xFF0D9488)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (isLost && (val == null || val.trim().isEmpty)) {
                    return 'Ingresa el nombre de la mascota perdida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Especie
              const Text(
                'Especie *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Perro', 'Gato', 'Otro'].map((species) {
                  final isSelected = _selectedSpecies == species;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(species),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0D9488),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
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
              const SizedBox(height: 18),

              // Municipio y Barrio
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Municipio
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Municipio *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedMunicipality,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Bucaramanga',
                              child: Text('Bucaramanga'),
                            ),
                            DropdownMenuItem(
                              value: 'Floridablanca',
                              child: Text('Floridablanca'),
                            ),
                            DropdownMenuItem(
                              value: 'Girón',
                              child: Text('Girón'),
                            ),
                            DropdownMenuItem(
                              value: 'Piedecuesta',
                              child: Text('Piedecuesta'),
                            ),
                            DropdownMenuItem(
                              value: 'Otro',
                              child: Text('Otro'),
                            ),
                          ],
                          onChanged: _onMunicipalityChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Barrio
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Barrio / Sector *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _neighborhoodController,
                          decoration: InputDecoration(
                            hintText: 'ej. Cabecera, Provenza',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Ingresa el barrio';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Mini-Mapa Interactivo con selector de ubicación exacta
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ubicación en el Mapa *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  Text(
                    '${_pinLocation.latitude.toStringAsFixed(4)}, ${_pinLocation.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Toca en el mapa para situar el pin exacto donde se perdió o vio el animalito.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),

              // Contenedor del Mapa
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
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
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Toca para reubicar pin',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Teléfono de contacto WhatsApp
              const Text(
                'Teléfono WhatsApp de Contacto *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contactPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'ej. 3151234567',
                  prefixIcon:
                      const Icon(Icons.phone_outlined, color: Color(0xFF0D9488)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingresa un número de WhatsApp para contacto';
                  }
                  final clean = val.replaceAll(RegExp(r'\D'), '');
                  if (clean.length < 10) {
                    return 'Ingresa un número válido de al menos 10 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Descripción
              const Text(
                'Descripción detallada *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: isLost
                      ? 'Describe señas particulares, collar, color de pelaje, tamaño, si requiere medicamentos o si es asustadizo...'
                      : 'Describe cómo lo viste, estado de salud aparente, color, si lleva collar o placa, y si está bajo resguardo...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 10) {
                    return 'Ingresa una descripción de al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Subida de Foto
              const Text(
                'Foto de la mascota',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),

              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Image.network(
                              _selectedImage!.path,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_selectedImage!.path),
                              height: 180,
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
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Galería'),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Cámara'),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Botón de Envío
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.send_rounded),
                  label: Text(
                    isLost ? 'Publicar Búsqueda de Mascota' : 'Publicar Avistamiento',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _handleSubmit,
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? activeColor : const Color(0xFF64748B)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? activeColor : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
