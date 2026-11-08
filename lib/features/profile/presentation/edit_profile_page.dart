// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:paw_campus/app/theme.dart';
import 'package:paw_campus/core/presentation/app_feedback.dart';
import 'package:paw_campus/core/presentation/pawco_design_system.dart';
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
  final _photoCtrl = TextEditingController();

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
    final picked = await _picker.pickImage(source: source, imageQuality: 80);

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 860;

    return Scaffold(
      backgroundColor: PawCoColors.background,
      body: AnimalSilhouetteBackground(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PawColAuroraWaveHeader(
                contentPadding: EdgeInsets.fromLTRB(
                  isDesktop ? 32 : 16,
                  MediaQuery.of(context).padding.top + 14,
                  isDesktop ? 32 : 16,
                  18,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Row(
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/profile');
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PawColGradientText(
                                'Editar perfil',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: isDesktop ? 26 : 21,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Actualiza tus datos de contacto y fotografía',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  color: Colors.white.withValues(alpha: 0.82),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              profileAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(
                    child: CircularProgressIndicator(color: PawCoColors.plum),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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

                  final imagePreview = _pickedImageBytes != null
                      ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                      : (profile?.photoUrl != null &&
                            profile!.photoUrl!.isNotEmpty)
                      ? Image.network(
                          profile.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_outline_rounded,
                            size: 52,
                            color: PawCoColors.plum,
                          ),
                        )
                      : null;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth < 360 ? 14 : 20,
                      vertical: 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: PawCoColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: PawCoColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: PawCoColors.plum.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: PawCoColors.surface,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(22),
                                        ),
                                      ),
                                      builder: (_) => SafeArea(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            child: Wrap(
                                              children: [
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.photo_library_rounded,
                                                    color: PawCoColors.plum,
                                                  ),
                                                  title: Text(
                                                    'Elegir de galería',
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    _pickImage(
                                                      ImageSource.gallery,
                                                    );
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.camera_alt_rounded,
                                                    color: PawCoColors.malva,
                                                  ),
                                                  title: Text(
                                                    'Tomar foto',
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    _pickImage(
                                                      ImageSource.camera,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: 55,
                                        backgroundColor:
                                            PawCoColors.cottonLilac,
                                        child: ClipOval(
                                          child: SizedBox(
                                            width: 110,
                                            height: 110,
                                            child:
                                                imagePreview ??
                                                const Icon(
                                                  Icons.person_outline_rounded,
                                                  size: 54,
                                                  color: PawCoColors.plum,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: PawCoColors.plum,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _nameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre',
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: PawCoColors.plum,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
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
                                    prefixIcon: Icon(
                                      Icons.phone_outlined,
                                      color: PawCoColors.plum,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: PawCoColors.plum,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: _isSaving
                                        ? null
                                        : () async {
                                            if (!_formKey.currentState!
                                                .validate()) {
                                              return;
                                            }

                                            setState(() {
                                              _isSaving = true;
                                            });

                                            try {
                                              final repo = ProfileRepository();

                                              String? photoUrl;

                                              if (_pickedImage != null) {
                                                photoUrl = await repo
                                                    .uploadProfilePhoto(
                                                      _pickedImage!,
                                                    );
                                              }

                                              await repo.updateCurrentProfile(
                                                name: _nameCtrl.text.trim(),
                                                phone:
                                                    _phoneCtrl.text
                                                        .trim()
                                                        .isEmpty
                                                    ? null
                                                    : _phoneCtrl.text.trim(),
                                                photoUrl: photoUrl,
                                              );

                                              AppFeedback.showSuccess(
                                                context,
                                                'Perfil actualizado correctamente',
                                              );

                                              ref.invalidate(
                                                currentProfileProvider,
                                              );

                                              context.pop();
                                            } catch (e) {
                                              AppFeedback.showError(context, e);
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
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Guardar cambios',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
