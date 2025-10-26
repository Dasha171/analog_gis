import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/poi_model.dart';
import '../models/route_model.dart';
import '../models/organization_model.dart';
import '../services/database_service.dart';

class MapProvider extends ChangeNotifier {
  MapController? _mapController;
  latlng.LatLng? _currentLocation;
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  List<POI> _pois = [];
  RouteResult? _currentRoute;
  bool _isLoading = false;
  String _mapStyle = 'standard';
  String _currentLocationText = 'Определяем местоположение...';
  bool _isMapLoaded = false;
  final DatabaseService _databaseService = DatabaseService();

  // Default camera position (Almaty, Kazakhstan)
  static const latlng.LatLng _initialCameraPosition = latlng.LatLng(43.238949, 76.889709);

  // Getters
  MapController? get mapController => _mapController;
  latlng.LatLng? get currentLocation => _currentLocation;
  List<Marker> get markers => _markers;
  List<Polyline> get polylines => _polylines;
  List<POI> get pois => _pois;
  RouteResult? get currentRoute => _currentRoute;
  bool get isLoading => _isLoading;
  String get mapStyle => _mapStyle;
  latlng.LatLng get initialCameraPosition => _initialCameraPosition;
  String get currentLocationText => _currentLocationText;
  bool get isMapLoaded => _isMapLoaded;

  void setMapController(MapController controller) {
    _mapController = controller;
    _isLoading = false;
    _isMapLoaded = true;
    // Clear any existing markers before getting current location
    _markers.clear();
    // Get current location asynchronously (не блокирует UI)
    Future.microtask(() => getCurrentLocation());
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    // Проверяем кэшированную позицию (не старше 5 минут)
    final cachedLocation = await _getCachedLocation();
    if (cachedLocation != null) {
      _currentLocation = cachedLocation;
      _currentLocationText = 'Широта: ${cachedLocation.latitude.toStringAsFixed(6)}, Долгота: ${cachedLocation.longitude.toStringAsFixed(6)}';
      _addCurrentLocationMarker();
      if (_mapController != null) {
        _mapController!.move(_currentLocation!, 15.0);
      }
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Быстрая проверка разрешений
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _useFallbackLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _useFallbackLocation();
        return;
      }

      print('Getting current position...');
      // Используем более быструю точность и короткий timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // Быстрее чем high
        timeLimit: const Duration(seconds: 5), // Короче timeout
      );

      print('Position received: ${position.latitude}, ${position.longitude}');

      _currentLocation = latlng.LatLng(position.latitude, position.longitude);
      _currentLocationText = 'Широта: ${position.latitude.toStringAsFixed(6)}, Долгота: ${position.longitude.toStringAsFixed(6)}';

      // Кэшируем позицию
      await _cacheLocation(_currentLocation!);

      if (_mapController != null) {
        print('Moving map to current location');
        _mapController!.move(_currentLocation!, 15.0);
      }

      _addCurrentLocationMarker();

    } catch (e) {
      print('Error getting current location: $e');
      _useFallbackLocation();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _useFallbackLocation() {
    _currentLocation = const latlng.LatLng(43.238949, 76.889709);
    _currentLocationText = 'Используется местоположение по умолчанию (Алматы)';
    if (_mapController != null) {
      _mapController!.move(_currentLocation!, 15.0);
    }
    _addCurrentLocationMarker();
  }

  // Кэширование геолокации
  Future<void> _cacheLocation(latlng.LatLng location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_latitude', location.latitude.toString());
      await prefs.setString('cached_longitude', location.longitude.toString());
      await prefs.setInt('cached_location_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching location: $e');
    }
  }

  Future<latlng.LatLng?> _getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final latStr = prefs.getString('cached_latitude');
      final lngStr = prefs.getString('cached_longitude');
      final timestamp = prefs.getInt('cached_location_timestamp');

      if (latStr != null && lngStr != null && timestamp != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        // Кэш действителен 5 минут
        if (cacheAge < 5 * 60 * 1000) {
          return latlng.LatLng(double.parse(latStr), double.parse(lngStr));
        }
      }
    } catch (e) {
      print('Error reading cached location: $e');
    }
    return null;
  }

  void _addCurrentLocationMarker() {
    if (_currentLocation != null) {
      // Удаляем все маркеры текущего местоположения
      _markers.removeWhere((marker) => 
          marker.key?.toString() == 'current_location' || 
          marker.key?.toString().contains('current_location') == true);
      
      // Добавляем новый маркер текущего местоположения
      _markers.add(
        Marker(
          key: const ValueKey('current_location'),
          point: _currentLocation!,
          width: 20,
          height: 20,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF0C79FE),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
          ),
        ),
      );
      notifyListeners();
    }
  }

  void addPOI(POI poi) {
    _pois.add(poi);
    _markers.add(
      Marker(
        point: latlng.LatLng(poi.position.latitude, poi.position.longitude),
        child: Icon(
          _getPOIIcon(poi.type),
          color: _getPOIColor(poi.type),
          size: 25,
        ),
      ),
    );
    notifyListeners();
  }

  IconData _getPOIIcon(String type) {
    switch (type.toLowerCase()) {
      case 'restaurant':
      case 'кафе':
        return Icons.restaurant;
      case 'pharmacy':
      case 'аптека':
        return Icons.local_pharmacy;
      case 'shopping':
      case 'магазин':
        return Icons.shopping_cart;
      default:
        return Icons.place;
    }
  }

  Color _getPOIColor(String type) {
    switch (type.toLowerCase()) {
      case 'restaurant':
      case 'кафе':
        return Colors.red;
      case 'pharmacy':
      case 'аптека':
        return Colors.green;
      case 'shopping':
      case 'магазин':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  void setRoute(RouteResult route) {
    _currentRoute = route;
    _polylines.clear();

    if (route.points.isNotEmpty) {
      List<latlng.LatLng> polylinePoints = route.points
          .map((point) => latlng.LatLng(point.latitude, point.longitude))
          .toList();

      // Определяем цвет маршрута
      Color routeColor;
      if (route.transportType == TransportType.car) {
        // Зеленый для самого быстрого маршрута на машине
        routeColor = Colors.green;
      } else if (route.transportType == TransportType.bus) {
        // Синий для маршрута на автобусе (без пробок)
        routeColor = Colors.blue;
      } else {
        // Для остальных видов транспорта используем цвет из маршрута
        routeColor = route.color == RouteColor.green ? Colors.green : Colors.blue;
      }

      _polylines.add(
        Polyline(
          points: polylinePoints,
          color: routeColor,
          strokeWidth: 5,
        ),
      );
    }

    notifyListeners();
  }

  void clearRoute() {
    _currentRoute = null;
    _polylines.clear();
    notifyListeners();
  }

  void toggleMapStyle() {
    _mapStyle = _mapStyle == 'standard' ? 'satellite' : 'standard';
    notifyListeners();
  }

  void moveToLocation(latlng.LatLng location) {
    if (_mapController != null) {
      _mapController!.move(location, _mapController!.camera.zoom);
    }
  }

  void zoomIn() {
    if (_mapController != null) {
      _mapController!.move(_mapController!.camera.center, _mapController!.camera.zoom + 1);
    }
  }

  void zoomOut() {
    if (_mapController != null) {
      _mapController!.move(_mapController!.camera.center, _mapController!.camera.zoom - 1);
    }
  }

  // Методы для работы с маркерами поиска
  void addSearchMarker(Marker marker) {
    _markers.add(marker);
    notifyListeners();
  }

  void removeSearchMarkers() {
    _markers.removeWhere((marker) => 
        marker.key?.toString().startsWith('search_') == true);
    notifyListeners();
  }

  void clearAllMarkers() {
    _markers.clear();
    notifyListeners();
  }

  void clearSearchMarkers() {
    _markers.removeWhere((marker) => 
        marker.key?.toString().startsWith('search_') == true ||
        marker.key?.toString().contains('search_') == true);
    notifyListeners();
  }

  // Загрузка организаций и создание маркеров
  Future<void> loadOrganizations() async {
    try {
      final organizations = await _databaseService.getAllOrganizations();
      
      // Удаляем старые маркеры организаций
      _markers.removeWhere((marker) => 
          marker.key?.toString().startsWith('org_') == true);
      
      // Создаем новые маркеры для организаций
      for (final org in organizations) {
        if (org.latitude != 0.0 && org.longitude != 0.0) {
          final marker = Marker(
            key: ValueKey('org_${org.id}'),
            point: latlng.LatLng(org.latitude, org.longitude),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showOrganizationInfo(org),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          );
          _markers.add(marker);
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Ошибка загрузки организаций: $e');
    }
  }

  void _showOrganizationInfo(Organization org) {
    // TODO: Показать информацию об организации
    print('Организация: ${org.name}');
  }
}