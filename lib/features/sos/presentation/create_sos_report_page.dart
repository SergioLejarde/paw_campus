import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme.dart';
import '../../../core/presentation/app_feedback.dart';
import '../../../core/presentation/pawco_design_system.dart';
import '../data/sos_repository.dart';

class CreateSosReportPage extends ConsumerStatefulWidget {
  const CreateSosReportPage({super.key});

  @override
  ConsumerState<CreateSosReportPage> createState() =>
      _CreateSosReportPageState();
}

class _CreateSosReportPageState extends ConsumerState<CreateSosReportPage> {
  final _formKey = GlobalKey<FormState>();

  String _urgencyLevel = 'Alta';
  String _abuseType = 'Animal herido en vía pública';
  String _municipality = 'Bucaramanga';

  final _neighborhoodController = TextEditingController();
  final _addressNotesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isAnonymous = true;
  XFile? _pickedImage;
  Uint8List? _imageBytes;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _urgencyOptions = [
    {
      'label': 'Crítica',
      'subtitle': 'Peligro inminente de vida / Heridas graves',
      'color': PawCoColors.terracottaDark,
      'icon': Icons.warning_amber_rounded,
    },
    {
      'label': 'Alta',
      'subtitle': 'Maltrato activo / Agresión física reiterada',
      'color': PawCoColors.terracotta,
      'icon': Icons.priority_high_rounded,
    },
    {
      'label': 'Moderada',
      'subtitle': 'Negligencia / Desnutrición / Sin agua ni techo',
      'color': const Color(0xFFD97706),
      'icon': Icons.info_outline_rounded,
    },
  ];

  final List<String> _abuseTypeOptions = [
    'Animal herido en vía pública',
    'Abandono severo',
    'Agresión física',
    'Negligencia / Sin agua ni techo',
    'Criadero ilegal / Explotación',
    'Otro tipo de maltrato',
  ];

  final List<String> _municipalities = [
    'Bucaramanga',
    'Floridablanca',
    'Girón',
    'Piedecuesta',
    'Otro',
  ];

  User? _getCurrentUser() {
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _neighborhoodController.dispose();
    _addressNotesController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _pickedImage = picked;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'No se pudo seleccionar la imagen: $e');
      }
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Foto o Video de Evidencia',
                  style: GoogleFonts.fraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: PawCoColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: PawCoColors.sageLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: PawCoColors.forest),
                  ),
                  title: Text(
                    'Tomar foto con la cámara',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: PawCoColors.terracottaLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library, color: PawCoColors.terracottaDark),
                  ),
                  title: Text(
                    'Seleccionar de la galería',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    AppFeedback.showLoadingDialog(
      context,
      message: 'Radicando reporte confidencial SOS...',
    );

    try {
      final repo = ref.read(sosRepositoryProvider);
      String? uploadedPhotoUrl;

      if (_pickedImage != null) {
        uploadedPhotoUrl = await repo.uploadEvidencePhoto(_pickedImage!);
      }

      final currentUser = _getCurrentUser();
      final reportId =
          'sos-${DateTime.now().millisecondsSinceEpoch}-${currentUser?.id.substring(0, 5) ?? "anon"}';

      final report = AbuseReport(
        id: reportId,
        urgencyLevel: _urgencyLevel,
        abuseType: _abuseType,
        municipality: _municipality,
        neighborhood: _neighborhoodController.text.trim(),
        addressNotes: _addressNotesController.text.trim().isEmpty
            ? null
            : _addressNotesController.text.trim(),
        description: _descriptionController.text.trim(),
        photoUrl: uploadedPhotoUrl,
        isAnonymous: _isAnonymous,
        reporterId: _isAnonymous ? null : currentUser?.id,
        reporterContact: _isAnonymous || _contactController.text.trim().isEmpty
            ? null
            : _contactController.text.trim(),
        status: 'pending_review',
        createdAt: DateTime.now(),
      );

      await repo.submitReport(report);

      ref.invalidate(publicSosAlertsProvider);
      ref.invalidate(allSosReportsAdminProvider);

      if (!mounted) return;
      AppFeedback.hideLoadingDialog(context);

      // Modal de confirmación tranquilizador
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: const Icon(
            Icons.verified_user_rounded,
            color: PawCoColors.forest,
            size: 50,
          ),
          title: Text(
            '¡Reporte Recibido!',
            style: GoogleFonts.fraunces(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isAnonymous
                    ? 'Tu reporte fue radicado de forma 100% anónima y confidencial.'
                    : 'Tu reporte fue recibido. Si el equipo requiere más datos se comunicará contigo.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: PawCoColors.ink),
              ),
              const SizedBox(height: 10),
              Text(
                'Nuestro equipo y fundaciones aliadas en Bucaramanga y el AMB verificarán la información '
                'para gestionar el rescate o articular con las autoridades.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: PawCoColors.muted),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PawCoColors.forest,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      AppFeedback.hideLoadingDialog(context);
      AppFeedback.showError(context, e);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PawCoColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Reportar Caso SOS',
          style: GoogleFonts.fraunces(
            fontWeight: FontWeight.w700,
            fontSize: 19,
            color: PawCoColors.ink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PawCoColors.ink),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: AnimalSilhouetteBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                children: [
                  // Banner informativo de confidencialidad
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: PawCoColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: PawCoColors.borderLight),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: PawCoColors.terracottaLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shield_outlined,
                              color: PawCoColors.terracottaDark, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Canal Seguro de Protección Ciudadana',
                                style: GoogleFonts.fraunces(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: PawCoColors.ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Este formulario canaliza casos hacia la red comunitaria y fundaciones del Área Metropolitana de Bucaramanga. Tus datos sensibles están 100% protegidos.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  color: PawCoColors.muted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nivel de Urgencia
                  Text(
                    'Nivel de Urgencia *',
                    style: GoogleFonts.fraunces(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: PawCoColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _urgencyOptions.map((opt) {
                      final isSelected = _urgencyLevel == opt['label'];
                      final color = opt['color'] as Color;

                      return InkWell(
                        onTap: () =>
                            setState(() => _urgencyLevel = opt['label'] as String),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.1)
                                : PawCoColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? color : PawCoColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(opt['icon'] as IconData, color: color, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt['label'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.5,
                                        color: isSelected ? color : PawCoColors.ink,
                                      ),
                                    ),
                                    Text(
                                      opt['subtitle'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: PawCoColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: color, size: 20),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Tipo de Situación
                  Text(
                    'Tipo de Maltrato o Situación *',
                    style: GoogleFonts.fraunces(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: PawCoColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: PawCoColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: PawCoColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        initialValue: _abuseType,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.category_outlined, color: PawCoColors.forest),
                        ),
                        items: _abuseTypeOptions.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _abuseType = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Municipio y Barrio
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Municipio *',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: PawCoColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: PawCoColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: PawCoColors.border),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _municipality,
                                  decoration: const InputDecoration(border: InputBorder.none),
                                  items: _municipalities.map((mun) {
                                    return DropdownMenuItem(
                                      value: mun,
                                      child: Text(mun, style: GoogleFonts.plusJakartaSans(fontSize: 13.5)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _municipality = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Barrio / Sector *',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: PawCoColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _neighborhoodController,
                              style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                              decoration: InputDecoration(
                                hintText: 'Ej. Cabecera, Real de Minas',
                                filled: true,
                                fillColor: PawCoColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: PawCoColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: PawCoColors.border),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Indica el barrio';
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

                  // Punto de referencia confidencial / Dirección privada
                  Row(
                    children: [
                      Text(
                        'Dirección exacta o punto de referencia',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: PawCoColors.ink,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.lock_outline, size: 15, color: PawCoColors.muted),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Solo visible para administradores y rescatistas verificados. Jamás se publicará en la app.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: PawCoColors.muted),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _addressNotesController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Ej. Cra 33 # 48-12, frente al parque. Casa con reja verde.',
                      filled: true,
                      fillColor: PawCoColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: PawCoColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: PawCoColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Descripción detallada
                  Text(
                    'Descripción de los hechos *',
                    style: GoogleFonts.fraunces(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: PawCoColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText:
                          'Describe el estado del animal, condición de salud, qué necesita con urgencia y cualquier detalle relevante para su atención...',
                      filled: true,
                      fillColor: PawCoColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: PawCoColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: PawCoColors.border),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().length < 10) {
                        return 'Por favor describe la situación (mínimo 10 caracteres)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ========================================================
                  // ZONA DE CARGA DE EVIDENCIA (PAWCODASHEDBOX - MOCKUP 5)
                  // ========================================================
                  Text(
                    'Foto o Video de Evidencia',
                    style: GoogleFonts.fraunces(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: PawCoColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Una foto clara ayuda enormemente a evaluar la gravedad y priorizar el auxilio.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: PawCoColors.muted),
                  ),
                  const SizedBox(height: 10),

                  if (_imageBytes != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.memory(
                            _imageBytes!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 20),
                              onPressed: () {
                                setState(() {
                                  _pickedImage = null;
                                  _imageBytes = null;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    PawCoDashedBox(
                      borderRadius: 18,
                      backgroundColor: const Color(0xFFE4F0EC), // Verde agua pastel Mockup 5
                      strokeColor: PawCoColors.sage,
                      onTap: _showImagePickerSheet,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_upload_outlined,
                                size: 30,
                                color: PawCoColors.forest,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Toca aquí para subir foto o video',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: PawCoColors.forest,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Formatos permitidos: JPG, PNG • Cámara o Galería',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: PawCoColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 22),

                  // ========================================================
                  // BLOQUE DE CONTACTO DE EMERGENCIA (DURAZNO CÁLIDO #F7E4D4)
                  // ========================================================
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7E4D4), // Durazno cálido Mockup 5
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: PawCoColors.terracotta.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Switch de confidencialidad en verde bosque
                        Material(
                          color: Colors.transparent,
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            activeThumbColor: PawCoColors.forest,
                            activeTrackColor: PawCoColors.sageLight,
                            title: Text(
                              'Enviar denuncia de forma anónima',
                              style: GoogleFonts.fraunces(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: PawCoColors.ink,
                              ),
                            ),
                            subtitle: Text(
                              'Tu identidad y cuenta de usuario no quedarán asociadas al reporte público.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: PawCoColors.inkSecondary,
                              ),
                            ),
                            value: _isAnonymous,
                            onChanged: (val) {
                              setState(() => _isAnonymous = val);
                            },
                          ),
                        ),
                        if (!_isAnonymous) ...[
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _contactController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                            decoration: InputDecoration(
                              labelText: 'Teléfono o WhatsApp de contacto',
                              labelStyle: GoogleFonts.plusJakartaSans(color: PawCoColors.inkSecondary),
                              hintText: 'Ej. 315 123 4567',
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.phone_outlined, color: PawCoColors.forest),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  // ========================================================
                  // BOTÓN PRINCIPAL REDONDEADO EN VERDE BOSQUE (#3E5641)
                  // ========================================================
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E5641), // Verde bosque profundo
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 20),
                      label: Text(
                        'Radicar Reporte SOS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
