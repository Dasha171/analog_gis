import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class CrossPlatformSyncService {
  static final CrossPlatformSyncService _instance = CrossPlatformSyncService._internal();
  factory CrossPlatformSyncService() => _instance;
  CrossPlatformSyncService._internal();

  // Используем простой подход - сохраняем данные в localStorage с уникальным ключом
  static const String _syncKey = 'anal_gis_sync_data';
  static const String _lastSyncKey = 'anal_gis_last_sync';

  /// Синхронизация пользователей между платформами
  Future<void> syncUsers() async {
    try {
      print('🔄 СИНХРОНИЗАЦИЯ ПОЛЬЗОВАТЕЛЕЙ МЕЖДУ ПЛАТФОРМАМИ...');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Получаем текущих пользователей
      final usersJson = prefs.getString('unified_users') ?? '[]';
      final users = (json.decode(usersJson) as List)
          .map((json) => User.fromJson(json))
          .toList();
      
      print('🔍 Текущие пользователи: ${users.length}');
      for (final user in users) {
        print('  - ${user.email}: ${user.fullName} (${user.role})');
      }
      
      // Сохраняем данные с меткой времени
      final syncData = {
        'users': users.map((u) => u.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'platform': _getPlatformName(),
      };
      
      await prefs.setString(_syncKey, json.encode(syncData));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      
      print('✅ Данные синхронизированы: ${users.length} пользователей');
      
    } catch (e) {
      print('❌ Ошибка синхронизации: $e');
    }
  }

  /// Загрузка синхронизированных данных
  Future<List<User>> loadSyncedUsers() async {
    try {
      print('📥 ЗАГРУЗКА СИНХРОНИЗИРОВАННЫХ ДАННЫХ...');
      
      final prefs = await SharedPreferences.getInstance();
      final syncDataJson = prefs.getString(_syncKey);
      
      if (syncDataJson == null) {
        print('🔍 Нет синхронизированных данных');
        return [];
      }
      
      final syncData = json.decode(syncDataJson) as Map<String, dynamic>;
      final usersJson = syncData['users'] as List;
      final timestamp = syncData['timestamp'] as int;
      final platform = syncData['platform'] as String;
      
      final users = usersJson.map((json) => User.fromJson(json)).toList();
      
      print('🔍 Загружено ${users.length} пользователей (платформа: $platform, время: ${DateTime.fromMillisecondsSinceEpoch(timestamp)})');
      
      return users;
      
    } catch (e) {
      print('❌ Ошибка загрузки синхронизированных данных: $e');
      return [];
    }
  }

  /// Получение имени платформы
  String _getPlatformName() {
    // В реальном приложении можно использовать kIsWeb из foundation
    return 'mobile'; // Пока что всегда mobile, так как мы в мобильном приложении
  }

  /// Проверка необходимости синхронизации
  Future<bool> needsSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString(_lastSyncKey);
      
      if (lastSync == null) {
        return true;
      }
      
      final lastSyncTime = DateTime.parse(lastSync);
      final now = DateTime.now();
      final difference = now.difference(lastSyncTime);
      
      // Синхронизируем если прошло больше 15 минут
      return difference.inMinutes > 15;
      
    } catch (e) {
      print('❌ Ошибка проверки синхронизации: $e');
      return true;
    }
  }

  /// Инициализация синхронизации
  Future<void> initialize() async {
    try {
      print('🚀 ИНИЦИАЛИЗАЦИЯ СИНХРОНИЗАЦИИ...');
      
      // Синхронизируем только если действительно нужно
      if (await needsSync()) {
        print('🔍 Требуется синхронизация');
        await syncUsers();
      } else {
        print('✅ Синхронизация не требуется');
      }
      
    } catch (e) {
      print('❌ Ошибка инициализации синхронизации: $e');
    }
  }
}
