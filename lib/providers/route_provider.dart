import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'dart:math' as math;
import '../models/route_model.dart';
import '../services/route_service.dart' as route_service;
import 'map_provider.dart';

class RouteProvider extends ChangeNotifier {
  final route_service.RouteService _routeService = route_service.RouteService();
  
  // Состояние поиска
  List<route_service.SearchResult> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';
  
  // Состояние маршрутов
  List<RouteResult> _routes = [];
  RouteResult? _selectedRoute;
  bool _isBuildingRoute = false;
  
  // Текущие координаты
  double? _currentLat;
  double? _currentLng;
  double? _destinationLat;
  double? _destinationLng;
  String _destinationName = '';
  String _currentLocationName = 'Моё местоположение';
  
  // Режим маршрутизации
  bool _isRouteMode = false;
  
  // Выбранный тип транспорта
  TransportType? _selectedTransportType;
  
  // Контроллер для поля ввода
  final TextEditingController _destinationController = TextEditingController();
  
  // История маршрутов
  List<RouteResult> _routeHistory = [];
  
  // Getters
  List<route_service.SearchResult> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  List<RouteResult> get routes => _routes;
  RouteResult? get selectedRoute => _selectedRoute;
  bool get isBuildingRoute => _isBuildingRoute;
  double? get currentLat => _currentLat;
  double? get currentLng => _currentLng;
  double? get destinationLat => _destinationLat;
  double? get destinationLng => _destinationLng;
  String get destinationName => _destinationName;
  String get currentLocationName => _currentLocationName;
  bool get isRouteMode => _isRouteMode;
  TransportType? get selectedTransportType => _selectedTransportType;
  TextEditingController get destinationController => _destinationController;
  List<RouteResult> get routeHistory => _routeHistory;
  
  /// Установка режима маршрутизации
  void setRouteMode(bool isRouteMode) {
    _isRouteMode = isRouteMode;
    notifyListeners();
  }
  
  /// Установка названия пункта назначения
  void setDestinationName(String name) {
    _destinationName = name;
    notifyListeners();
  }

  /// Установка названия текущего местоположения
  void setCurrentLocationName(String name) {
    _currentLocationName = name;
    notifyListeners();
  }
  
  /// Установка выбранного типа транспорта
  void setSelectedTransportType(TransportType transportType) {
    _selectedTransportType = transportType;
    notifyListeners();
  }
  
  /// Переворот мест отправления и назначения
  void swapLocations() {
    // Меняем местами текущее местоположение и пункт назначения
    final tempLat = _currentLat;
    final tempLng = _currentLng;
    final tempCurrentName = _currentLocationName;
    
    _currentLat = _destinationLat;
    _currentLng = _destinationLng;
    _currentLocationName = _destinationName;
    
    _destinationLat = tempLat;
    _destinationLng = tempLng;
    _destinationName = tempCurrentName;
    
    // Обновляем контроллеры
    _destinationController.text = _destinationName;
    
    notifyListeners();
  }
  
  /// Установка быстрого пункта назначения
  void setQuickDestination(String destination) {
    _destinationName = destination;
    _destinationController.text = destination;
    
    // Имитация координат для быстрых мест
    switch (destination) {
      case 'Дом':
        _destinationLat = 43.238949;
        _destinationLng = 76.889709;
        break;
      case 'Работа':
        _destinationLat = 43.240000;
        _destinationLng = 76.890000;
        break;
    }
    
    notifyListeners();
  }
  
  /// Добавление в историю маршрутов
  void addToRouteHistory(String destinationName) {
    if (_currentLat != null && _currentLng != null && 
        _destinationLat != null && _destinationLng != null) {
      
      final route = RouteResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startLat: _currentLat!,
        startLng: _currentLng!,
        endLat: _destinationLat!,
        endLng: _destinationLng!,
        transportType: _selectedTransportType ?? TransportType.car,
        distance: _calculateDistance(_currentLat!, _currentLng!, _destinationLat!, _destinationLng!) / 1000,
        duration: Duration(seconds: getTransportDuration(_selectedTransportType ?? TransportType.car) ?? 1200),
        cost: 0.0,
        points: [
          LatLng(_currentLat!, _currentLng!),
          LatLng(_destinationLat!, _destinationLng!),
        ],
        color: RouteColor.green,
        hasTraffic: false,
        hasAccidents: false,
        steps: [],
      );
      
      _routeHistory.insert(0, route);
      
      // Ограничиваем историю 10 элементами
      if (_routeHistory.length > 10) {
        _routeHistory = _routeHistory.take(10).toList();
      }
      
      notifyListeners();
    }
  }
  
  /// Получение времени для типа транспорта
  int? getTransportDuration(TransportType transportType) {
    // Имитация расчета времени в зависимости от типа транспорта
    if (_currentLat == null || _currentLng == null || 
        _destinationLat == null || _destinationLng == null) {
      return null;
    }
    
    // Базовое время в минутах для разных типов транспорта
    final baseTimes = {
      TransportType.car: 15,
      TransportType.bus: 25,
      TransportType.walking: 45,
      TransportType.taxi: 12,
      TransportType.bicycle: 20,
      TransportType.scooter: 18,
      TransportType.truck: 30,
    };
    
    return (baseTimes[transportType] ?? 20) * 60; // Конвертируем в секунды
  }
  
  /// Построение маршрута для конкретного типа транспорта
  Future<void> buildRouteForTransport(TransportType transportType) async {
    if (_currentLat == null || _currentLng == null || 
        _destinationLat == null || _destinationLng == null) {
      return;
    }
    
    _isBuildingRoute = true;
    notifyListeners();
    
    try {
      // Имитация построения маршрута
      await Future.delayed(const Duration(seconds: 1));
      
      final route = RouteResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startLat: _currentLat!,
        startLng: _currentLng!,
        endLat: _destinationLat!,
        endLng: _destinationLng!,
        transportType: transportType,
        distance: _calculateDistance(_currentLat!, _currentLng!, _destinationLat!, _destinationLng!) / 1000,
        duration: Duration(seconds: getTransportDuration(transportType) ?? 1200),
        cost: transportType == TransportType.taxi ? 500.0 : 0.0,
        points: [
          LatLng(_currentLat!, _currentLng!),
          LatLng(_destinationLat!, _destinationLng!),
        ],
        color: transportType == TransportType.car ? RouteColor.green : RouteColor.blue,
        hasTraffic: transportType == TransportType.car,
        hasAccidents: false,
        steps: [],
      );
      
      _routes = [route];
      _selectedRoute = route;
      
    } catch (e) {
      print('Ошибка построения маршрута: $e');
    } finally {
      _isBuildingRoute = false;
      notifyListeners();
    }
  }
  
  /// Построение маршрута на карте
  void buildRouteOnMap(RouteResult route) {
    _selectedRoute = route;
    notifyListeners();
    
    // Здесь будет логика отображения маршрута на карте
    print('📍 Построение маршрута на карте: ${route.startLat}, ${route.startLng} → ${route.endLat}, ${route.endLng}');
  }
  
  /// Расчет расстояния между двумя точками
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // Радиус Земли в метрах
    
    final double dLat = (lat2 - lat1) * (3.14159265359 / 180);
    final double dLng = (lng2 - lng1) * (3.14159265359 / 180);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) * 
        math.sin(dLng / 2) * math.sin(dLng / 2);
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }
  
  /// Поиск адресов и организаций
  Future<void> searchAddresses(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }
    
    _isSearching = true;
    _searchQuery = query;
    notifyListeners();
    
    try {
      _searchResults = await _routeService.searchAddresses(query);
      print('🔍 Найдено результатов поиска: ${_searchResults.length}');
    } catch (e) {
      print('❌ Ошибка поиска: $e');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }
  
  /// Выбор пункта назначения
  void selectDestination(route_service.SearchResult result) {
    _destinationLat = result.latitude;
    _destinationLng = result.longitude;
    _destinationName = result.name;
    
    print('📍 Выбран пункт назначения: ${result.name} (${result.latitude}, ${result.longitude})');
    
    // Очищаем результаты поиска
    _searchResults = [];
    _searchQuery = '';
    
    notifyListeners();
  }
  
  /// Установка текущего местоположения
  void setCurrentLocation(double lat, double lng) {
    _currentLat = lat;
    _currentLng = lng;
    print('📍 Установлено текущее местоположение: ($lat, $lng)');
    notifyListeners();
  }
  
  /// Построение маршрутов для всех видов транспорта
  Future<void> buildAllRoutes(BuildContext context) async {
    if (_currentLat == null || _currentLng == null || 
        _destinationLat == null || _destinationLng == null) {
      print('❌ Недостаточно данных для построения маршрута');
      return;
    }
    
    _isBuildingRoute = true;
    _routes = [];
    notifyListeners();
    
    try {
      print('🗺️ Построение маршрутов для всех видов транспорта...');
      
      // Строим маршруты для всех видов транспорта
      final transportTypes = TransportType.values;
      final List<RouteResult> allRoutes = [];
      
      for (final transportType in transportTypes) {
        try {
          final route = await _routeService.buildRoute(
            startLat: _currentLat!,
            startLng: _currentLng!,
            endLat: _destinationLat!,
            endLng: _destinationLng!,
            transportType: transportType,
          );
          allRoutes.add(route);
          print('✅ Маршрут построен: ${route.transportName} - ${route.formattedDuration}');
        } catch (e) {
          print('❌ Ошибка построения маршрута ${transportType.name}: $e');
        }
      }
      
      // Сортируем маршруты по времени
      allRoutes.sort((a, b) => a.duration.compareTo(b.duration));
      
      _routes = allRoutes;
      _selectedRoute = allRoutes.isNotEmpty ? allRoutes.first : null;
      
      // Отправляем маршрут на карту
      if (_selectedRoute != null) {
        // Получаем MapProvider и устанавливаем маршрут
        final mapProvider = Provider.of<MapProvider>(context, listen: false);
        mapProvider.setRoute(_selectedRoute!);
      }
      
      print('✅ Построено маршрутов: ${_routes.length}');
      
    } catch (e) {
      print('❌ Ошибка построения маршрутов: $e');
    } finally {
      _isBuildingRoute = false;
      notifyListeners();
    }
  }
  
  /// Выбор маршрута
  void selectRoute(RouteResult route) {
    _selectedRoute = route;
    print('🗺️ Выбран маршрут: ${route.transportName} - ${route.formattedDuration}');
    notifyListeners();
  }
  
  /// Очистка маршрутов
  void clearRoutes() {
    _routes = [];
    _selectedRoute = null;
    _destinationLat = null;
    _destinationLng = null;
    _destinationName = '';
    notifyListeners();
  }
  
  /// Очистка поиска
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }
  
  /// Получение маршрута по типу транспорта
  RouteResult? getRouteByTransport(TransportType transportType) {
    try {
      return _routes.firstWhere((route) => route.transportType == transportType);
    } catch (e) {
      return null;
    }
  }
  
  /// Проверка, есть ли маршрут для данного типа транспорта
  bool hasRouteForTransport(TransportType transportType) {
    return _routes.any((route) => route.transportType == transportType);
  }
  
  /// Получение лучшего маршрута (самый быстрый)
  RouteResult? get bestRoute {
    if (_routes.isEmpty) return null;
    
    // Ищем зеленый маршрут (самый быстрый)
    final greenRoute = _routes.firstWhere(
      (route) => route.color == RouteColor.green,
      orElse: () => _routes.first,
    );
    
    return greenRoute;
  }
  
  /// Получение альтернативных маршрутов
  List<RouteResult> get alternativeRoutes {
    if (_routes.isEmpty) return [];
    
    final best = bestRoute;
    if (best == null) return _routes;
    
    return _routes.where((route) => route.id != best.id).toList();
  }
}