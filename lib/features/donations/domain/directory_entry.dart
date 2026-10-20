/// Categorías disponibles para las entidades del directorio 24/7
class DirectoryCategory {
  static const String veterinary24h = 'Veterinaria 24/7';
  static const String foundation = 'Fundación / Refugio';
  static const String emergencyLine = 'Línea de Emergencia';
  static const String welfare = 'Esterilización / Bienestar';

  static const List<String> all = [
    veterinary24h,
    foundation,
    emergencyLine,
    welfare,
  ];
}

/// Municipios del Área Metropolitana de Bucaramanga
class DirectoryMunicipality {
  static const String bucaramanga = 'Bucaramanga';
  static const String floridablanca = 'Floridablanca';
  static const String giron = 'Girón';
  static const String piedecuesta = 'Piedecuesta';
  static const String metropolitana = 'Área Metropolitana';

  static const List<String> all = [
    bucaramanga,
    floridablanca,
    giron,
    piedecuesta,
    metropolitana,
  ];
}

/// Modelo para una entidad en el Directorio 24/7 y Comunitario de Bucaramanga y AMB
class DirectoryEntry {
  final String id;
  final String name;
  final String category;
  final String municipality;
  final String address;
  final String phone;
  final String? whatsapp;
  final bool is24Hours;
  final String description;
  final String? neighborhood;
  final String? openHours;

  const DirectoryEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.municipality,
    required this.address,
    required this.phone,
    this.whatsapp,
    this.is24Hours = false,
    required this.description,
    this.neighborhood,
    this.openHours,
  });

  /// Extrae solo los dígitos para llamadas directas
  String get cleanPhone => phone.replaceAll(RegExp(r'[^0-9]'), '');

  /// Extrae los dígitos del número de WhatsApp (o del teléfono si es celular)
  String get cleanWhatsapp {
    final raw = (whatsapp != null && whatsapp!.isNotEmpty) ? whatsapp! : phone;
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    // Si viene con el prefijo 57 lo dejamos; si son 10 dígitos (celular colombiano) queda listo
    return digits;
  }

  /// URL lista para abrir la app de teléfono
  String get telUrl => 'tel:$cleanPhone';

  /// URL lista para abrir chat directo en WhatsApp
  String get whatsappUrl {
    final digits = cleanWhatsapp;
    final formatted = digits.startsWith('57') ? digits : '57$digits';
    return 'https://wa.me/$formatted?text=Hola,%20los%20contacto%20desde%20la%20comunidad%20PawCo%20🐾';
  }

  factory DirectoryEntry.fromJson(Map<String, dynamic> json) {
    return DirectoryEntry(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? DirectoryCategory.veterinary24h).toString(),
      municipality: (json['municipality'] ?? DirectoryMunicipality.bucaramanga).toString(),
      address: (json['address'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      whatsapp: json['whatsapp'] as String?,
      is24Hours: json['is_24_hours'] == true || json['is24Hours'] == true,
      description: (json['description'] ?? '').toString(),
      neighborhood: json['neighborhood'] as String?,
      openHours: json['open_hours'] as String? ?? json['openHours'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'municipality': municipality,
      'address': address,
      'phone': phone,
      'whatsapp': whatsapp,
      'is_24_hours': is24Hours,
      'description': description,
      'neighborhood': neighborhood,
      'open_hours': openHours,
    };
  }

  DirectoryEntry copyWith({
    String? id,
    String? name,
    String? category,
    String? municipality,
    String? address,
    String? phone,
    String? whatsapp,
    bool? is24Hours,
    String? description,
    String? neighborhood,
    String? openHours,
  }) {
    return DirectoryEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      municipality: municipality ?? this.municipality,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      is24Hours: is24Hours ?? this.is24Hours,
      description: description ?? this.description,
      neighborhood: neighborhood ?? this.neighborhood,
      openHours: openHours ?? this.openHours,
    );
  }

  /// Lista curada oficial de centros de atención y fundaciones en Bucaramanga y AMB
  static const List<DirectoryEntry> curatedEntries = [
    // 1. UBA Bucaramanga
    DirectoryEntry(
      id: 'uba-bucaramanga',
      name: 'Unidad de Bienestar Animal (UBA)',
      category: DirectoryCategory.welfare,
      municipality: DirectoryMunicipality.bucaramanga,
      neighborhood: 'El Mutis / Vía Chimitá',
      address: 'Km 2 Vía Chimitá (antigua planta de asfalto)',
      phone: '3164733499',
      whatsapp: '3164733499',
      is24Hours: false,
      openHours: 'Lunes a Viernes 7:30 AM - 4:00 PM',
      description:
          'Entidad oficial de la Alcaldía de Bucaramanga para rescate, esterilización y atención médico-veterinaria de caninos y felinos vulnerables.',
    ),

    // 2. Policía Ambiental Metropolitana
    DirectoryEntry(
      id: 'policia-ambiental-amb',
      name: 'Policía Ambiental y Ecológica Metropolitana',
      category: DirectoryCategory.emergencyLine,
      municipality: DirectoryMunicipality.metropolitana,
      neighborhood: 'Comando Central MEBUC',
      address: 'Calle 45 con Carrera 9, Bucaramanga',
      phone: '123',
      whatsapp: '3143617860',
      is24Hours: true,
      openHours: '24 Horas / Todos los días',
      description:
          'Atención inmediata a casos de maltrato animal en flagrancia, rescate de fauna silvestre y operativos de protección animal en Bucaramanga y AMB.',
    ),

    // 3. Clínica Veterinaria San Fermín 24H (Cabecera)
    DirectoryEntry(
      id: 'vet-san-fermin-24h',
      name: 'Clínica Veterinaria San Fermín 24 Horas',
      category: DirectoryCategory.veterinary24h,
      municipality: DirectoryMunicipality.bucaramanga,
      neighborhood: 'Cabecera del Llano',
      address: 'Carrera 33 # 48-25',
      phone: '3183502818',
      whatsapp: '3183502818',
      is24Hours: true,
      openHours: '24 Horas / 365 días',
      description:
          'Servicio ininterrumpido de urgencias veterinarias, cirugía de trauma, laboratorio clínico y cuidados intensivos en el sector Cabecera.',
    ),

    // 4. Mascotas del Country 24/7 (Cañaveral - Floridablanca)
    DirectoryEntry(
      id: 'vet-mascotas-country-florida',
      name: 'Centro Médico Veterinario Cañaveral 24/7',
      category: DirectoryCategory.veterinary24h,
      municipality: DirectoryMunicipality.floridablanca,
      neighborhood: 'Cañaveral',
      address: 'Calle 30 # 25-14',
      phone: '3168765432',
      whatsapp: '3168765432',
      is24Hours: true,
      openHours: '24 Horas / 365 días',
      description:
          'Urgencias 24 horas en Floridablanca, rayos X digital, ecografía, quirófano especializado y hospitalización canina y felina.',
    ),

    // 5. Centro Veterinario San Agustín 24H (Sotomayor)
    DirectoryEntry(
      id: 'vet-san-agustin-sotomayor',
      name: 'Clínica Veterinaria San Agustín 24 Horas',
      category: DirectoryCategory.veterinary24h,
      municipality: DirectoryMunicipality.bucaramanga,
      neighborhood: 'Sotomayor',
      address: 'Calle 45 # 28-30',
      phone: '3002345678',
      whatsapp: '3002345678',
      is24Hours: true,
      openHours: '24 Horas',
      description:
          'Atención veterinaria médica y quirúrgica nocturna y diurna, ambulancia de traslados y farmacia veterinaria permanente.',
    ),

    // 6. Clínica Veterinaria Real de Minas 24H
    DirectoryEntry(
      id: 'vet-real-de-minas-24h',
      name: 'Hospital Veterinario Real de Minas 24 Horas',
      category: DirectoryCategory.veterinary24h,
      municipality: DirectoryMunicipality.bucaramanga,
      neighborhood: 'Ciudadela Real de Minas',
      address: 'Avenida Samanes # 55-12',
      phone: '3123456789',
      whatsapp: '3123456789',
      is24Hours: true,
      openHours: '24 Horas',
      description:
          'Atención de urgencias, cesáreas y politraumatismos con disponibilidad de cirujanos y auxiliares durante toda la noche.',
    ),

    // 7. Fundación Corazón Animal Bucaramanga
    DirectoryEntry(
      id: 'fundacion-corazon-animal',
      name: 'Fundación Corazón Animal Bucaramanga',
      category: DirectoryCategory.foundation,
      municipality: DirectoryMunicipality.bucaramanga,
      neighborhood: 'Provenza / Sede de Acogida',
      address: 'Calle 105 # 22-18',
      phone: '3176543210',
      whatsapp: '3176543210',
      is24Hours: false,
      openHours: 'Lunes a Sábado 9:00 AM - 5:00 PM',
      description:
          'Rescate y rehabilitación de peluditos maltratados o abandonados. Organización de jornadas de adopción responsable y donaciones de alimento.',
    ),

    // 8. Fundación Adopta un Amigo Floridablanca
    DirectoryEntry(
      id: 'fundacion-adopta-amigo-florida',
      name: 'Fundación Adopta un Amigo Floridablanca',
      category: DirectoryCategory.foundation,
      municipality: DirectoryMunicipality.floridablanca,
      neighborhood: 'Lagos I',
      address: 'Carrera 8 # 29-45',
      phone: '3158901234',
      whatsapp: '3158901234',
      is24Hours: false,
      openHours: 'Lunes a Sábado 8:00 AM - 6:00 PM',
      description:
          'Red de hogares de paso en Floridablanca y Ruitoque. Apoyo en cirugías de rescate y jornadas de esterilización a bajo costo.',
    ),

    // 9. Refugio Huellitas Felices Girón
    DirectoryEntry(
      id: 'refugio-huellitas-giron',
      name: 'Refugio Huellitas Felices Girón',
      category: DirectoryCategory.foundation,
      municipality: DirectoryMunicipality.giron,
      neighborhood: 'El Poblado / Casco Antiguo',
      address: 'Calle 43 # 24-10, Girón',
      phone: '3114567890',
      whatsapp: '3114567890',
      is24Hours: false,
      openHours: 'Martes a Domingo 10:00 AM - 4:00 PM',
      description:
          'Albergue comunitario sin ánimo de lucro que acoge más de 60 perros y gatos rescatados en las riberas del Río de Oro y sectores rurales de Girón.',
    ),

    // 10. Fundación Amor Callejero Piedecuesta
    DirectoryEntry(
      id: 'fundacion-amor-callejero-piedecuesta',
      name: 'Fundación Amor Callejero Piedecuesta',
      category: DirectoryCategory.foundation,
      municipality: DirectoryMunicipality.piedecuesta,
      neighborhood: 'Barrio Hoyo Grande',
      address: 'Carrera 4 # 12-32, Piedecuesta',
      phone: '3209876543',
      whatsapp: '3209876543',
      is24Hours: false,
      openHours: 'Lunes a Sábado 9:00 AM - 5:00 PM',
      description:
          'Rescate de animales abandonados, campañas pedagógicas contra el abandono y gestión de jornadas de vacunación en veredas de Piedecuesta.',
    ),

    // 11. Centro de Zoonosis y Bienestar Animal Piedecuesta
    DirectoryEntry(
      id: 'zoonosis-piedecuesta',
      name: 'Centro de Zoonosis y Bienestar Piedecuesta',
      category: DirectoryCategory.welfare,
      municipality: DirectoryMunicipality.piedecuesta,
      neighborhood: 'Vía Guatiguará',
      address: 'Km 1 Vía San Roque / Guatiguará',
      phone: '6076550000',
      is24Hours: false,
      openHours: 'Lunes a Viernes 8:00 AM - 3:00 PM',
      description:
          'Jornadas oficiales de vacunación antirrábica gratuita y esterilizaciones de fauna urbana para estratos 1 y 2 en Piedecuesta.',
    ),

    // 12. GELMA Fiscalía General
    DirectoryEntry(
      id: 'gelma-fiscalia-nacional',
      name: 'GELMA — Fiscalía General de la Nación',
      category: DirectoryCategory.emergencyLine,
      municipality: DirectoryMunicipality.metropolitana,
      neighborhood: 'Seccional Santander',
      address: 'Línea Nacional 122 (Celulares) / Sede Bucaramanga',
      phone: '122',
      is24Hours: true,
      openHours: '24 Horas / Todos los días',
      description:
          'Grupo Especial para la Lucha Contra el Maltrato Animal. Recepción de denuncias penales por delitos contra la vida e integridad animal (Ley 1774).',
    ),
  ];
}
