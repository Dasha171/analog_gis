class Advertisement {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String organizationId;
  final String organizationName;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int priority; // 1-10, чем выше, тем важнее
  final String targetAudience; // 'all', 'premium', 'local'
  final Map<String, dynamic> targetLocation; // {'latitude': 0.0, 'longitude': 0.0, 'radius': 1000}
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy; // ID менеджера/админа
  final int viewCount;
  final int clickCount;
  final String? cityId;
  final String? linkUrl;
  final String? status;
  final int? views;
  final int? clicks;
  final String? managerId;
  final String? cityName;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? managerName;

  Advertisement({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.organizationId,
    required this.organizationName,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.priority = 1,
    this.targetAudience = 'all',
    this.targetLocation = const {},
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.viewCount = 0,
    this.clickCount = 0,
    this.cityId,
    this.linkUrl,
    this.status,
    this.views,
    this.clicks,
    this.managerId,
    this.cityName,
    this.approvedAt,
    this.rejectionReason,
    this.managerName,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      organizationId: json['organizationId'] as String,
      organizationName: json['organizationName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] is int ? (json['isActive'] as int) == 1 : (json['isActive'] as bool? ?? true),
      priority: json['priority'] as int? ?? 1,
      targetAudience: json['targetAudience'] as String? ?? 'all',
      targetLocation: Map<String, dynamic>.from(json['targetLocation'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      viewCount: json['viewCount'] as int? ?? 0,
      clickCount: json['clickCount'] as int? ?? 0,
      cityId: json['cityId'] as String?,
      linkUrl: json['linkUrl'] as String?,
      status: json['status'] as String?,
      views: json['views'] as int?,
      clicks: json['clicks'] as int?,
      managerId: json['managerId'] as String?,
      cityName: json['cityName'] as String?,
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt'] as String) : null,
      rejectionReason: json['rejectionReason'] as String?,
      managerName: json['managerName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'priority': priority,
      'targetAudience': targetAudience,
      'targetLocation': targetLocation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'viewCount': viewCount,
      'clickCount': clickCount,
      'cityId': cityId,
      'linkUrl': linkUrl,
      'status': status,
      'views': views,
      'clicks': clicks,
      'managerId': managerId,
      'cityName': cityName,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'managerName': managerName,
    };
  }

  Advertisement copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? organizationId,
    String? organizationName,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? priority,
    String? targetAudience,
    Map<String, dynamic>? targetLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    int? viewCount,
    int? clickCount,
    String? cityId,
    String? linkUrl,
    String? status,
    int? views,
    int? clicks,
    String? managerId,
    String? cityName,
    DateTime? approvedAt,
    String? rejectionReason,
    String? managerName,
  }) {
    return Advertisement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      targetAudience: targetAudience ?? this.targetAudience,
      targetLocation: targetLocation ?? this.targetLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      viewCount: viewCount ?? this.viewCount,
      clickCount: clickCount ?? this.clickCount,
      cityId: cityId ?? this.cityId,
      linkUrl: linkUrl ?? this.linkUrl,
      status: status ?? this.status,
      views: views ?? this.views,
      clicks: clicks ?? this.clicks,
      managerId: managerId ?? this.managerId,
      cityName: cityName ?? this.cityName,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      managerName: managerName ?? this.managerName,
    );
  }

  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  double get clickThroughRate {
    if (viewCount == 0) return 0.0;
    return (clickCount / viewCount) * 100;
  }

  String get advertisementStatus {
    if (!isActive) return 'Неактивна';
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 'Запланирована';
    if (now.isAfter(endDate)) return 'Завершена';
    return 'Активна';
  }
}