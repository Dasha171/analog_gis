import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class OptimizedPolylineLayer extends StatelessWidget {
  final List<Polyline> polylines;
  final double? strokeWidth;
  final Color? strokeColor;

  const OptimizedPolylineLayer({
    super.key,
    required this.polylines,
    this.strokeWidth,
    this.strokeColor,
  });

  @override
  Widget build(BuildContext context) {
    return PolylineLayer(
      polylines: polylines,
    );
  }
}
