import 'package:latlong2/latlong.dart' as latlng;

class POI {
  final String id;
  final String name;
  final String address;
  final latlng.LatLng position;
  final String type;
  final String? phone;
  final String? website;
  final String? description;
  final double? rating;
  final bool isOpen;
  final String? openingHours;
  final String? logoUrl;
  final bool isBusinessListing;
  
  const POI({
    required this.id,
    required this.name,
    required this.address,
    required this.position,
    required this.type,
    this.phone,
    this.website,
    this.description,
    this.rating,
    this.isOpen = true,
    this.openingHours,
    this.logoUrl,
    this.isBusinessListing = false,
  });
  
  factory POI.fromJson(Map<String, dynamic> json) {
    return POI(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      position: latlng.LatLng(
        json['latitude']?.toDouble() ?? 0.0,
        json['longitude']?.toDouble() ?? 0.0,
      ),
      type: json['type'] ?? '',
      phone: json['phone'],
      website: json['website'],
      description: json['description'],
      rating: json['rating']?.toDouble(),
      isOpen: json['is_open'] ?? true,
      openingHours: json['opening_hours'],
      logoUrl: json['logo_url'],
      isBusinessListing: json['is_business_listing'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'type': type,
      'phone': phone,
      'website': website,
      'description': description,
      'rating': rating,
      'is_open': isOpen,
      'opening_hours': openingHours,
      'logo_url': logoUrl,
      'is_business_listing': isBusinessListing,
    };
  }
  
  POI copyWith({
    String? id,
    String? name,
    String? address,
    latlng.LatLng? position,
    String? type,
    String? phone,
    String? website,
    String? description,
    double? rating,
    bool? isOpen,
    String? openingHours,
    String? logoUrl,
    bool? isBusinessListing,
  }) {
    return POI(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      position: position ?? this.position,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      isOpen: isOpen ?? this.isOpen,
      openingHours: openingHours ?? this.openingHours,
      logoUrl: logoUrl ?? this.logoUrl,
      isBusinessListing: isBusinessListing ?? this.isBusinessListing,
    );
  }
}

