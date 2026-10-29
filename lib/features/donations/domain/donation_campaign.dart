/// Categorías para las metas de donación con causa verificada
class CampaignCategory {
  static const String foodBags = 'Bultos de Comida';
  static const String hospitalizationSurgery = 'Hospitalización / Cirugía';
  static const String sterilization = 'Esterilización';
  static const String shelterImprovement = 'Adecuación Refugio';

  static const List<String> all = [
    foodBags,
    hospitalizationSurgery,
    sterilization,
    shelterImprovement,
  ];
}

/// Modelo para una Campaña o Meta de Donación verificada en Bucaramanga y AMB
class DonationCampaign {
  final String id;
  final String title;
  final String foundationName;
  final String municipality;
  final String category;
  final String description;
  final int targetAmountCop;
  final int raisedAmountCop;
  final int daysLeft;
  final String? petOrBeneficiaryName;
  final String photoUrl;
  final String? verifiedInvoiceCode;

  const DonationCampaign({
    required this.id,
    required this.title,
    required this.foundationName,
    required this.municipality,
    required this.category,
    required this.description,
    required this.targetAmountCop,
    required this.raisedAmountCop,
    required this.daysLeft,
    this.petOrBeneficiaryName,
    required this.photoUrl,
    this.verifiedInvoiceCode,
  });

  /// Progreso de la campaña de 0.0 a 1.0 (clamped)
  double get progressRatio {
    if (targetAmountCop <= 0) return 0.0;
    return (raisedAmountCop / targetAmountCop).clamp(0.0, 1.0);
  }

  /// Porcentaje entero (0 a 100)
  int get progressPercentage => (progressRatio * 100).toInt();

  /// Formato abreviado de la meta (ej. $4.5M o $1.85M)
  String get formattedTargetShort {
    if (targetAmountCop >= 1000000) {
      final millions = targetAmountCop / 1000000;
      final formatted = millions.toStringAsFixed(millions.truncateToDouble() == millions ? 0 : 1);
      return '\$${formatted}M';
    }
    return '\$${targetAmountCop ~/ 1000}K';
  }

  /// Formato completo en COP (ej. $4.500.000 COP)
  String get formattedTargetCop => _formatCop(targetAmountCop);

  /// Formato completo recaudado en COP (ej. $3.150.000 COP)
  String get formattedRaisedCop => _formatCop(raisedAmountCop);

  /// Resumen textual de progreso
  String get progressSummary => '$progressPercentage% de $formattedTargetShort recaudados • $daysLeft días restantes';

  static String _formatCop(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return '\$${buffer.toString().split('').reversed.join()} COP';
  }

  factory DonationCampaign.fromJson(Map<String, dynamic> json) {
    return DonationCampaign(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      foundationName: (json['foundation_name'] ?? json['foundationName'] ?? '').toString(),
      municipality: (json['municipality'] ?? '').toString(),
      category: (json['category'] ?? CampaignCategory.foodBags).toString(),
      description: (json['description'] ?? '').toString(),
      targetAmountCop: (json['target_amount_cop'] ?? json['targetAmountCop'] ?? 0) as int,
      raisedAmountCop: (json['raised_amount_cop'] ?? json['raisedAmountCop'] ?? 0) as int,
      daysLeft: (json['days_left'] ?? json['daysLeft'] ?? 0) as int,
      petOrBeneficiaryName: json['pet_or_beneficiary_name'] as String? ?? json['petOrBeneficiaryName'] as String?,
      photoUrl: (json['photo_url'] ?? json['photoUrl'] ?? '').toString(),
      verifiedInvoiceCode: json['verified_invoice_code'] as String? ?? json['verifiedInvoiceCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'foundation_name': foundationName,
      'municipality': municipality,
      'category': category,
      'description': description,
      'target_amount_cop': targetAmountCop,
      'raised_amount_cop': raisedAmountCop,
      'days_left': daysLeft,
      'pet_or_beneficiary_name': petOrBeneficiaryName,
      'photo_url': photoUrl,
      'verified_invoice_code': verifiedInvoiceCode,
    };
  }

  DonationCampaign copyWith({
    String? id,
    String? title,
    String? foundationName,
    String? municipality,
    String? category,
    String? description,
    int? targetAmountCop,
    int? raisedAmountCop,
    int? daysLeft,
    String? petOrBeneficiaryName,
    String? photoUrl,
    String? verifiedInvoiceCode,
  }) {
    return DonationCampaign(
      id: id ?? this.id,
      title: title ?? this.title,
      foundationName: foundationName ?? this.foundationName,
      municipality: municipality ?? this.municipality,
      category: category ?? this.category,
      description: description ?? this.description,
      targetAmountCop: targetAmountCop ?? this.targetAmountCop,
      raisedAmountCop: raisedAmountCop ?? this.raisedAmountCop,
      daysLeft: daysLeft ?? this.daysLeft,
      petOrBeneficiaryName: petOrBeneficiaryName ?? this.petOrBeneficiaryName,
      photoUrl: photoUrl ?? this.photoUrl,
      verifiedInvoiceCode: verifiedInvoiceCode ?? this.verifiedInvoiceCode,
    );
  }

  /// 5 Campañas activas realistas en Bucaramanga y el AMB
  static const List<DonationCampaign> activeCampaigns = [
    // 1. Meta de Alimentación
    DonationCampaign(
      id: 'camp-alimento-giron-bga',
      title: '45 Bultos de Concentrado Adulto y Cachorro para Refugio en Girón y Bucaramanga',
      foundationName: 'Fundación Corazón Animal & Refugio Huellitas Felices',
      municipality: 'Girón y Bucaramanga',
      category: CampaignCategory.foodBags,
      description:
          'Garantiza alimento balanceado para 110 perros y gatos rescatados durante el próximo mes en el albergue de Girón y hogares de paso.',
      targetAmountCop: 4500000,
      raisedAmountCop: 3150000,
      daysLeft: 8,
      petOrBeneficiaryName: '110 Rescatados del Refugio',
      photoUrl:
          'https://images.unsplash.com/photo-1548767797-d8c844163c4c?auto=format&fit=crop&w=800&q=80',
      verifiedInvoiceCode: 'AUD-COL-2026-441',
    ),

    // 2. Meta de Hospitalización Urgente
    DonationCampaign(
      id: 'camp-cirugia-toby-piede',
      title: 'Hospitalización y Cirugía Ortopédica de "Toby" (Perrito criollo atropellado en Piedecuesta)',
      foundationName: 'Clínica Aliada 24H & Fundación Amor Callejero',
      municipality: 'Piedecuesta',
      category: CampaignCategory.hospitalizationSurgery,
      description:
          'Toby sufrió una fractura de fémur tras ser atropellado en la vía Piedecuesta. Requiere osteosíntesis, clavos quirúrgicos y 5 días de internación con analgesia.',
      targetAmountCop: 1850000,
      raisedAmountCop: 1295000,
      daysLeft: 4,
      petOrBeneficiaryName: 'Toby (Criollo rescatado)',
      photoUrl:
          'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&q=80',
      verifiedInvoiceCode: 'FV-2026-884',
    ),

    // 3. Meta de Hospitalización Felina
    DonationCampaign(
      id: 'camp-uci-luna-florida',
      title: 'Tratamiento UCI y Medicamentos para "Luna" y 4 gatitos rescatados en Floridablanca',
      foundationName: 'Fundación Adopta un Amigo Floridablanca',
      municipality: 'Floridablanca',
      category: CampaignCategory.hospitalizationSurgery,
      description:
          'Luna y su camada recién nacida fueron encontrados en condición de hipotermia en Cañaveral. Necesitan incubadora, sueros pediátricos y control veterinario continuo.',
      targetAmountCop: 1200000,
      raisedAmountCop: 840000,
      daysLeft: 6,
      petOrBeneficiaryName: 'Luna y 4 Gatitos',
      photoUrl:
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
      verifiedInvoiceCode: 'FV-2026-902',
    ),

    // 4. Meta de Alimento y Cuidado Renal
    DonationCampaign(
      id: 'camp-renal-senior-cabecera',
      title: '30 Bultos de Arena y Alimento Renal para Gatos Senior Rescatados en Cabecera/Sotomayor',
      foundationName: 'Red de Hogares de Paso Bucaramanga',
      municipality: 'Bucaramanga',
      category: CampaignCategory.foodBags,
      description:
          '18 gatitos de la tercera edad con afecciones renales dependen de concentrado especializado Renal y arena aglutinante hipoalergénica para su calidad de vida.',
      targetAmountCop: 2400000,
      raisedAmountCop: 1320000,
      daysLeft: 12,
      petOrBeneficiaryName: '18 Gatos Senior',
      photoUrl:
          'https://images.unsplash.com/photo-1573865526739-10659fec78a5?auto=format&fit=crop&w=800&q=80',
      verifiedInvoiceCode: 'AUD-BGA-2026-319',
    ),

    // 5. Meta de Esterilización
    DonationCampaign(
      id: 'camp-esterilizacion-norte-bga',
      title: 'Jornada Gratuita de 60 Esterilizaciones en Barrios vulnerables del Norte de Bucaramanga',
      foundationName: 'Unidad de Bienestar Animal (UBA) & Voluntariado PawCol',
      municipality: 'Bucaramanga',
      category: CampaignCategory.sterilization,
      description:
          'Frenar la sobrepoblación y el abandono en asentamientos del Norte (Comuna 1 y 2). La meta cubre insumos quirúrgicos, anestesia y kits de recuperación postoperatoria para 60 animalitos.',
      targetAmountCop: 3600000,
      raisedAmountCop: 2880000,
      daysLeft: 10,
      petOrBeneficiaryName: '60 Mascotas de la Comuna 1 y 2',
      photoUrl:
          'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
      verifiedInvoiceCode: 'JORN-ST-2026-06',
    ),
  ];
}
