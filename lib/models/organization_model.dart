class Organization {
  final String id;
  final String name;
  final String description;
  final String category; // 'restaurant', 'cafe', 'shop', 'service', etc.
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String website;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String ownerId; // ID пользователя-владельца
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isVerified;
  final Map<String, dynamic> workingHours; // {'monday': '9:00-21:00', ...}
  final List<String> amenities; // ['wifi', 'parking', 'delivery', ...]
  final double priceRange; // 1-5 stars for price level
  final bool isPublished;
  final int viewsPerMonth;
  final int routesBuilt;
  final int promotionsActivated;

  Organization({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.website,
    this.images = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isVerified = false,
    this.workingHours = const {},
    this.amenities = const [],
    this.priceRange = 1.0,
    this.isPublished = false,
    this.viewsPerMonth = 0,
    this.routesBuilt = 0,
    this.promotionsActivated = 0,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String,
      email: json['email'] as String,
      website: json['website'] as String,
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] is int ? (json['isActive'] as int) == 1 : (json['isActive'] as bool? ?? true),
      isVerified: json['isVerified'] is int ? (json['isVerified'] as int) == 1 : (json['isVerified'] as bool? ?? false),
      workingHours: Map<String, dynamic>.from(json['workingHours'] ?? {}),
      amenities: List<String>.from(json['amenities'] ?? []),
      priceRange: (json['priceRange'] as num?)?.toDouble() ?? 1.0,
      isPublished: json['isPublished'] is int ? (json['isPublished'] as int) == 1 : (json['isPublished'] as bool? ?? false),
      viewsPerMonth: json['viewsPerMonth'] as int? ?? 0,
      routesBuilt: json['routesBuilt'] as int? ?? 0,
      promotionsActivated: json['promotionsActivated'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'website': website,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'isVerified': isVerified ? 1 : 0,
      'workingHours': workingHours,
      'amenities': amenities,
      'priceRange': priceRange,
      'isPublished': isPublished ? 1 : 0,
      'viewsPerMonth': viewsPerMonth,
      'routesBuilt': routesBuilt,
      'promotionsActivated': promotionsActivated,
    };
  }

  Organization copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    List<String>? images,
    double? rating,
    int? reviewCount,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isVerified,
    Map<String, dynamic>? workingHours,
    List<String>? amenities,
    double? priceRange,
    bool? isPublished,
    int? viewsPerMonth,
    int? routesBuilt,
    int? promotionsActivated,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      workingHours: workingHours ?? this.workingHours,
      amenities: amenities ?? this.amenities,
      priceRange: priceRange ?? this.priceRange,
      isPublished: isPublished ?? this.isPublished,
      viewsPerMonth: viewsPerMonth ?? this.viewsPerMonth,
      routesBuilt: routesBuilt ?? this.routesBuilt,
      promotionsActivated: promotionsActivated ?? this.promotionsActivated,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case 'restaurant': return 'Ресторан';
      case 'cafe': return 'Кафе';
      case 'shop': return 'Магазин';
      case 'service': return 'Услуги';
      case 'hotel': return 'Отель';
      case 'pharmacy': return 'Аптека';
      case 'bank': return 'Банк';
      case 'gas_station': return 'АЗС';
      default: return category;
    }
  }

  String get ratingDisplay => rating > 0 ? rating.toStringAsFixed(1) : 'Нет оценок';
}