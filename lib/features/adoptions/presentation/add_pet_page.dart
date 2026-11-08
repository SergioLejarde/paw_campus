import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_campus/app/theme.dart';
import 'package:paw_campus/core/presentation/app_feedback.dart';
import 'package:paw_campus/core/presentation/pawco_design_system.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/pets_repository.dart';

class AddPetPage extends ConsumerStatefulWidget {
  const AddPetPage({super.key});

  @override
  ConsumerState<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends ConsumerState<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController(text: 'Perro');
  final _ageController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCity = 'Bucaramanga';
  String _selectedSize = 'Mediano';

  static const List<String> _cities = [
    'Bucaramanga',
    'Floridablanca',
    'Girón',
    'Piedecuesta',
    'Otro',
  ];

  static const List<String> _sizes = [
    'Pequeño',
    'Mediano',
    'Grande',
  ];

  static const List<String> _speciesList = [
    'Perro',
    'Gato',
    'Conejo',
    'Otro',
  ];

  XFile? _pickedImage;
  Uint8List? _imageBytes;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _ageController.dispose();
    _neighborhoodController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedImage = picked;
        _imageBytes = bytes;
      });
    }
  }

  Future<String> _uploadImage(XFile file, Uint8List bytes) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final rawExt = file.name.contains('.')
        ? file.name.split('.').last.toLowerCase()
        : 'jpg';
    final fileExt = rawExt.isEmpty ? 'jpg' : rawExt;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'pets/${user.id}/$fileName';

    final storage = Supabase.instance.client.storage.from('pet_photos');
    await storage.uploadBinary(filePath, bytes);
    return storage.getPublicUrl(filePath);
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImage == null || _imageBytes == null) {
      AppFeedback.showError(
        context,
        Exception('Por favor selecciona una foto de la mascota'),
      );
      return;
    }

    setState(() => _loading = true);
    final repo = PetsRepository();

    try {
      final imageUrl = await _uploadImage(_pickedImage!, _imageBytes!);
      await repo.addPet(
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        description: _descriptionController.text.trim(),
        photoUrl: imageUrl,
        city: _selectedCity,
        neighborhood: _neighborhoodController.text.trim().isEmpty
            ? null
            : _neighborhoodController.text.trim(),
        size: _selectedSize,
      );

      if (mounted) {
        AppFeedback.showSuccess(
          context,
          'Mascota registrada correctamente. Quedó pendiente de aprobación.',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, e);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      context.go('/adoptions');
                    }
                  },
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Dar en adopción',
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
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Container(
                      padding: const EdgeInsets.all(22),
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Selector de foto con PawCoDashedBox en Lila Algodón
                            if (_imageBytes != null)
                              GestureDetector(
                                onTap: _pickImage,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: SizedBox(
                                    height: 220,
                                    width: double.infinity,
                                    child: Image.memory(
                                      _imageBytes!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                            else
                              PawCoDashedBox(
                                onTap: _pickImage,
                                backgroundColor: PawCoColors.sageMuted,
                                strokeColor: PawCoColors.sage,
                                borderRadius: 18,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 34,
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: const BoxDecoration(
                                          color: PawCoColors.cottonLilac,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add_a_photo_rounded,
                                          size: 30,
                                          color: PawCoColors.plum,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Toca para subir una foto',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: PawCoColors.plum,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),

                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre de la mascota',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Ingresa el nombre'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue:
                                  _speciesList.contains(_speciesController.text)
                                      ? _speciesController.text
                                      : 'Perro',
                              decoration: const InputDecoration(
                                labelText: 'Especie',
                                prefixIcon: Icon(Icons.pets_rounded),
                              ),
                              items: _speciesList.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _speciesController.text = val);
                                }
                              },
                            ),
                            const SizedBox(height: 14),

                            // Edad y Tamaño adaptables para móviles de 320px
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isNarrow = constraints.maxWidth < 360;
                                final ageField = TextFormField(
                                  controller: _ageController,
                                  decoration: const InputDecoration(
                                    labelText: 'Edad (años)',
                                    prefixIcon: Icon(Icons.cake_outlined),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Ingresa la edad'
                                          : null,
                                );
                                final sizeField =
                                    DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  initialValue: _selectedSize,
                                  decoration: const InputDecoration(
                                    labelText: 'Tamaño',
                                    prefixIcon: Icon(Icons.straighten_rounded),
                                  ),
                                  items: _sizes.map((sz) {
                                    return DropdownMenuItem(
                                      value: sz,
                                      child: Text(
                                        sz,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedSize = val);
                                    }
                                  },
                                );

                                if (isNarrow) {
                                  return Column(
                                    children: [
                                      ageField,
                                      const SizedBox(height: 14),
                                      sizeField,
                                    ],
                                  );
                                }
                                return Row(
                                  children: [
                                    Expanded(child: ageField),
                                    const SizedBox(width: 12),
                                    Expanded(child: sizeField),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedCity,
                              decoration: const InputDecoration(
                                labelText: 'Municipio / Ciudad',
                                prefixIcon: Icon(Icons.location_city_rounded),
                              ),
                              items: _cities.map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCity = val);
                                }
                              },
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _neighborhoodController,
                              decoration: const InputDecoration(
                                labelText: 'Barrio / Sector (opcional)',
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Historia / Descripción',
                                alignLabelWithHint: true,
                              ),
                              maxLines: 4,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Cuéntanos un poco sobre su personalidad'
                                  : null,
                            ),
                            const SizedBox(height: 24),

                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PawCoColors.plum,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _loading ? null : _savePet,
                                icon: _loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.pets_rounded),
                                label: Text(
                                  _loading
                                      ? 'Publicando...'
                                      : 'Publicar mascota para adopción',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tu publicación será revisada por el equipo de PawCol antes de aparecer en el catálogo público.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: PawCoColors.muted,
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
}
