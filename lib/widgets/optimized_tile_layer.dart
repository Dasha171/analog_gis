import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      tileFadeInStart: 0.0,
      tileFadeInDuration: const Duration(milliseconds: 150),
      tileFadeOutStart: 0.0,
      tileFadeOutDuration: const Duration(milliseconds: 50),
      tileDisplay: TileDisplay.fadeIn,
      tileUpdateTransformer: (stream, tile) {
        return stream.timeout(
          const Duration(seconds: 3),
          onTimeout: (eventSink) {
            eventSink.addError(TimeoutException('Tile load timeout', const Duration(seconds: 3)));
          },
        );
      },
    );
  }

  Widget _defaultTileBuilder(BuildContext context, Widget tileWidget, Tile tile) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: tileWidget,
    );
  }

  Widget _defaultErrorTileCallback(Tile tile, Object? error, StackTrace? stackTrace) {
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
