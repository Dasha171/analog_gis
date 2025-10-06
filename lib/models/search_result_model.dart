import 'package:latlong2/latlong.dart' as latlng;

class SearchResult {
  final String id;
  final String name;
  final String address;
  final String type;
  final double? rating;
  final bool isOpen;
  final String? distance;
  final latlng.LatLng? position;
  final String? phone;
  final String? website;
  final String? description;
  final String? openingHours;
  final String? logoUrl;
  
  const SearchResult({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    this.rating,
    this.isOpen = true,
    this.distance,
    this.position,
    this.phone,
    this.website,
    this.description,
    this.openingHours,
    this.logoUrl,
  });
  
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      type: json['type'] ?? '',
      rating: json['rating']?.toDouble(),
      isOpen: json['is_open'] ?? true,
      distance: json['distance'],
      position: json['latitude'] != null && json['longitude'] != null
          ? latlng.LatLng(
              json['latitude']?.toDouble() ?? 0.0,
              json['longitude']?.toDouble() ?? 0.0,
            )
          : null,
      phone: json['phone'],
      website: json['website'],
      description: json['description'],
      openingHours: json['opening_hours'],
      logoUrl: json['logo_url'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'type': type,
      'rating': rating,
      'is_open': isOpen,
      'distance': distance,
      'latitude': position?.latitude,
      'longitude': position?.longitude,
      'phone': phone,
      'website': website,
      'description': description,
      'opening_hours': openingHours,
      'logo_url': logoUrl,
    };
  }
  
  SearchResult copyWith({
    String? id,
    String? name,
    String? address,
    String? type,
    double? rating,
    bool? isOpen,
    String? distance,
    latlng.LatLng? position,
    String? phone,
    String? website,
    String? description,
    String? openingHours,
    String? logoUrl,
  }) {
    return SearchResult(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      isOpen: isOpen ?? this.isOpen,
      distance: distance ?? this.distance,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      description: description ?? this.description,
      openingHours: openingHours ?? this.openingHours,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}

