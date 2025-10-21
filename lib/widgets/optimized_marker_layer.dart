import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:math' as math;

class OptimizedMarkerLayer extends StatelessWidget {
  final List<Marker> markers;
  final double? maxZoom;
  final double? minZoom;

  const OptimizedMarkerLayer({
    super.key,
    required this.markers,
    this.maxZoom,
    this.minZoom,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: _filterMarkersByZoom(markers),
    );
  }

  List<Marker> _filterMarkersByZoom(List<Marker> allMarkers) {
    // Фильтруем маркеры в зависимости от уровня зума
    // На низких зумах показываем только важные маркеры
    return allMarkers.where((marker) {
      // Здесь можно добавить логику фильтрации маркеров
      // Например, показывать только маркеры текущего местоположения на низких зумах
      return true;
    }).toList();
  }
}
