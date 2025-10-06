import 'package:latlong2/latlong.dart' as latlng;

class RouteInfo {
  final String id;
  final List<latlng.LatLng> points;
  final double distance; // в километрах
  final int duration; // в минутах
  final String mode; // walking, driving, transit
  final List<RouteStep> steps;
  final latlng.LatLng startPoint;
  final latlng.LatLng endPoint;
  
  const RouteInfo({
    required this.id,
    required this.points,
    required this.distance,
    required this.duration,
    required this.mode,
    required this.steps,
    required this.startPoint,
    required this.endPoint,
  });
  
  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      id: json['id'] ?? '',
      points: (json['points'] as List?)
          ?.map((point) => latlng.LatLng(
                point['latitude']?.toDouble() ?? 0.0,
                point['longitude']?.toDouble() ?? 0.0,
              ))
          .toList() ?? [],
      distance: json['distance']?.toDouble() ?? 0.0,
      duration: json['duration'] ?? 0,
      mode: json['mode'] ?? 'walking',
      steps: (json['steps'] as List?)
          ?.map((step) => RouteStep.fromJson(step))
          .toList() ?? [],
      startPoint: latlng.LatLng(
        json['start_latitude']?.toDouble() ?? 0.0,
        json['start_longitude']?.toDouble() ?? 0.0,
      ),
      endPoint: latlng.LatLng(
        json['end_latitude']?.toDouble() ?? 0.0,
        json['end_longitude']?.toDouble() ?? 0.0,
      ),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      }).toList(),
      'distance': distance,
      'duration': duration,
      'mode': mode,
      'steps': steps.map((step) => step.toJson()).toList(),
      'start_latitude': startPoint.latitude,
      'start_longitude': startPoint.longitude,
      'end_latitude': endPoint.latitude,
      'end_longitude': endPoint.longitude,
    };
  }
}

class RouteStep {
  final String instruction;
  final double distance;
  final int duration;
  final latlng.LatLng startPoint;
  final latlng.LatLng endPoint;
  final String? maneuver; // turn-left, turn-right, straight, etc.
  
  const RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.startPoint,
    required this.endPoint,
    this.maneuver,
  });
  
  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['instruction'] ?? '',
      distance: json['distance']?.toDouble() ?? 0.0,
      duration: json['duration'] ?? 0,
      startPoint: latlng.LatLng(
        json['start_latitude']?.toDouble() ?? 0.0,
        json['start_longitude']?.toDouble() ?? 0.0,
      ),
      endPoint: latlng.LatLng(
        json['end_latitude']?.toDouble() ?? 0.0,
        json['end_longitude']?.toDouble() ?? 0.0,
      ),
      maneuver: json['maneuver'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'instruction': instruction,
      'distance': distance,
      'duration': duration,
      'start_latitude': startPoint.latitude,
      'start_longitude': startPoint.longitude,
      'end_latitude': endPoint.latitude,
      'end_longitude': endPoint.longitude,
      'maneuver': maneuver,
    };
  }
}

