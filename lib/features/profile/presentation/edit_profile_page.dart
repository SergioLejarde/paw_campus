// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:paw_campus/features/profile/data/profile_repository.dart';
import 'profile_page.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _photoCtrl = TextEditingController(); // compatibilidad

  final _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;

  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedImage = picked;
        _pickedImageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error cargando perfil:\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (profile) {
          if (!_initialized) {
            _initialized = true;
            if (profile != null) {
              _nameCtrl.text = profile.name ?? '';
              _phoneCtrl.text = profile.phone ?? '';
              _photoCtrl.text = profile.photoUrl ?? '';
            }
          }

          // ✅ PREVIEW SEGURO (WEB + MOBILE)
          final imagePreview = _pickedImageBytes != null
              ? Image.memory(
                  _pickedImageBytes!,
                  fit: BoxFit.cover,
                )
              : (profile?.photoUrl != null &&
                      profile!.photoUrl!.isNotEmpty)
                  ? Image.network(
                      profile.photoUrl!,
                      fit: BoxFit.cover,
                    )
                  : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(
                                leading:
                                    const Icon(Icons.photo_library),
                                title:
                                    const Text('Elegir de galería'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                              ListTile(
                                leading:
                                    const Icon(Icons.camera_alt),
                                title:
                                    const Text('Tomar foto'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor:
                          Colors.grey.shade300,
                      child: ClipOval(
                        child: SizedBox(
                          width: 110,
                          height: 110,
                          child: imagePreview ??
                              const Icon(
                                Icons.person,
                                size: 60,
                              ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Ingresa tu nombre';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (!_formKey
                                  .currentState!
                                  .validate()) {
                                return;
                              }

                              setState(() {
                                _isSaving = true;
                              });

                              try {
                                final repo =
                                    ProfileRepository();

                                String? photoUrl;

                                if (_pickedImage != null) {
                                  photoUrl =
                                      await repo.uploadProfilePhoto(
                                    _pickedImage!,
                                  );
                                }

                                await repo.updateCurrentProfile(
                                  name: _nameCtrl
                                      .text
                                      .trim(),
                                  phone: _phoneCtrl
                                          .text
                                          .trim()
                                          .isEmpty
                                      ? null
                                      : _phoneCtrl
                                          .text
                                          .trim(),
                                  photoUrl: photoUrl,
                                );

                                ScaffoldMessenger.of(
                                        context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Perfil actualizado ✅'),
                                  ),
                                );

                                ref.invalidate(
                                    currentProfileProvider);

                                context.pop();
                              } catch (e) {
                                ScaffoldMessenger.of(
                                        context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Error al guardar: $e'),
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isSaving = false;
                                  });
                                }
                              }
                            },
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Guardar cambios'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
