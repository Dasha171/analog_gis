class Friend {
  final String id;
  final String userId;
  final String friendId;
  final String status; // 'pending', 'accepted', 'declined', 'blocked'
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final bool shareLocation;
  final DateTime? lastLocationUpdate;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.shareLocation = false,
    this.lastLocationUpdate,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] != null 
          ? DateTime.parse(json['acceptedAt'] as String) 
          : null,
      shareLocation: json['shareLocation'] is int ? (json['shareLocation'] as int) == 1 : (json['shareLocation'] as bool? ?? false),
      lastLocationUpdate: json['lastLocationUpdate'] != null 
          ? DateTime.parse(json['lastLocationUpdate'] as String) 
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'shareLocation': shareLocation ? 1 : 0,
      'lastLocationUpdate': lastLocationUpdate?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
    };
  }

  Friend copyWith({
    String? id,
    String? userId,
    String? friendId,
    String? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    bool? shareLocation,
    DateTime? lastLocationUpdate,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    return Friend(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      shareLocation: shareLocation ?? this.shareLocation,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
    );
  }

  bool get isAccepted => status == 'accepted';
  bool get isPending => status == 'pending';
  bool get isDeclined => status == 'declined';
  bool get isBlocked => status == 'blocked';
  
  bool get hasLocation => latitude != null && longitude != null;
  
  String get statusDisplay {
    switch (status) {
      case 'pending': return 'Ожидает подтверждения';
      case 'accepted': return 'Друзья';
      case 'declined': return 'Отклонено';
      case 'blocked': return 'Заблокировано';
      default: return status;
    }
  }
}
