import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../providers/theme_provider.dart';

class OptimizedMapWidget extends StatefulWidget {
  final MapController mapController;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final Function(latlng.LatLng) onTap;

  const OptimizedMapWidget({
    super.key,
    required this.mapController,
    required this.markers,
    required this.polylines,
    required this.onTap,
  });

  @override
  State<OptimizedMapWidget> createState() => _OptimizedMapWidgetState();
}

class _OptimizedMapWidgetState extends State<OptimizedMapWidget> {
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    // Небольшая задержка для инициализации карты
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isMapReady = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Stack(
            children: [
              // Фоновый цвет для загрузки
              Container(
                color: themeProvider.backgroundColor,
                child: Center(
                  child: _isMapReady
                      ? null
                      : CircularProgressIndicator(
                          color: themeProvider.primaryColor,
                        ),
                ),
              ),
              // Карта
              if (_isMapReady)
                FlutterMap(
                  mapController: widget.mapController,
                  options: MapOptions(
                    initialCenter: const latlng.LatLng(43.238949, 76.889709),
                    initialZoom: 15.0,
                    minZoom: 3.0,
                    maxZoom: 18.0,
                    onTap: (tapPosition, point) => widget.onTap(point),
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    // Оптимизация производительности
                    cameraConstraint: CameraConstraint.contain(
                      bounds: LatLngBounds(
                        const latlng.LatLng(-90, -180),
                        const latlng.LatLng(90, 180),
                      ),
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.anal_gis',
                      maxZoom: 18,
                      tileSize: 256,
                      retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
                      backgroundColor: themeProvider.backgroundColor,
                      // Оптимизация загрузки тайлов
                      tileBuilder: (context, tileWidget, tile) {
                        return Container(
                          decoration: BoxDecoration(
                            color: themeProvider.backgroundColor,
                          ),
                          child: tileWidget,
                        );
                      },
                      errorTileCallback: (tile, error, stackTrace) {
                        return Container(
                          color: themeProvider.backgroundColor,
                          child: Center(
                            child: Icon(
                              Icons.error_outline,
                              color: themeProvider.textSecondaryColor,
                              size: 24,
                            ),
                          ),
                        );
                      },
                      // Быстрые переходы
                      tileFadeInStart: 0.0,
                      tileFadeInDuration: const Duration(milliseconds: 150),
                      tileFadeOutStart: 0.0,
                      tileFadeOutDuration: const Duration(milliseconds: 50),
                      // Кэширование
                      evictErrorTileFromCache: true,
                      keepBuffer: 2,
                      panBuffer: 1,
                    ),
                    MarkerLayer(
                      markers: widget.markers,
                    ),
                    PolylineLayer(
                      polylines: widget.polylines,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
