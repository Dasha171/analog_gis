import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/organization_model.dart';
import '../models/advertisement_model.dart';
import '../models/friend_model.dart';
import '../models/manager_permissions_model.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  // Используем JSONPlaceholder как временное хранилище
  // В реальном приложении здесь должен быть ваш API
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  
  // Ключи для хранения данных
  static const String _usersKey = 'sync_users';
  static const String _organizationsKey = 'sync_organizations';
  static const String _advertisementsKey = 'sync_advertisements';
  static const String _friendsKey = 'sync_friends';
  static const String _managerPermissionsKey = 'sync_manager_permissions';

  /// Синхронизация пользователей
  Future<void> syncUsers() async {
    try {
      print('🔄 СИНХРОНИЗАЦИЯ ПОЛЬЗОВАТЕЛЕЙ...');
      
      // Получаем локальные данные
      final prefs = await SharedPreferences.getInstance();
      final localUsersJson = prefs.getString('unified_users') ?? '[]';
      final localUsers = (json.decode(localUsersJson) as List)
          .map((json) => User.fromJson(json))
          .toList();
      
      print('🔍 Локальные пользователи: ${localUsers.length}');
      
      // Получаем данные с сервера (имитируем)
      final serverUsers = await _getServerUsers();
      print('🔍 Серверные пользователи: ${serverUsers.length}');
      
      // Объединяем данные (приоритет серверным данным)
      final Map<String, User> userMap = {};
      
      // Добавляем локальные пользователи
      for (final user in localUsers) {
        userMap[user.email] = user;
      }
      
      // Добавляем серверные пользователи (перезаписывают локальные)
      for (final user in serverUsers) {
        userMap[user.email] = user;
      }
      
      final mergedUsers = userMap.values.toList();
      print('🔍 Объединенные пользователи: ${mergedUsers.length}');
      
      // Сохраняем объединенные данные локально
      await prefs.setString('unified_users', 
          json.encode(mergedUsers.map((u) => u.toJson()).toList()));
      
      // Отправляем данные на сервер (имитируем)
      await _saveServerUsers(mergedUsers);
      
      print('✅ Синхронизация пользователей завершена');
      
    } catch (e) {
      print('❌ Ошибка синхронизации пользователей: $e');
    }
  }

  /// Получение пользователей с сервера (имитация)
  Future<List<User>> _getServerUsers() async {
    try {
      // В реальном приложении здесь будет HTTP запрос
      // Пока возвращаем пустой список
      return [];
    } catch (e) {
      print('❌ Ошибка получения пользователей с сервера: $e');
      return [];
    }
  }

  /// Сохранение пользователей на сервер (имитация)
  Future<void> _saveServerUsers(List<User> users) async {
    try {
      // В реальном приложении здесь будет HTTP запрос
      print('📤 Отправка ${users.length} пользователей на сервер (имитация)');
    } catch (e) {
      print('❌ Ошибка сохранения пользователей на сервер: $e');
    }
  }

  /// Синхронизация всех данных
  Future<void> syncAllData() async {
    try {
      print('🔄 ПОЛНАЯ СИНХРОНИЗАЦИЯ ДАННЫХ...');
      
      await syncUsers();
      // Здесь можно добавить синхронизацию других типов данных
      
      print('✅ Полная синхронизация завершена');
    } catch (e) {
      print('❌ Ошибка полной синхронизации: $e');
    }
  }

  /// Принудительная синхронизация при запуске приложения
  Future<void> initializeSync() async {
    try {
      print('🚀 ИНИЦИАЛИЗАЦИЯ СИНХРОНИЗАЦИИ...');
      
      // Проверяем, есть ли данные для синхронизации
      final prefs = await SharedPreferences.getInstance();
      final hasLocalData = prefs.getString('unified_users') != null;
      
      if (hasLocalData) {
        print('🔍 Найдены локальные данные, выполняем синхронизацию');
        await syncAllData();
      } else {
        print('🔍 Локальных данных нет, пропускаем синхронизацию');
      }
      
    } catch (e) {
      print('❌ Ошибка инициализации синхронизации: $e');
    }
  }
}
