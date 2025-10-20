import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
  final _speciesController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();

  XFile? _pickedImage;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una foto 📷')),
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
        age: int.parse(_ageController.text.trim()),
        description: _descriptionController.text.trim(),
        photoUrl: imageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '🐾 Mascota registrada correctamente (pendiente de aprobación)'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Error al registrar: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePreview = _pickedImage == null
        ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
        : (kIsWeb
            ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
            : Image.file(File(_pickedImage!.path), fit: BoxFit.cover));

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Mascota')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Center(child: imagePreview),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingrese el nombre' : null,
                ),
                TextFormField(
                  controller: _speciesController,
                  decoration: const InputDecoration(labelText: 'Especie'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingrese la especie' : null,
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Edad (años)'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingrese la edad' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Ingrese una breve descripción'
                      : null,
                ),
                const SizedBox(height: 20),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _savePet,
                        icon: const Icon(Icons.pets),
                        label: const Text('Registrar Mascota'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
