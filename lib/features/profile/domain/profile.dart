class UserProfile {
  final String id; // = auth.users.id
  final String? email;
  final String? name;
  final String? phone;
  final String? photoUrl;
  final String city;
  final bool isAdmin;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    this.email,
    this.name,
    this.phone,
    this.photoUrl,
    this.city = 'Bucaramanga',
    this.isAdmin = false,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] ?? '').toString(),
      email: json['email'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      photoUrl: json['photo_url'] as String?,
      city: json['city'] as String? ?? 'Bucaramanga',
      isAdmin: json['is_admin'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'photo_url': photoUrl,
      'city': city,
      'is_admin': isAdmin,
    };
  }

  UserProfile copyWith({
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    String? city,
    bool? isAdmin,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      city: city ?? this.city,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt,
    );
  }
}
