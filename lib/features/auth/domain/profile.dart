class UserProfile {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? photoUrl;

  const UserProfile({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.photoUrl,
  });

  /// Construye el modelo desde Supabase (JSON)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  /// Convierte el modelo a JSON (si se necesita en el futuro)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'photo_url': photoUrl,
    };
  }

  /// Permite crear una copia modificada del perfil
  UserProfile copyWith({
    String? name,
    String? phone,
    String? photoUrl,
  }) {
    return UserProfile(
      id: id,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
