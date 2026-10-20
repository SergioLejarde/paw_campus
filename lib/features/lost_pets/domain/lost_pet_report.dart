import 'package:latlong2/latlong.dart';

/// Modelo de dominio para reportes de mascotas perdidas o encontradas/avistadas.
class LostPetReport {
  final String id;
  final String reportType; // 'lost' (Perdido) | 'found' (Avistado / Encontrado)
  final String petName;
  final String species; // 'Perro', 'Gato', 'Otro'
  final String municipality; // 'Bucaramanga', 'Floridablanca', 'Girón', 'Piedecuesta', 'Otro'
  final String neighborhood;
  final String description;
  final String? photoUrl;
  final String contactPhone;
  final double latitude;
  final double longitude;
  final String status; // 'active', 'resolved', 'flagged'
  final String? createdBy;
  final DateTime createdAt;

  const LostPetReport({
    required this.id,
    required this.reportType,
    required this.petName,
    required this.species,
    required this.municipality,
    required this.neighborhood,
    required this.description,
    this.photoUrl,
    required this.contactPhone,
    this.latitude = 7.1193,
    this.longitude = -73.1227,
    this.status = 'active',
    this.createdBy,
    required this.createdAt,
  });

  /// Coordenadas LatLng para uso directo con flutter_map
  LatLng get latLng => LatLng(latitude, longitude);

  /// Indica si es un reporte de mascota perdida
  bool get isLost => reportType == 'lost';

  /// Indica si es un reporte de mascota encontrada o avistada
  bool get isFound => reportType == 'found';

  /// Estado activo (visible públicamente)
  bool get isActive => status == 'active';

  /// Estado resuelto (¡Ya apareció!)
  bool get isResolved => status == 'resolved';

  /// Estado marcado por la comunidad como indebido
  bool get isFlagged => status == 'flagged';

  /// Etiqueta legible del tipo de reporte
  String get typeLabel => isLost ? 'Perdido' : 'Avistado / Encontrado';

  /// Teléfono limpio formateado con indicativo Colombia (57) para WhatsApp
  String get cleanWhatsappPhone {
    var digits = contactPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10 && !digits.startsWith('57')) {
      digits = '57$digits';
    }
    return digits;
  }

  factory LostPetReport.fromJson(Map<String, dynamic> json) {
    return LostPetReport(
      id: json['id']?.toString() ?? '',
      reportType: json['report_type']?.toString() ??
          json['reportType']?.toString() ??
          'lost',
      petName: json['pet_name']?.toString() ??
          json['petName']?.toString() ??
          'Mascota sin nombre',
      species: json['species']?.toString() ?? 'Perro',
      municipality: json['municipality']?.toString() ?? 'Bucaramanga',
      neighborhood: json['neighborhood']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ?? json['photoUrl']?.toString(),
      contactPhone: json['contact_phone']?.toString() ??
          json['contactPhone']?.toString() ??
          '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 7.1193,
      longitude: (json['longitude'] as num?)?.toDouble() ?? -73.1227,
      status: json['status']?.toString() ?? 'active',
      createdBy:
          json['created_by']?.toString() ?? json['createdBy']?.toString(),
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : (json['createdAt'] != null
              ? (DateTime.tryParse(json['createdAt'].toString()) ??
                  DateTime.now())
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_type': reportType,
      'pet_name': petName,
      'species': species,
      'municipality': municipality,
      'neighborhood': neighborhood,
      'description': description,
      'photo_url': photoUrl,
      'contact_phone': contactPhone,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LostPetReport copyWith({
    String? id,
    String? reportType,
    String? petName,
    String? species,
    String? municipality,
    String? neighborhood,
    String? description,
    String? photoUrl,
    String? contactPhone,
    double? latitude,
    double? longitude,
    String? status,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return LostPetReport(
      id: id ?? this.id,
      reportType: reportType ?? this.reportType,
      petName: petName ?? this.petName,
      species: species ?? this.species,
      municipality: municipality ?? this.municipality,
      neighborhood: neighborhood ?? this.neighborhood,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      contactPhone: contactPhone ?? this.contactPhone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
