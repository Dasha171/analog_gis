import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OfflineMapsService {
  static const String _baseUrl = 'https://your-map-tiles-server.com';
  static const String _prefsKey = 'offline_maps';
  
  /// Список доступных регионов для загрузки
  static const List<Map<String, dynamic>> _availableRegions = [
    {
      'id': 'almaty',
      'name': 'Алматы',
      'size': '150 МБ',
      'bounds': {
        'north': 43.4,
        'south': 43.1,
        'east': 77.0,
        'west': 76.7,
      },
      'zoomLevels': [10, 11, 12, 13, 14, 15, 16, 17, 18],
    },
    {
      'id': 'astana',
      'name': 'Астана',
      'size': '120 МБ',
      'bounds': {
        'north': 51.3,
        'south': 51.0,
        'east': 71.6,
        'west': 71.2,
      },
      'zoomLevels': [10, 11, 12, 13, 14, 15, 16, 17, 18],
    },
    {
      'id': 'shymkent',
      'name': 'Шымкент',
      'size': '80 МБ',
      'bounds': {
        'north': 42.4,
        'south': 42.2,
        'east': 69.7,
        'west': 69.5,
      },
      'zoomLevels': [10, 11, 12, 13, 14, 15, 16, 17, 18],
    },
  ];
  
  /// Получить список доступных регионов
  static List<Map<String, dynamic>> getAvailableRegions() {
    return _availableRegions;
  }
  
  /// Получить список загруженных регионов
  static Future<List<String>> getDownloadedRegions() async {
    final prefs = await SharedPreferences.getInstance();
    final regionsJson = prefs.getString(_prefsKey) ?? '[]';
    final regions = json.decode(regionsJson) as List;
    return regions.cast<String>();
  }
  
  /// Проверить, загружен ли регион
  static Future<bool> isRegionDownloaded(String regionId) async {
    final downloadedRegions = await getDownloadedRegions();
    return downloadedRegions.contains(regionId);
  }
  
  /// Загрузить регион
  static Future<DownloadProgress> downloadRegion(
    String regionId, {
    Function(DownloadProgress)? onProgress,
  }) async {
    final region = _availableRegions.firstWhere(
      (r) => r['id'] == regionId,
      orElse: () => throw Exception('Region not found'),
    );
    
    final progress = DownloadProgress(
      regionId: regionId,
      totalTiles: _calculateTotalTiles(region),
      downloadedTiles: 0,
      status: DownloadStatus.downloading,
    );
    
    try {
      // Создаем директорию для тайлов
      final tilesDir = await _getTilesDirectory();
      final regionDir = Directory('${tilesDir.path}/$regionId');
      await regionDir.create(recursive: true);
      
      final bounds = region['bounds'] as Map<String, double>;
      final zoomLevels = region['zoomLevels'] as List<int>;
      
      int downloadedTiles = 0;
      
      for (final zoom in zoomLevels) {
        final tileBounds = _calculateTileBounds(bounds, zoom);
        
        for (int x = tileBounds['minX']!; x <= tileBounds['maxX']!; x++) {
          for (int y = tileBounds['minY']!; y <= tileBounds['maxY']!; y++) {
            try {
              await _downloadTile(regionId, zoom, x, y, regionDir);
              downloadedTiles++;
              
              progress.downloadedTiles = downloadedTiles;
              onProgress?.call(progress);
              
              // Небольшая задержка, чтобы не перегружать сервер
              await Future.delayed(const Duration(milliseconds: 10));
            } catch (e) {
              print('Error downloading tile $zoom/$x/$y: $e');
            }
          }
        }
      }
      
      // Сохраняем информацию о загруженном регионе
      await _saveDownloadedRegion(regionId);
      
      progress.status = DownloadStatus.completed;
      onProgress?.call(progress);
      
      return progress;
    } catch (e) {
      progress.status = DownloadStatus.failed;
      progress.error = e.toString();
      onProgress?.call(progress);
      return progress;
    }
  }
  
  /// Удалить регион
  static Future<void> deleteRegion(String regionId) async {
    try {
      // Удаляем файлы тайлов
      final tilesDir = await _getTilesDirectory();
      final regionDir = Directory('${tilesDir.path}/$regionId');
      if (await regionDir.exists()) {
        await regionDir.delete(recursive: true);
      }
      
      // Удаляем из сохраненного списка
      final downloadedRegions = await getDownloadedRegions();
      downloadedRegions.remove(regionId);
      await _saveDownloadedRegions(downloadedRegions);
    } catch (e) {
      print('Error deleting region: $e');
      rethrow;
    }
  }
  
  /// Получить URL тайла для офлайн использования
  static Future<String?> getOfflineTileUrl(int zoom, int x, int y) async {
    try {
      final tilesDir = await _getTilesDirectory();
      
      // Проверяем все загруженные регионы
      final downloadedRegions = await getDownloadedRegions();
      
      for (final regionId in downloadedRegions) {
        final tileFile = File('${tilesDir.path}/$regionId/$zoom/$x/$y.png');
        if (await tileFile.exists()) {
          return tileFile.uri.toString();
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting offline tile URL: $e');
      return null;
    }
  }
  
  /// Получить директорию для тайлов
  static Future<Directory> _getTilesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/offline_tiles');
  }
  
  /// Скачать тайл
  static Future<void> _downloadTile(
    String regionId,
    int zoom,
    int x,
    int y,
    Directory regionDir,
  ) async {
    final tileDir = Directory('${regionDir.path}/$zoom/$x');
    await tileDir.create(recursive: true);
    
    final tileFile = File('${tileDir.path}/$y.png');
    if (await tileFile.exists()) {
      return; // Тайл уже загружен
    }
    
    // В реальном приложении здесь будет запрос к серверу тайлов
    // Пока создаем пустой файл для демонстрации
    await tileFile.create();
  }
  
  /// Рассчитать границы тайлов для зума
  static Map<String, int> _calculateTileBounds(
    Map<String, double> bounds,
    int zoom,
  ) {
    final minX = _lonToTile(bounds['west']!, zoom);
    final maxX = _lonToTile(bounds['east']!, zoom);
    final minY = _latToTile(bounds['north']!, zoom);
    final maxY = _latToTile(bounds['south']!, zoom);
    
    return {
      'minX': minX,
      'maxX': maxX,
      'minY': minY,
      'maxY': maxY,
    };
  }
  
  /// Конвертировать долготу в номер тайла X
  static int _lonToTile(double lon, int zoom) {
    return ((lon + 180) / 360 * (1 << zoom)).floor();
  }
  
  /// Конвертировать широту в номер тайла Y
  static int _latToTile(double lat, int zoom) {
    final latRad = lat * (3.14159265359 / 180);
    return ((1 - (sin(latRad) + 1) / 2) * (1 << zoom)).floor();
  }
  
  /// Рассчитать общее количество тайлов
  static int _calculateTotalTiles(Map<String, dynamic> region) {
    final bounds = region['bounds'] as Map<String, double>;
    final zoomLevels = region['zoomLevels'] as List<int>;
    
    int totalTiles = 0;
    
    for (final zoom in zoomLevels) {
      final tileBounds = _calculateTileBounds(bounds, zoom);
      final tilesInZoom = (tileBounds['maxX']! - tileBounds['minX']! + 1) *
          (tileBounds['maxY']! - tileBounds['minY']! + 1);
      totalTiles += tilesInZoom;
    }
    
    return totalTiles;
  }
  
  /// Сохранить информацию о загруженном регионе
  static Future<void> _saveDownloadedRegion(String regionId) async {
    final downloadedRegions = await getDownloadedRegions();
    if (!downloadedRegions.contains(regionId)) {
      downloadedRegions.add(regionId);
      await _saveDownloadedRegions(downloadedRegions);
    }
  }
  
  /// Сохранить список загруженных регионов
  static Future<void> _saveDownloadedRegions(List<String> regions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(regions));
  }
  
  /// Получить размер загруженных данных
  static Future<int> getDownloadedSize() async {
    try {
      final tilesDir = await _getTilesDirectory();
      if (!await tilesDir.exists()) {
        return 0;
      }
      
      int totalSize = 0;
      await for (final entity in tilesDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error calculating downloaded size: $e');
      return 0;
    }
  }
  
  /// Очистить все загруженные данные
  static Future<void> clearAllDownloads() async {
    try {
      final tilesDir = await _getTilesDirectory();
      if (await tilesDir.exists()) {
        await tilesDir.delete(recursive: true);
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (e) {
      print('Error clearing all downloads: $e');
      rethrow;
    }
  }
}

class DownloadProgress {
  final String regionId;
  final int totalTiles;
  int downloadedTiles;
  DownloadStatus status;
  String? error;
  
  DownloadProgress({
    required this.regionId,
    required this.totalTiles,
    required this.downloadedTiles,
    required this.status,
    this.error,
  });
  
  double get progress => totalTiles > 0 ? downloadedTiles / totalTiles : 0.0;
  
  String get progressText => '${downloadedTiles}/${totalTiles} тайлов';
}

enum DownloadStatus {
  downloading,
  completed,
  failed,
  paused,
}
