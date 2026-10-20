import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/presentation/app_feedback.dart';
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
      'color': const Color(0xFFE11D48),
      'icon': Icons.warning_amber_rounded,
    },
    {
      'label': 'Alta',
      'subtitle': 'Maltrato activo / Agresión física reiterada',
      'color': const Color(0xFFEA580C),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Foto de Evidencia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFCCFBF1),
                    child: Icon(Icons.camera_alt, color: Color(0xFF0D9488)),
                  ),
                  title: const Text('Tomar foto con la cámara'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFE4E6),
                    child: Icon(Icons.photo_library, color: Color(0xFFE11D48)),
                  ),
                  title: const Text('Seleccionar de la galería'),
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

      final currentUser = Supabase.instance.client.auth.currentUser;
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
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.verified_user_rounded,
            color: Color(0xFF0D9488),
            size: 54,
          ),
          title: const Text(
            '¡Reporte Recibido!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isAnonymous
                    ? 'Tu reporte fue radicado de forma 100% anónima y confidencial.'
                    : 'Tu reporte fue recibido. Si el equipo requiere más datos se comunicará contigo.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nuestro equipo y fundaciones aliadas en Bucaramanga y el AMB verificarán la información '
                'para gestionar el rescate o articular con las autoridades.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Caso SOS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Banner informativo de confidencialidad
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined,
                          color: Color(0xFFE11D48), size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Canal Seguro de Protección Ciudadana',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Este formulario canaliza casos hacia la red comunitaria y fundaciones del Área Metropolitana de Bucaramanga. Tus datos sensibles están protegidos.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7F1D1D),
                                height: 1.35,
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
                const Text(
                  'Nivel de Urgencia *',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
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
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(opt['icon'] as IconData,
                                color: color, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt['label'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isSelected
                                          ? color
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    opt['subtitle'] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: color, size: 22),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Tipo de Caso
                const Text(
                  'Tipo de Maltrato o Situación *',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _abuseType,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _abuseTypeOptions.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _abuseType = val);
                  },
                ),
                const SizedBox(height: 16),

                // Municipio y Barrio
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Municipio *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _municipality,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                            items: _municipalities.map((mun) {
                              return DropdownMenuItem(
                                value: mun,
                                child: Text(mun,
                                    style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _municipality = val);
                              }
                            },
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
                          const Text(
                            'Barrio / Sector *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _neighborhoodController,
                            decoration: const InputDecoration(
                              hintText: 'Ej. Cabecera, Real de Minas',
                              prefixIcon: Icon(Icons.map_outlined),
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
                const SizedBox(height: 16),

                // Punto de referencia confidencial / Dirección privada
                const Row(
                  children: [
                    Text(
                      'Dirección exacta o punto de referencia',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.lock_outline, size: 16, color: Color(0xFF64748B)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Solo visible para administradores y brigadas de rescate. Jamás se publicará en la app.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressNotesController,
                  decoration: const InputDecoration(
                    hintText:
                        'Ej. Cra 33 # 48-12, frente al parque. Casa con reja verde.',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Descripción detallada
                const Text(
                  'Descripción de los hechos *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                        'Describe el estado del animal, condición de salud, qué necesita con urgencia y cualquier detalle relevante para su atención...',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length < 10) {
                      return 'Por favor describe la situación (mínimo 10 caracteres)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Foto de Evidencia
                const Text(
                  'Foto de Evidencia (Recomendada)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Una foto clara ayuda enormemente a evaluar la gravedad y priorizar el auxilio.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),

                if (_imageBytes != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
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
                            icon:
                                const Icon(Icons.close, color: Colors.white, size: 20),
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
                  OutlinedButton.icon(
                    onPressed: _showImagePickerSheet,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Adjuntar foto (Cámara o Galería)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF0D9488)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Switch de Denuncia Anónima
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: const Color(0xFF0D9488),
                          title: const Text(
                            'Denuncia 100% Anónima',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: const Text(
                            'Tu identidad y cuenta de usuario no quedarán asociadas al reporte.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          value: _isAnonymous,
                          onChanged: (val) {
                            setState(() => _isAnonymous = val);
                          },
                        ),
                        if (!_isAnonymous) ...[
                          const Divider(),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _contactController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono o WhatsApp de contacto',
                              hintText: 'Ej. 315 123 4567',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Botón de Enviar
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded),
                  label: const Text(
                    'Radicar Reporte SOS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
