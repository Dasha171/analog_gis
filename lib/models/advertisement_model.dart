import 'dart:convert';

class City {
  final String id;
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  City({
    required this.id,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class Advertisement {
  final String id;
  final String title;
  final String imageUrl;
  final String linkUrl;
  final String cityId;
  final String cityName;
  final String managerId;
  final String managerName;
  final DateTime createdAt;
  final String status; // 'pending', 'approved', 'rejected', 'blocked'
  final String? rejectionReason;
  final DateTime? approvedAt;
  final int views;
  final int clicks;

  Advertisement({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.linkUrl,
    required this.cityId,
    required this.cityName,
    required this.managerId,
    required this.managerName,
    required this.createdAt,
    required this.status,
    this.rejectionReason,
    this.approvedAt,
    this.views = 0,
    this.clicks = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'cityId': cityId,
      'cityName': cityName,
      'managerId': managerId,
      'managerName': managerName,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'rejectionReason': rejectionReason,
      'approvedAt': approvedAt?.toIso8601String(),
      'views': views,
      'clicks': clicks,
    };
  }

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      linkUrl: json['linkUrl'],
      cityId: json['cityId'],
      cityName: json['cityName'],
      managerId: json['managerId'],
      managerName: json['managerName'],
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
      rejectionReason: json['rejectionReason'],
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      views: json['views'] ?? 0,
      clicks: json['clicks'] ?? 0,
    );
  }

  Advertisement copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? linkUrl,
    String? cityId,
    String? cityName,
    String? managerId,
    String? managerName,
    DateTime? createdAt,
    String? status,
    String? rejectionReason,
    DateTime? approvedAt,
    int? views,
    int? clicks,
  }) {
    return Advertisement(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedAt: approvedAt ?? this.approvedAt,
      views: views ?? this.views,
      clicks: clicks ?? this.clicks,
    );
  }
}

class ManagerPermissions {
  final String managerId;
  final List<String> allowedCities;
  final bool canAddAds;
  final bool canEditAds;
  final bool canDeleteAds;
  final DateTime createdAt;
  final DateTime? expiresAt;

  ManagerPermissions({
    required this.managerId,
    required this.allowedCities,
    required this.canAddAds,
    required this.canEditAds,
    required this.canDeleteAds,
    required this.createdAt,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'managerId': managerId,
      'allowedCities': allowedCities,
      'canAddAds': canAddAds,
      'canEditAds': canEditAds,
      'canDeleteAds': canDeleteAds,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory ManagerPermissions.fromJson(Map<String, dynamic> json) {
    return ManagerPermissions(
      managerId: json['managerId'],
      allowedCities: List<String>.from(json['allowedCities']),
      canAddAds: json['canAddAds'],
      canEditAds: json['canEditAds'],
      canDeleteAds: json['canDeleteAds'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }
}
