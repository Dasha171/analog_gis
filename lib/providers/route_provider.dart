import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;

enum TransportMode {
  car,
  bus,
  pedestrian,
  taxi,
  bicycle,
  scooter,
  truck,
}

class RouteProvider extends ChangeNotifier {
  String _fromLocation = 'Моё местоположение';
  String _toLocation = '';
  bool _isRouteMode = false;
  TransportMode _selectedTransport = TransportMode.car;
  latlng.LatLng? _fromPosition;
  latlng.LatLng? _toPosition;

  // Getters
  String get fromLocation => _fromLocation;
  String get toLocation => _toLocation;
  bool get isRouteMode => _isRouteMode;
  TransportMode get selectedTransport => _selectedTransport;
  latlng.LatLng? get fromPosition => _fromPosition;
  latlng.LatLng? get toPosition => _toPosition;

  void setRouteMode(bool isRouteMode) {
    _isRouteMode = isRouteMode;
    if (!isRouteMode) {
      // Reset when closing route mode
      _toLocation = '';
      _toPosition = null;
    }
    notifyListeners();
  }

  void setFromLocation(String location, {latlng.LatLng? position}) {
    _fromLocation = location;
    _fromPosition = position;
    notifyListeners();
  }

  void setToLocation(String location, {latlng.LatLng? position}) {
    _toLocation = location;
    _toPosition = position;
    notifyListeners();
  }

  void swapLocations() {
    final tempLocation = _fromLocation;
    final tempPosition = _fromPosition;
    
    _fromLocation = _toLocation.isEmpty ? 'Куда?' : _toLocation;
    _fromPosition = _toPosition;
    
    _toLocation = tempLocation;
    _toPosition = tempPosition;
    
    notifyListeners();
  }

  void setTransportMode(TransportMode mode) {
    _selectedTransport = mode;
    notifyListeners();
  }

  void setCurrentLocationAsFrom(latlng.LatLng position) {
    _fromLocation = 'Моё местоположение';
    _fromPosition = position;
    notifyListeners();
  }

  // Get transport mode icon
  IconData getTransportIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.car:
        return Icons.directions_car;
      case TransportMode.bus:
        return Icons.directions_bus;
      case TransportMode.pedestrian:
        return Icons.directions_walk;
      case TransportMode.taxi:
        return Icons.local_taxi;
      case TransportMode.bicycle:
        return Icons.directions_bike;
      case TransportMode.scooter:
        return Icons.electric_scooter;
      case TransportMode.truck:
        return Icons.local_shipping;
    }
  }

  // Get transport mode name
  String getTransportName(TransportMode mode) {
    switch (mode) {
      case TransportMode.car:
        return 'Автомобиль';
      case TransportMode.bus:
        return 'Автобус';
      case TransportMode.pedestrian:
        return 'Пешком';
      case TransportMode.taxi:
        return 'Такси';
      case TransportMode.bicycle:
        return 'Велосипед';
      case TransportMode.scooter:
        return 'Самокат';
      case TransportMode.truck:
        return 'Грузовик';
    }
  }

  bool canBuildRoute() {
    return _fromPosition != null && _toPosition != null;
  }
}
