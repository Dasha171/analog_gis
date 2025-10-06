import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_model.dart';

class NavigationService {
  static const String _baseUrl = 'https://api.openrouteservice.org/v2';
  static const String _apiKey = 'YOUR_API_KEY'; // Замените на реальный API ключ
  
  /// Построение маршрута между двумя точками
  static Future<RouteInfo?> getRoute({
    required LatLng start,
    required LatLng end,
    required String mode, // driving, walking, cycling
  }) async {
    try {
      final profile = _getProfile(mode);
      final url = '$_baseUrl/directions/$profile?api_key=$_apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseRouteResponse(data, start, end, mode);
      }
    } catch (e) {
      print('Error getting route: $e');
      // Возвращаем моковый маршрут для демонстрации
      return _createMockRoute(start, end, mode);
    }
    
    return null;
  }
  
  static String _getProfile(String mode) {
    switch (mode) {
      case 'walking':
        return 'foot-walking';
      case 'cycling':
        return 'cycling-regular';
      case 'driving':
      default:
        return 'driving-car';
    }
  }
  
  static RouteInfo _parseRouteResponse(Map<String, dynamic> data, LatLng start, LatLng end, String mode) {
    final features = data['features'] as List;
    if (features.isEmpty) {
      return _createMockRoute(start, end, mode);
    }
    
    final feature = features.first;
    final properties = feature['properties'];
    final geometry = feature['geometry'];
    
    final coordinates = geometry['coordinates'] as List;
    final points = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
    
    final summary = properties['summary'];
    final distance = summary['distance'] / 1000; // Конвертируем в км
    final duration = summary['duration'] / 60; // Конвертируем в минуты
    
    final segments = properties['segments'] as List;
    final steps = segments.expand((segment) {
      final segmentSteps = segment['steps'] as List;
      return segmentSteps.map((step) => _parseRouteStep(step));
    }).toList();
    
    return RouteInfo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      points: points,
      distance: distance,
      duration: duration.toInt(),
      mode: mode,
      steps: steps,
      startPoint: start,
      endPoint: end,
    );
  }
  
  static RouteStep _parseRouteStep(Map<String, dynamic> step) {
    final instruction = step['instruction'] ?? '';
    final distance = step['distance'] / 1000; // Конвертируем в км
    final duration = step['duration'] / 60; // Конвертируем в минуты
    
    final wayPoints = step['way_points'] as List;
    final startIndex = wayPoints.first;
    final endIndex = wayPoints.last;
    
    // Для упрощения, создаем фиктивные координаты
    final startPoint = const LatLng(43.238949, 76.889709);
    final endPoint = const LatLng(43.238949, 76.889709);
    
    return RouteStep(
      instruction: instruction,
      distance: distance,
      duration: duration.toInt(),
      startPoint: startPoint,
      endPoint: endPoint,
      maneuver: step['maneuver']?['type'],
    );
  }
  
  /// Создание мокового маршрута для демонстрации
  static RouteInfo _createMockRoute(LatLng start, LatLng end, String mode) {
    // Создаем простой прямой маршрут
    final points = [start, end];
    
    // Рассчитываем примерное расстояние и время
    final distance = _calculateDistance(start, end);
    final duration = _calculateDuration(distance, mode);
    
    return RouteInfo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      points: points,
      distance: distance,
      duration: duration,
      mode: mode,
      steps: [
        RouteStep(
          instruction: 'Начните движение',
          distance: distance,
          duration: duration,
          startPoint: start,
          endPoint: end,
          maneuver: 'depart',
        ),
        RouteStep(
          instruction: 'Вы прибыли в пункт назначения',
          distance: 0,
          duration: 0,
          startPoint: end,
          endPoint: end,
          maneuver: 'arrive',
        ),
      ],
      startPoint: start,
      endPoint: end,
    );
  }
  
  static double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Радиус Земли в км
    
    final lat1Rad = start.latitude * (3.14159265359 / 180);
    final lat2Rad = end.latitude * (3.14159265359 / 180);
    final deltaLatRad = (end.latitude - start.latitude) * (3.14159265359 / 180);
    final deltaLngRad = (end.longitude - start.longitude) * (3.14159265359 / 180);
    
    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    
    final c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }
  
  static int _calculateDuration(double distance, String mode) {
    double speed; // км/ч
    
    switch (mode) {
      case 'walking':
        speed = 5;
        break;
      case 'cycling':
        speed = 15;
        break;
      case 'driving':
      default:
        speed = 50;
        break;
    }
    
    return (distance / speed * 60).round();
  }
  
  /// Поиск POI в радиусе
  static Future<List<LatLng>> searchNearbyPOI({
    required LatLng location,
    required String type,
    double radius = 1000, // в метрах
  }) async {
    // В реальном приложении здесь будет запрос к API
    // Пока возвращаем моковые данные
    return [
      LatLng(location.latitude + 0.001, location.longitude + 0.001),
      LatLng(location.latitude - 0.001, location.longitude - 0.001),
      LatLng(location.latitude + 0.002, location.longitude - 0.001),
    ];
  }
}
