class Organization {
  final String id;
  final String businessUserId;
  final String name;
  final String address;
  final String phone;
  final String category;
  final String? website;
  final double rating;
  final int viewsPerMonth;
  final int routesBuilt;
  final int promotionsActivated;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? latitude;
  final double? longitude;

  Organization({
    required this.id,
    required this.businessUserId,
    required this.name,
    required this.address,
    required this.phone,
    required this.category,
    this.website,
    this.rating = 0.0,
    this.viewsPerMonth = 0,
    this.routesBuilt = 0,
    this.promotionsActivated = 0,
    this.isPublished = false,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessUserId': businessUserId,
      'name': name,
      'address': address,
      'phone': phone,
      'category': category,
      'website': website,
      'rating': rating,
      'viewsPerMonth': viewsPerMonth,
      'routesBuilt': routesBuilt,
      'promotionsActivated': promotionsActivated,
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      businessUserId: json['businessUserId'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      category: json['category'],
      website: json['website'],
      rating: json['rating']?.toDouble() ?? 0.0,
      viewsPerMonth: json['viewsPerMonth'] ?? 0,
      routesBuilt: json['routesBuilt'] ?? 0,
      promotionsActivated: json['promotionsActivated'] ?? 0,
      isPublished: json['isPublished'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Organization copyWith({
    String? id,
    String? businessUserId,
    String? name,
    String? address,
    String? phone,
    String? category,
    String? website,
    double? rating,
    int? viewsPerMonth,
    int? routesBuilt,
    int? promotionsActivated,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
  }) {
    return Organization(
      id: id ?? this.id,
      businessUserId: businessUserId ?? this.businessUserId,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      website: website ?? this.website,
      rating: rating ?? this.rating,
      viewsPerMonth: viewsPerMonth ?? this.viewsPerMonth,
      routesBuilt: routesBuilt ?? this.routesBuilt,
      promotionsActivated: promotionsActivated ?? this.promotionsActivated,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
