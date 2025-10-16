class BusinessUser {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final double rating;
  final int totalOrganizations;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  BusinessUser({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    this.rating = 0.0,
    this.totalOrganizations = 0,
    required this.createdAt,
    required this.lastLoginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'totalOrganizations': totalOrganizations,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  factory BusinessUser.fromJson(Map<String, dynamic> json) {
    return BusinessUser(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      phone: json['phone'],
      profileImageUrl: json['profileImageUrl'],
      rating: json['rating']?.toDouble() ?? 0.0,
      totalOrganizations: json['totalOrganizations'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
    );
  }

  BusinessUser copyWith({
    String? id,
    String? name,
    String? surname,
    String? email,
    String? phone,
    String? profileImageUrl,
    double? rating,
    int? totalOrganizations,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return BusinessUser(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      totalOrganizations: totalOrganizations ?? this.totalOrganizations,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
