import 'package:latlong2/latlong.dart' as latlng;

class SearchResult {
  final String id;
  final String name;
  final String address;
  final String category;
  final latlng.LatLng position;
  final double rating;
  final int reviewCount;
  final String? phone;
  final String? website;
  final String? description;
  final List<String> images;
  final Map<String, dynamic> additionalInfo;

  SearchResult({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.position,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.phone,
    this.website,
    this.description,
    this.images = const [],
    this.additionalInfo = const {},
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      category: json['category'] ?? '',
      position: latlng.LatLng(
        json['latitude'] ?? 0.0,
        json['longitude'] ?? 0.0,
      ),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      phone: json['phone'],
      website: json['website'],
      description: json['description'],
      images: List<String>.from(json['images'] ?? []),
      additionalInfo: Map<String, dynamic>.from(json['additionalInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'category': category,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'rating': rating,
      'reviewCount': reviewCount,
      'phone': phone,
      'website': website,
      'description': description,
      'images': images,
      'additionalInfo': additionalInfo,
    };
  }

  // Calculate distance from current location (simplified)
  double calculateDistance(latlng.LatLng from) {
    final distance = latlng.Distance();
    return distance.as(latlng.LengthUnit.Kilometer, from, position);
  }

  String getDistanceText(latlng.LatLng from) {
    final distance = calculateDistance(from);
    if (distance < 1) {
      return '${(distance * 1000).round()} м';
    } else {
      return '${distance.toStringAsFixed(1)} км';
    }
  }

  String getRatingText() {
    if (rating == 0.0) return 'Нет оценок';
    return '$rating (${reviewCount} отзывов)';
  }
}