import 'package:flutter/material.dart';

/// Типы транспорта
enum TransportType {
  car,
  bus,
  walking,
  taxi,
  bicycle,
  scooter,
  truck,
}

/// Цвета маршрутов
enum RouteColor {
  green, // Самый быстрый
  blue,  // Без пробок и объездов
}

/// Результат построения маршрута
class RouteResult {
  final String id;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final TransportType transportType;
  final double distance; // в километрах
  final Duration duration;
  final double cost; // в тенге
  final List<LatLng> points;
  final RouteColor color;
  final bool hasTraffic;
  final bool hasAccidents;
  final List<RouteStep> steps;

  RouteResult({
    required this.id,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.transportType,
    required this.distance,
    required this.duration,
    required this.cost,
    required this.points,
    required this.color,
    required this.hasTraffic,
    required this.hasAccidents,
    required this.steps,
  });

  /// Получить иконку транспорта
  IconData get transportIcon {
    switch (transportType) {
      case TransportType.car:
        return Icons.directions_car;
      case TransportType.bus:
        return Icons.directions_bus;
      case TransportType.walking:
        return Icons.directions_walk;
      case TransportType.taxi:
        return Icons.local_taxi;
      case TransportType.bicycle:
        return Icons.directions_bike;
      case TransportType.scooter:
        return Icons.electric_scooter;
      case TransportType.truck:
        return Icons.local_shipping;
    }
  }

  /// Получить название транспорта
  String get transportName {
    switch (transportType) {
      case TransportType.car:
        return 'Автомобиль';
      case TransportType.bus:
        return 'Автобус';
      case TransportType.walking:
        return 'Пешком';
      case TransportType.taxi:
        return 'Такси';
      case TransportType.bicycle:
        return 'Велосипед';
      case TransportType.scooter:
        return 'Самокат';
      case TransportType.truck:
        return 'Грузовик';
    }
  }

  /// Получить цвет маршрута
  Color get routeColorValue {
    switch (color) {
      case RouteColor.green:
        return Colors.green;
      case RouteColor.blue:
        return Colors.blue;
    }
  }

  /// Форматирование времени
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}ч ${minutes}мин';
    } else {
      return '${minutes}мин';
    }
  }

  /// Форматирование расстояния
  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).round()}м';
    } else {
      return '${distance.toStringAsFixed(1)}км';
    }
  }

  /// Форматирование стоимости
  String get formattedCost {
    if (cost == 0) {
      return 'Бесплатно';
    } else {
      return '~${cost.round()}тг';
    }
  }

  /// Время прибытия
  String getArrivalTime() {
    final now = DateTime.now();
    final arrival = now.add(duration);
    return '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')}';
  }
}

/// Модель точки маршрута
class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(
      json['latitude'] as double,
      json['longitude'] as double,
    );
  }
}

/// Модель шага маршрута
class RouteStep {
  final String instruction;
  final Duration duration;
  final double distance;
  final TransportType transportType;

  RouteStep({
    required this.instruction,
    required this.duration,
    required this.distance,
    required this.transportType,
  });

  /// Форматирование времени шага
  String get formattedDuration {
    final minutes = duration.inMinutes;
    return '${minutes}мин';
  }

  /// Форматирование расстояния шага
  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).round()}м';
    } else {
      return '${distance.toStringAsFixed(1)}км';
    }
  }

  /// Получить иконку транспорта для шага
  IconData get transportIcon {
    switch (transportType) {
      case TransportType.car:
        return Icons.directions_car;
      case TransportType.bus:
        return Icons.directions_bus;
      case TransportType.walking:
        return Icons.directions_walk;
      case TransportType.taxi:
        return Icons.local_taxi;
      case TransportType.bicycle:
        return Icons.directions_bike;
      case TransportType.scooter:
        return Icons.electric_scooter;
      case TransportType.truck:
        return Icons.local_shipping;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'instruction': instruction,
      'duration': duration.inMinutes,
      'distance': distance,
      'transportType': transportType.name,
    };
  }

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['instruction'] as String,
      duration: Duration(minutes: json['duration'] as int),
      distance: json['distance'] as double,
      transportType: TransportType.values.firstWhere(
        (e) => e.name == json['transportType'],
      ),
    );
  }
}