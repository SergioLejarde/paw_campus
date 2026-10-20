/// Modelo de dominio para reportes de maltrato animal y solicitudes de auxilio SOS.
class AbuseReport {
  final String id;
  final String urgencyLevel; // 'Crítica', 'Alta', 'Moderada'
  final String abuseType; // 'Abandono severo', 'Agresión física', 'Negligencia / Sin agua ni techo', 'Criadero ilegal / Explotación', 'Animal herido en vía pública'
  final String municipality; // 'Bucaramanga', 'Floridablanca', 'Girón', 'Piedecuesta', 'Otro'
  final String neighborhood;
  final String? addressNotes; // Solo visible para administradores y rescatistas (privado)
  final String description;
  final String? photoUrl;
  final bool isAnonymous;
  final String? reporterId;
  final String? reporterContact; // Opcional si no es anónima (teléfono/email de contacto)
  final String status; // 'pending_review', 'in_progress', 'public_alert', 'resolved', 'rejected'
  final DateTime createdAt;

  const AbuseReport({
    required this.id,
    required this.urgencyLevel,
    required this.abuseType,
    required this.municipality,
    required this.neighborhood,
    this.addressNotes,
    required this.description,
    this.photoUrl,
    this.isAnonymous = true,
    this.reporterId,
    this.reporterContact,
    this.status = 'pending_review',
    required this.createdAt,
  });

  factory AbuseReport.fromJson(Map<String, dynamic> json) {
    return AbuseReport(
      id: json['id']?.toString() ?? '',
      urgencyLevel: json['urgency_level']?.toString() ??
          json['urgencyLevel']?.toString() ??
          'Alta',
      abuseType: json['abuse_type']?.toString() ??
          json['abuseType']?.toString() ??
          'Animal herido en vía pública',
      municipality: json['municipality']?.toString() ?? 'Bucaramanga',
      neighborhood: json['neighborhood']?.toString() ?? '',
      addressNotes: json['address_notes']?.toString() ??
          json['addressNotes']?.toString(),
      description: json['description']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ?? json['photoUrl']?.toString(),
      isAnonymous: (json['is_anonymous'] as bool?) ??
          (json['isAnonymous'] as bool?) ??
          true,
      reporterId:
          json['reporter_id']?.toString() ?? json['reporterId']?.toString(),
      reporterContact: json['reporter_contact']?.toString() ??
          json['reporterContact']?.toString(),
      status: json['status']?.toString() ?? 'pending_review',
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
      'urgency_level': urgencyLevel,
      'abuse_type': abuseType,
      'municipality': municipality,
      'neighborhood': neighborhood,
      'address_notes': addressNotes,
      'description': description,
      'photo_url': photoUrl,
      'is_anonymous': isAnonymous,
      'reporter_id': reporterId,
      'reporter_contact': reporterContact,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AbuseReport copyWith({
    String? id,
    String? urgencyLevel,
    String? abuseType,
    String? municipality,
    String? neighborhood,
    String? addressNotes,
    String? description,
    String? photoUrl,
    bool? isAnonymous,
    String? reporterId,
    String? reporterContact,
    String? status,
    DateTime? createdAt,
  }) {
    return AbuseReport(
      id: id ?? this.id,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      abuseType: abuseType ?? this.abuseType,
      municipality: municipality ?? this.municipality,
      neighborhood: neighborhood ?? this.neighborhood,
      addressNotes: addressNotes ?? this.addressNotes,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      reporterId: reporterId ?? this.reporterId,
      reporterContact: reporterContact ?? this.reporterContact,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
