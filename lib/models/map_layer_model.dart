class MapLayer {
  final String id;
  final String name;
  final String icon;
  final bool isEnabled;
  final String description;

  MapLayer({
    required this.id,
    required this.name,
    required this.icon,
    this.isEnabled = false,
    this.description = '',
  });

  MapLayer copyWith({
    String? id,
    String? name,
    String? icon,
    bool? isEnabled,
    String? description,
  }) {
    return MapLayer(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isEnabled: isEnabled ?? this.isEnabled,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isEnabled': isEnabled,
      'description': description,
    };
  }

  factory MapLayer.fromJson(Map<String, dynamic> json) {
    return MapLayer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      isEnabled: json['isEnabled'] ?? false,
      description: json['description'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapLayer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MapLayer(id: $id, name: $name, isEnabled: $isEnabled)';
  }
}
