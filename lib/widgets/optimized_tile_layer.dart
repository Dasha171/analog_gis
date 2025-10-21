import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:async';

class OptimizedTileLayer extends StatelessWidget {
  final String urlTemplate;
  final String userAgentPackageName;
  final int maxZoom;
  final int minZoom;
  final Color backgroundColor;
  final TileBuilder? tileBuilder;
  final TileErrorCallback? errorTileCallback;

  const OptimizedTileLayer({
    super.key,
    required this.urlTemplate,
    required this.userAgentPackageName,
    this.maxZoom = 18,
    this.minZoom = 3,
    required this.backgroundColor,
    this.tileBuilder,
    this.errorTileCallback,
  });

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: urlTemplate,
      userAgentPackageName: userAgentPackageName,
      maxZoom: maxZoom,
      minZoom: minZoom,
      backgroundColor: backgroundColor,
      tileBuilder: tileBuilder ?? _defaultTileBuilder,
      errorTileCallback: errorTileCallback ?? _defaultErrorTileCallback,
    );
  }

  Widget _defaultTileBuilder(BuildContext context, Widget tileWidget, TileImage tile) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: tileWidget,
    );
  }

  Widget _defaultErrorTileCallback(TileImage tile, Object? error, StackTrace? stackTrace) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.grey[400],
          size: 20,
        ),
      ),
    );
  }
}
