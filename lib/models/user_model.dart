class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool isEmailVerified;
  final String role; // 'admin', 'manager', 'business', 'user'
  final bool isBlocked;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.createdAt,
    required this.isEmailVerified,
    this.role = 'user',
    this.isBlocked = false,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isEmailVerified: json['isEmailVerified'] is int ? (json['isEmailVerified'] as int) == 1 : (json['isEmailVerified'] as bool? ?? false),
      role: json['role'] as String? ?? 'user',
      isBlocked: json['isBlocked'] is int ? (json['isBlocked'] as int) == 1 : (json['isBlocked'] as bool? ?? false),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'isEmailVerified': isEmailVerified ? 1 : 0,
      'role': role,
      'isBlocked': isBlocked ? 1 : 0,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? isEmailVerified,
    String? role,
    bool? isBlocked,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
      isBlocked: isBlocked ?? this.isBlocked,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
  
  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get isBusiness => role == 'business';
}