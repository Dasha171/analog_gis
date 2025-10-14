class VerificationCode {
  final String email;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;

  VerificationCode({
    required this.email,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isValid => !isUsed && !isExpired;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isUsed': isUsed,
    };
  }

  factory VerificationCode.fromJson(Map<String, dynamic> json) {
    return VerificationCode(
      email: json['email'] ?? '',
      code: json['code'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: DateTime.parse(json['expiresAt'] ?? DateTime.now().toIso8601String()),
      isUsed: json['isUsed'] ?? false,
    );
  }

  VerificationCode copyWith({
    String? email,
    String? code,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isUsed,
  }) {
    return VerificationCode(
      email: email ?? this.email,
      code: code ?? this.code,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isUsed: isUsed ?? this.isUsed,
    );
  }
}
