import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:paw_campus/core/presentation/app_feedback.dart';
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
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _pickedImage = picked);
    }
  }

  Future<String> _uploadImage(XFile file) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final fileExt = file.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'pets/${user.id}/$fileName';

    final storage = Supabase.instance.client.storage.from('pet_photos');

    if (kIsWeb) {
      // 📤 Web: subir bytes
      final bytes = await file.readAsBytes();
      await storage.uploadBinary(filePath, bytes);
    } else {
      // 📱 Móvil: subir archivo físico
      await storage.upload(filePath, File(file.path));
    }

    return storage.getPublicUrl(filePath);
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImage == null) {
      AppFeedback.showError(
        context,
        Exception('Por favor selecciona una foto de la mascota'),
      );
      return;
    }

    setState(() => _loading = true);
    final repo = PetsRepository();

    try {
      final imageUrl = await _uploadImage(_pickedImage!);
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
    final imagePreview = _pickedImage == null
        ? const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 48, color: Color(0xFF0D9488)),
              SizedBox(height: 8),
              Text(
                'Toca para subir una foto',
                style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          )
        : (kIsWeb
            ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
            : Image.file(File(_pickedImage!.path), fit: BoxFit.cover));

    return Scaffold(
      appBar: AppBar(title: const Text('Dar en adopción')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Selector de foto
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _pickedImage == null ? const Color(0xFFCBD5E1) : const Color(0xFF0D9488),
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Center(child: imagePreview),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nombre
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la mascota',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Ingresa el nombre' : null,
                  ),
                  const SizedBox(height: 14),

                  // Especie
                  DropdownButtonFormField<String>(
                    initialValue: _speciesList.contains(_speciesController.text)
                        ? _speciesController.text
                        : 'Perro',
                    decoration: const InputDecoration(
                      labelText: 'Especie',
                      prefixIcon: Icon(Icons.pets),
                    ),
                    items: _speciesList.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _speciesController.text = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Edad y Tamaño (en fila)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                            labelText: 'Edad (años)',
                            prefixIcon: Icon(Icons.cake_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Ingresa la edad' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedSize,
                          decoration: const InputDecoration(
                            labelText: 'Tamaño',
                            prefixIcon: Icon(Icons.straighten),
                          ),
                          items: _sizes.map((sz) {
                            return DropdownMenuItem(value: sz, child: Text(sz));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSize = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Municipio (Bucaramanga, Floridablanca, etc.)
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    decoration: const InputDecoration(
                      labelText: 'Municipio / Ciudad',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    items: _cities.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCity = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Barrio
                  TextFormField(
                    controller: _neighborhoodController,
                    decoration: const InputDecoration(
                      labelText: 'Barrio / Sector (opcional)',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Descripción
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

                  // Botón enviar
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
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
                          : const Icon(Icons.pets),
                      label: Text(
                        _loading ? 'Publicando...' : 'Publicar mascota para adopción',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tu publicación será revisada por el equipo de PawCo antes de aparecer en el catálogo público.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
