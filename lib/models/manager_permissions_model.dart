class ManagerPermissions {
  final String managerId;
  final List<String> cityIds;
  final bool canManageAds;
  final bool canManageOrganizations;
  final DateTime createdAt;
  final List<String>? allowedCities;
  final bool canAddAds;

  ManagerPermissions({
    required this.managerId,
    required this.cityIds,
    this.canManageAds = true,
    this.canManageOrganizations = true,
    required this.createdAt,
    this.allowedCities,
    this.canAddAds = true,
  });

  factory ManagerPermissions.fromJson(Map<String, dynamic> json) {
    return ManagerPermissions(
      managerId: json['managerId'] as String,
      cityIds: List<String>.from(json['cityIds'] ?? []),
      canManageAds: json['canManageAds'] as bool? ?? true,
      canManageOrganizations: json['canManageOrganizations'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      allowedCities: json['allowedCities'] != null ? List<String>.from(json['allowedCities']) : null,
      canAddAds: json['canAddAds'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'managerId': managerId,
      'cityIds': cityIds,
      'canManageAds': canManageAds,
      'canManageOrganizations': canManageOrganizations,
      'createdAt': createdAt.toIso8601String(),
      'allowedCities': allowedCities,
      'canAddAds': canAddAds,
    };
  }
}
