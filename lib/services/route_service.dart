import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../models/organization_model.dart';

class RouteService {
  static final RouteService _instance = RouteService._internal();
  factory RouteService() => _instance;
  RouteService._internal();

  /// Поиск адресов и организаций
  Future<List<SearchResult>> searchAddresses(String query) async {
    try {
      print('🔍 Поиск адресов: $query');
      
      // Имитация поиска адресов
      final addresses = <SearchResult>[];
      
      // Добавляем популярные адреса Алматы
      final popularAddresses = [
        'ул. Абая, 150',
        'пр. Абая, 1',
        'ул. Достык, 200',
        'ул. Сатпаева, 22',
        'ул. Желтоксан, 100',
        'пр. Назарбаева, 50',
        'ул. Толе би, 75',
        'ул. Фурманова, 25',
      ];
      
      for (final address in popularAddresses) {
        if (address.toLowerCase().contains(query.toLowerCase())) {
          addresses.add(SearchResult(
            id: 'address_${address.hashCode}',
            name: address,
            type: 'address',
            latitude: 43.222 + (math.Random().nextDouble() - 0.5) * 0.1,
            longitude: 76.8512 + (math.Random().nextDouble() - 0.5) * 0.1,
            description: 'Адрес в Алматы',
          ));
        }
      }
      
      // Добавляем организации
      final organizations = await _getOrganizations();
      for (final org in organizations) {
        if (org.name.toLowerCase().contains(query.toLowerCase()) ||
            org.address.toLowerCase().contains(query.toLowerCase())) {
          addresses.add(SearchResult(
            id: org.id,
            name: org.name,
            type: 'organization',
            latitude: org.latitude,
            longitude: org.longitude,
            description: org.description,
            organization: org,
          ));
        }
      }
      
      print('🔍 Найдено результатов: ${addresses.length}');
      return addresses;
      
    } catch (e) {
      print('❌ Ошибка поиска адресов: $e');
      return [];
    }
  }

  /// Получение организаций
  Future<List<Organization>> _getOrganizations() async {
    // Имитация получения организаций
    return [
      Organization(
        id: '1',
        name: 'MegaIce',
        description: 'Ледовый каток',
        address: 'ул. Сатпаева, 22',
        latitude: 43.222,
        longitude: 76.8512,
        category: 'Развлечения',
        phone: '+7 727 123 4567',
        website: 'https://megoice.kz',
        rating: 4.5,
        ownerId: 'admin',
        email: 'megoice@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Organization(
        id: '2',
        name: 'Диалект',
        description: 'Ресторан',
        address: 'ул. Абая, 150',
        latitude: 43.225,
        longitude: 76.855,
        category: 'Рестораны',
        phone: '+7 727 234 5678',
        website: 'https://dialekt.kz',
        rating: 4.2,
        ownerId: 'admin',
        email: 'dialekt@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Organization(
        id: '3',
        name: 'Deco Interior Home',
        description: 'Магазин мебели',
        address: 'пр. Абая, 1',
        latitude: 43.220,
        longitude: 76.850,
        category: 'Магазины',
        phone: '+7 727 345 6789',
        website: 'https://deco.kz',
        rating: 4.0,
        ownerId: 'admin',
        email: 'deco@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Построение маршрута
  Future<RouteResult> buildRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required TransportType transportType,
  }) async {
    try {
      print('🗺️ Построение маршрута: ${transportType.name}');
      
      // Имитация построения маршрута
      final distance = _calculateDistance(startLat, startLng, endLat, endLng);
      final duration = _calculateDuration(distance, transportType);
      final cost = _calculateCost(distance, transportType);
      
      // Создаем точки маршрута
      final points = _generateRoutePoints(startLat, startLng, endLat, endLng);
      
      // Определяем цвет маршрута
      RouteColor routeColor;
      if (transportType == TransportType.car) {
        routeColor = math.Random().nextBool() ? RouteColor.green : RouteColor.blue;
      } else {
        routeColor = RouteColor.blue;
      }
      
      final route = RouteResult(
        id: 'route_${DateTime.now().millisecondsSinceEpoch}',
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
        transportType: transportType,
        distance: distance,
        duration: duration,
        cost: cost,
        points: points,
        color: routeColor,
        hasTraffic: routeColor == RouteColor.blue,
        hasAccidents: math.Random().nextBool(),
        steps: _generateRouteSteps(distance, duration, transportType),
      );
      
      print('✅ Маршрут построен: ${duration.inMinutes} мин, ${distance.toStringAsFixed(1)} км');
      return route;
      
    } catch (e) {
      print('❌ Ошибка построения маршрута: $e');
      rethrow;
    }
  }

  /// Расчет расстояния между точками
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Радиус Земли в километрах
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Расчет времени в пути
  Duration _calculateDuration(double distance, TransportType transportType) {
    double speedKmh;
    
    switch (transportType) {
      case TransportType.car:
        speedKmh = 40; // Средняя скорость в городе
        break;
      case TransportType.bus:
        speedKmh = 25; // Скорость общественного транспорта
        break;
      case TransportType.walking:
        speedKmh = 5; // Скорость пешком
        break;
      case TransportType.taxi:
        speedKmh = 35; // Скорость такси
        break;
      case TransportType.bicycle:
        speedKmh = 15; // Скорость на велосипеде
        break;
      case TransportType.scooter:
        speedKmh = 20; // Скорость на самокате
        break;
      case TransportType.truck:
        speedKmh = 30; // Скорость грузовика
        break;
    }
    
    final hours = distance / speedKmh;
    return Duration(minutes: (hours * 60).round());
  }

  /// Расчет стоимости
  double _calculateCost(double distance, TransportType transportType) {
    switch (transportType) {
      case TransportType.car:
        return distance * 15; // 15 тенге за км
      case TransportType.bus:
        return 90; // Фиксированная стоимость
      case TransportType.walking:
        return 0;
      case TransportType.taxi:
        return distance * 25; // 25 тенге за км
      case TransportType.bicycle:
        return distance * 5; // 5 тенге за км
      case TransportType.scooter:
        return distance * 8; // 8 тенге за км
      case TransportType.truck:
        return distance * 20; // 20 тенге за км
    }
  }

  /// Генерация точек маршрута
  List<LatLng> _generateRoutePoints(double startLat, double startLng, double endLat, double endLng) {
    final points = <LatLng>[];
    
    // Добавляем начальную точку
    points.add(LatLng(startLat, startLng));
    
    // Генерируем промежуточные точки
    final steps = 10;
    for (int i = 1; i < steps; i++) {
      final ratio = i / steps;
      final lat = startLat + (endLat - startLat) * ratio + (math.Random().nextDouble() - 0.5) * 0.001;
      final lng = startLng + (endLng - startLng) * ratio + (math.Random().nextDouble() - 0.5) * 0.001;
      points.add(LatLng(lat, lng));
    }
    
    // Добавляем конечную точку
    points.add(LatLng(endLat, endLng));
    
    return points;
  }

  /// Генерация шагов маршрута
  List<RouteStep> _generateRouteSteps(double distance, Duration duration, TransportType transportType) {
    final steps = <RouteStep>[];
    
    if (transportType == TransportType.bus) {
      // Для общественного транспорта добавляем шаги
      steps.add(RouteStep(
        instruction: 'Идите пешком до остановки',
        duration: Duration(minutes: 6),
        distance: 0.5,
        transportType: TransportType.walking,
      ));
      
      steps.add(RouteStep(
        instruction: 'Автобус №14',
        duration: Duration(minutes: 25),
        distance: 8.0,
        transportType: TransportType.bus,
      ));
      
      steps.add(RouteStep(
        instruction: 'Автобус №5',
        duration: Duration(minutes: 15),
        distance: 4.5,
        transportType: TransportType.bus,
      ));
      
      steps.add(RouteStep(
        instruction: 'Идите пешком до места назначения',
        duration: Duration(minutes: 2),
        distance: 0.2,
        transportType: TransportType.walking,
      ));
    } else {
      // Для других видов транспорта
      steps.add(RouteStep(
        instruction: _getTransportInstruction(transportType),
        duration: duration,
        distance: distance,
        transportType: transportType,
      ));
    }
    
    return steps;
  }

  String _getTransportInstruction(TransportType transportType) {
    switch (transportType) {
      case TransportType.car:
        return 'Поезжайте на автомобиле';
      case TransportType.bus:
        return 'Поезжайте на автобусе';
      case TransportType.walking:
        return 'Идите пешком';
      case TransportType.taxi:
        return 'Поезжайте на такси';
      case TransportType.bicycle:
        return 'Езжайте на велосипеде';
      case TransportType.scooter:
        return 'Езжайте на самокате';
      case TransportType.truck:
        return 'Поезжайте на грузовике';
    }
  }
}

/// Модель результата поиска
class SearchResult {
  final String id;
  final String name;
  final String type; // 'address' или 'organization'
  final double latitude;
  final double longitude;
  final String description;
  final Organization? organization;

  SearchResult({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.organization,
  });
}
