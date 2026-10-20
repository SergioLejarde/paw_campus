class Pet {
  final String id;
  final String name;
  final String species;
  final int age;
  final String description;
  final String photoUrl;
  final String status;
  final String createdBy;
  final String city;
  final String? neighborhood;
  final String size;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.age,
    required this.description,
    required this.photoUrl,
    this.status = 'pending',
    required this.createdBy,
    this.city = 'Bucaramanga',
    this.neighborhood,
    this.size = 'Mediano',
  });

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        id: (json['id'] ?? '').toString(),
        name: json['name'] ?? '',
        species: json['species'] ?? '',
        age: (json['age'] ?? 0) is int
            ? json['age']
            : int.tryParse('${json['age']}') ?? 0,
        description: json['description'] ?? '',
        photoUrl: json['photo_url'] ?? '',
        status: json['status'] ?? 'pending',
        createdBy: (json['created_by'] ?? '').toString(),
        city: json['city'] as String? ?? 'Bucaramanga',
        neighborhood: json['neighborhood'] as String?,
        size: json['size'] as String? ?? 'Mediano',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'species': species,
        'age': age,
        'description': description,
        'photo_url': photoUrl,
        'status': status,
        'created_by': createdBy,
        'city': city,
        'neighborhood': neighborhood,
        'size': size,
      };

  Pet copyWith({
    String? id,
    String? name,
    String? species,
    int? age,
    String? description,
    String? photoUrl,
    String? status,
    String? createdBy,
    String? city,
    String? neighborhood,
    String? size,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      age: age ?? this.age,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      size: size ?? this.size,
    );
  }
}
