import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geolocator/geolocator.dart';
import '../models/poi_model.dart';
import '../models/route_model.dart';

class MapProvider extends ChangeNotifier {
  MapController? _mapController;
  latlng.LatLng? _currentLocation;
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  List<POI> _pois = [];
  RouteInfo? _currentRoute;
  bool _isLoading = false;
  String _mapStyle = 'standard';
  String _currentLocationText = 'Определяем местоположение...';
  bool _isMapLoaded = false;

  // Default camera position (Almaty, Kazakhstan)
  static const latlng.LatLng _initialCameraPosition = latlng.LatLng(43.238949, 76.889709);

  // Getters
  MapController? get mapController => _mapController;
  latlng.LatLng? get currentLocation => _currentLocation;
  List<Marker> get markers => _markers;
  List<Polyline> get polylines => _polylines;
  List<POI> get pois => _pois;
  RouteInfo? get currentRoute => _currentRoute;
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
    // Get current location when map is created
    getCurrentLocation();
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        _isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied');
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permission denied forever');
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('Getting current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('Position received: ${position.latitude}, ${position.longitude}');

      _currentLocation = latlng.LatLng(position.latitude, position.longitude);
      _currentLocationText = 'Широта: ${position.latitude.toStringAsFixed(6)}, Долгота: ${position.longitude.toStringAsFixed(6)}';

      if (_mapController != null) {
        print('Moving map to current location');
        _mapController!.move(_currentLocation!, 15.0);
      }

      // Add current location marker
      _addCurrentLocationMarker();

    } catch (e) {
      print('Error getting current location: $e');
      // Fallback to Almaty if geolocation fails
      _currentLocation = const latlng.LatLng(43.238949, 76.889709);
      if (_mapController != null) {
        _mapController!.move(_currentLocation!, 15.0);
      }
      _addCurrentLocationMarker();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  void setRoute(RouteInfo route) {
    _currentRoute = route;
    _polylines.clear();

    if (route.points.isNotEmpty) {
      List<latlng.LatLng> polylinePoints = route.points
          .map((point) => latlng.LatLng(point.latitude, point.longitude))
          .toList();

      _polylines.add(
        Polyline(
          points: polylinePoints,
          color: Colors.blue,
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
}