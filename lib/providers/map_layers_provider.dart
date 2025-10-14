import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/map_layer_model.dart';

class MapLayersProvider extends ChangeNotifier {
  List<MapLayer> _layers = [];
  bool _isLoading = false;

  // Getters
  List<MapLayer> get layers => _layers;
  bool get isLoading => _isLoading;

  // Инициализация слоев
  void initializeLayers() {
    _layers = [
      MapLayer(
        id: 'standard',
        name: 'Стандартная карта',
        icon: 'map',
        isEnabled: true, // По умолчанию включена
        description: 'Обычная карта с дорогами и объектами',
      ),
      MapLayer(
        id: 'satellite',
        name: 'Спутник',
        icon: 'satellite',
        isEnabled: false,
        description: 'Спутниковые снимки',
      ),
      MapLayer(
        id: 'traffic',
        name: 'Пробки',
        icon: 'traffic',
        isEnabled: false,
        description: 'Информация о пробках',
      ),
      MapLayer(
        id: 'transit',
        name: 'Общественный транспорт',
        icon: 'transit',
        isEnabled: false,
        description: 'Маршруты общественного транспорта',
      ),
      MapLayer(
        id: 'scooter',
        name: 'Самокат',
        icon: 'scooter',
        isEnabled: false,
        description: 'Прокат самокатов',
      ),
      MapLayer(
        id: 'bicycle',
        name: 'Велосипедные дорожки',
        icon: 'bicycle',
        isEnabled: false,
        description: 'Велосипедные маршруты',
      ),
      MapLayer(
        id: 'parking',
        name: 'Парковки',
        icon: 'parking',
        isEnabled: false,
        description: 'Парковочные места',
      ),
      MapLayer(
        id: 'accidents',
        name: 'Аварии',
        icon: 'accidents',
        isEnabled: false,
        description: 'Информация об авариях',
      ),
    ];
    
    _loadLayersState();
  }

  // Переключение слоя
  void toggleLayer(String layerId) {
    final index = _layers.indexWhere((layer) => layer.id == layerId);
    if (index != -1) {
      _layers[index] = _layers[index].copyWith(
        isEnabled: !_layers[index].isEnabled,
      );
      _saveLayersState();
      notifyListeners();
    }
  }

  // Получение состояния слоя
  bool isLayerEnabled(String layerId) {
    final layer = _layers.firstWhere(
      (layer) => layer.id == layerId,
      orElse: () => MapLayer(id: '', name: '', icon: ''),
    );
    return layer.isEnabled;
  }

  // Получение активных слоев
  List<MapLayer> get activeLayers {
    return _layers.where((layer) => layer.isEnabled).toList();
  }

  // Сохранение состояния в SharedPreferences
  Future<void> _saveLayersState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final layersJson = _layers.map((layer) => layer.toJson()).toList();
      final layersString = layersJson.map((json) => 
          '${json['id']}:${json['isEnabled']}').join(',');
      await prefs.setString('map_layers_state', layersString);
    } catch (e) {
      print('Error saving layers state: $e');
    }
  }

  // Загрузка состояния из SharedPreferences
  Future<void> _loadLayersState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final layersString = prefs.getString('map_layers_state');
      
      if (layersString != null && layersString.isNotEmpty) {
        final layersData = layersString.split(',');
        
        for (final layerData in layersData) {
          final parts = layerData.split(':');
          if (parts.length == 2) {
            final layerId = parts[0];
            final isEnabled = parts[1] == 'true';
            
            final index = _layers.indexWhere((layer) => layer.id == layerId);
            if (index != -1) {
              _layers[index] = _layers[index].copyWith(isEnabled: isEnabled);
            }
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error loading layers state: $e');
    }
  }

  // Сброс всех слоев
  void resetLayers() {
    for (int i = 0; i < _layers.length; i++) {
      _layers[i] = _layers[i].copyWith(
        isEnabled: i == 0, // Только стандартная карта включена
      );
    }
    _saveLayersState();
    notifyListeners();
  }

  // Получение иконки по типу
  IconData getLayerIcon(String iconType) {
    switch (iconType) {
      case 'map':
        return Icons.map;
      case 'satellite':
        return Icons.satellite;
      case 'traffic':
        return Icons.traffic;
      case 'transit':
        return Icons.directions_bus;
      case 'scooter':
        return Icons.electric_scooter;
      case 'bicycle':
        return Icons.directions_bike;
      case 'parking':
        return Icons.local_parking;
      case 'accidents':
        return Icons.car_crash;
      default:
        return Icons.map;
    }
  }
}
