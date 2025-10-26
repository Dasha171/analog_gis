import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'auth_provider.dart';
import 'advertisement_provider.dart';
import '../services/unified_database_service.dart';
import '../models/user_model.dart';
import '../models/manager_permissions_model.dart';
import '../utils/database_diagnostic.dart';

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin', 'moderator', 'user'
  final DateTime createdAt;
  final bool isActive;
  final Map<String, dynamic> permissions;
  final List<String> managedCities; // Города, которыми управляет менеджер

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.isActive,
    required this.permissions,
    this.managedCities = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'permissions': permissions,
      'managedCities': managedCities,
    };
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'],
      permissions: Map<String, dynamic>.from(json['permissions']),
      managedCities: List<String>.from(json['managedCities'] ?? []),
    );
  }
}

class AppStats {
  final int totalUsers;
  final int activeUsers;
  final int totalOrganizations;
  final int totalReviews;
  final int totalPhotos;
  final int totalFriendships;
  final DateTime lastUpdated;

  AppStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalOrganizations,
    required this.totalReviews,
    required this.totalPhotos,
    required this.totalFriendships,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'totalOrganizations': totalOrganizations,
      'totalReviews': totalReviews,
      'totalPhotos': totalPhotos,
      'totalFriendships': totalFriendships,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory AppStats.fromJson(Map<String, dynamic> json) {
    return AppStats(
      totalUsers: json['totalUsers'],
      activeUsers: json['activeUsers'],
      totalOrganizations: json['totalOrganizations'],
      totalReviews: json['totalReviews'],
      totalPhotos: json['totalPhotos'],
      totalFriendships: json['totalFriendships'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class AdminProvider extends ChangeNotifier {
  List<AdminUser> _users = [];
  AppStats _appStats = AppStats(
    totalUsers: 0,
    activeUsers: 0,
    totalOrganizations: 0,
    totalReviews: 0,
    totalPhotos: 0,
    totalFriendships: 0,
    lastUpdated: DateTime.now(),
  );
  bool _isLoading = false;
  bool _isAdmin = false;
  AuthProvider? _authProvider;
  final UnifiedDatabaseService _databaseService = UnifiedDatabaseService();

  // Getters
  List<AdminUser> get users => _users;
  AppStats get appStats => _appStats;
  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;
  UnifiedDatabaseService get databaseService => _databaseService;

  // Проверка, является ли пользователь администратором
  Future<bool> checkIfAdmin(String email) async {
    return email == 'admin@gmail.com';
  }

  // Инициализация админ панели
  Future<void> initialize({AuthProvider? authProvider}) async {
    _authProvider = authProvider;
    _setLoading(true);
    await _loadUsersData();
    await _loadAppStats();
    // Обновляем статистику на основе реальных данных пользователей
    await updateStats();
    _setLoading(false);
    
    // ВАЖНО: Уведомляем UI об инициализации
    notifyListeners();
    print('🔔 AdminProvider инициализирован, UI уведомлен');
  }

  // Загрузка данных пользователей
  Future<void> _loadUsersData() async {
    try {
      // Диагностика перед загрузкой
      print('🔍 ДИАГНОСТИКА ПЕРЕД ЗАГРУЗКОЙ ПОЛЬЗОВАТЕЛЕЙ:');
      await DatabaseDiagnostic.printAllData();
      
      // Сначала пытаемся загрузить из UnifiedDatabaseService
      final dbUsers = await _databaseService.getAllUsers();
      
      print('🔍 ПОЛЬЗОВАТЕЛИ ИЗ UNIFIED_DATABASE_SERVICE: ${dbUsers.length}');
      for (final user in dbUsers) {
        print('  - ${user.email}: ${user.fullName} (${user.role})');
      }
      
      if (dbUsers.isNotEmpty) {
        print('Загружено пользователей из UnifiedDatabaseService: ${dbUsers.length}');
        
        // Конвертируем User в AdminUser
        _users = dbUsers.map((user) {
          return AdminUser(
            id: user.id,
            name: user.fullName,
            email: user.email,
            role: user.role,
            createdAt: user.createdAt,
            isActive: !user.isBlocked,
            permissions: _getDefaultPermissions(user.role),
            managedCities: [], // Пока не реализовано
          );
        }).toList();
        
        print('Загружены пользователи из базы данных: ${_users.length}');
        for (var user in _users) {
          print('Пользователь: ${user.name} (${user.email}) - ${user.role}');
        }
      } else {
        print('❌ НЕТ ПОЛЬЗОВАТЕЛЕЙ В UNIFIED_DATABASE_SERVICE!');
        
        // Проверяем старые данные
        final prefs = await SharedPreferences.getInstance();
        final oldUsersJson = prefs.getString('users') ?? '[]';
        final oldUsersList = json.decode(oldUsersJson) as List;
        
        print('🔍 СТАРЫЕ ДАННЫЕ: ${oldUsersList.length} пользователей');
        
        if (oldUsersList.isNotEmpty) {
          print('⚠️ НАЙДЕНЫ СТАРЫЕ ДАННЫЕ! Мигрируем...');
          await _databaseService.migrateData();
          
          // Повторно загружаем
          final migratedUsers = await _databaseService.getAllUsers();
          print('🔍 ПОСЛЕ МИГРАЦИИ: ${migratedUsers.length} пользователей');
          
          _users = migratedUsers.map((user) {
            return AdminUser(
              id: user.id,
              name: user.fullName,
              email: user.email,
              role: user.role,
              createdAt: user.createdAt,
              isActive: !user.isBlocked,
              permissions: _getDefaultPermissions(user.role),
              managedCities: [],
            );
          }).toList();
        }
      }

      // Если нет пользователей, создаем демо данные
      if (_users.isEmpty) {
        await _createDemoUsers();
      }

      print('Итого загружено пользователей: ${_users.length}');
      
      // ВАЖНО: Уведомляем UI об изменении данных
      notifyListeners();
      print('🔔 UI уведомлен об изменении данных пользователей: ${_users.length}');
    } catch (e) {
      print('Ошибка загрузки пользователей: $e');
    }
  }

  // Создание демо пользователей
  Future<void> _createDemoUsers() async {
    _users = [
      AdminUser(
        id: '1',
        name: 'Admin',
        email: 'admin@gmail.com',
        role: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isActive: true,
        permissions: {
          'manageUsers': true,
          'manageOrganizations': true,
          'viewStats': true,
          'manageAds': true,
          'manageRoles': true,
        },
      ),
      AdminUser(
        id: '2',
        name: 'Менеджер',
        email: 'manager@gmail.com',
        role: 'manager',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isActive: true,
        permissions: {
          'manageUsers': false,
          'manageOrganizations': true,
          'viewStats': true,
          'manageAds': false,
          'manageRoles': false,
        },
      ),
      AdminUser(
        id: '3',
        name: 'Менеджер',
        email: 'maneger@gmail.com',
        role: 'manager',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isActive: true,
        permissions: {
          'manageUsers': false,
          'manageOrganizations': true,
          'viewStats': true,
          'manageAds': false,
          'manageRoles': false,
        },
      ),
    ];
    await _saveUsersData();
    
    // ВАЖНО: Уведомляем UI об изменении данных
    notifyListeners();
    print('🔔 UI уведомлен о создании демо пользователей: ${_users.length}');
  }

  // Загрузка статистики приложения
  Future<void> _loadAppStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final statsJson = prefs.getString('app_stats');
      if (statsJson != null) {
        final statsMap = json.decode(statsJson);
        _appStats = AppStats.fromJson(statsMap);
      } else {
        await _generateDemoStats();
      }

      print('Загружена статистика приложения');
    } catch (e) {
      print('Ошибка загрузки статистики: $e');
    }
  }

  // Генерация демо статистики
  Future<void> _generateDemoStats() async {
    // Используем реальные данные вместо случайных чисел
    final totalUsers = _users.length;
    final activeUsers = _users.where((u) => u.isActive).length;
    
    _appStats = AppStats(
      totalUsers: totalUsers,
      activeUsers: activeUsers,
      totalOrganizations: 0, // Пока нет реальных организаций
      totalReviews: 0, // Пока нет реальных отзывов
      totalPhotos: 0, // Пока нет реальных фото
      totalFriendships: 0, // Пока нет реальных друзей
      lastUpdated: DateTime.now(),
    );
    await _saveAppStats();
  }

  // Сохранение данных пользователей
  Future<void> _saveUsersData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_users', json.encode(_users.map((e) => e.toJson()).toList()));
      print('Пользователи сохранены');
    } catch (e) {
      print('Ошибка сохранения пользователей: $e');
    }
  }

  // Сохранение статистики
  Future<void> _saveAppStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_stats', json.encode(_appStats.toJson()));
      print('Статистика сохранена');
    } catch (e) {
      print('Ошибка сохранения статистики: $e');
    }
  }

  // Добавление нового пользователя
  Future<bool> addUser(String name, String email, String role) async {
    try {
      // Проверяем, не существует ли уже пользователь с таким email
      if (_users.any((u) => u.email == email)) {
        return false;
      }

      final user = AdminUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
        isActive: true,
        permissions: _getDefaultPermissions(role),
      );

      _users.add(user);
      await _saveUsersData();
      
      // Также сохраняем в единую базу данных
      final unifiedUser = User(
        id: user.id,
        firstName: user.name.split(' ').first,
        lastName: user.name.split(' ').length > 1 ? user.name.split(' ').last : '',
        email: user.email,
        phone: '',
        createdAt: user.createdAt,
        isEmailVerified: true,
        role: user.role,
        isBlocked: !user.isActive,
        lastLoginAt: DateTime.now(),
      );
      
      await _databaseService.saveUser(unifiedUser);
      print('✅ Пользователь добавлен в админ панель и единую базу: ${user.email}');
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Ошибка добавления пользователя: $e');
      return false;
    }
  }

  // Получение разрешений по роли
  Map<String, dynamic> _getDefaultPermissions(String role) {
    switch (role) {
      case 'admin':
        return {
          'manageUsers': true,
          'manageOrganizations': true,
          'viewStats': true,
          'manageAds': true,
          'manageRoles': true,
        };
      case 'manager':
        return {
          'manageUsers': false,
          'manageOrganizations': true,
          'viewStats': true,
          'manageAds': false,
          'manageRoles': false,
        };
      default:
        return {
          'manageUsers': false,
          'manageOrganizations': false,
          'viewStats': false,
          'manageAds': false,
          'manageRoles': false,
        };
    }
  }

  // Обновление роли пользователя
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        _users[userIndex] = AdminUser(
          id: _users[userIndex].id,
          name: _users[userIndex].name,
          email: _users[userIndex].email,
          role: newRole,
          createdAt: _users[userIndex].createdAt,
          isActive: _users[userIndex].isActive,
          permissions: _getDefaultPermissions(newRole),
          managedCities: _users[userIndex].managedCities,
        );
        
        // Сохраняем в обеих системах
        await _saveUsersData();
        
        // Обновляем в базе данных
        final user = await _databaseService.getUserById(userId);
        if (user != null) {
          final updatedUser = user.copyWith(role: newRole);
          await _databaseService.updateUser(updatedUser);
          print('✅ Роль пользователя обновлена в БД: ${user.email} -> $newRole');
        }
        
        notifyListeners();
        
        print('Роль пользователя обновлена: ${_users[userIndex].name} -> $newRole');
      }
    } catch (e) {
      print('Ошибка обновления роли: $e');
    }
  }

  // Блокировка/разблокировка пользователя
  Future<void> toggleUserStatus(String userId) async {
    try {
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        _users[userIndex] = AdminUser(
          id: _users[userIndex].id,
          name: _users[userIndex].name,
          email: _users[userIndex].email,
          role: _users[userIndex].role,
          createdAt: _users[userIndex].createdAt,
          isActive: !_users[userIndex].isActive,
          permissions: _users[userIndex].permissions,
          managedCities: _users[userIndex].managedCities,
        );
        
        // Сохраняем в обеих системах
        await _saveUsersData();
        notifyListeners();
        
        print('Статус пользователя изменен: ${_users[userIndex].name} -> ${_users[userIndex].isActive ? 'активен' : 'заблокирован'}');
      }
    } catch (e) {
      print('Ошибка изменения статуса пользователя: $e');
    }
  }

  // Удаление пользователя
  Future<void> deleteUser(String userId) async {
    try {
      _users.removeWhere((u) => u.id == userId);
      await _saveUsersData();
      notifyListeners();
    } catch (e) {
      print('Ошибка удаления пользователя: $e');
    }
  }

  // Обновление статистики
  Future<void> updateStats() async {
    try {
      // Подсчитываем реальную статистику
      final totalUsers = _users.length;
      final activeUsers = _users.where((u) => u.isActive).length;
      final managers = _users.where((u) => u.role == 'manager').length;
      final admins = _users.where((u) => u.role == 'admin').length;
      
      _appStats = AppStats(
        totalUsers: totalUsers,
        activeUsers: activeUsers,
        totalOrganizations: 0, // Пока нет реальных организаций
        totalReviews: 0, // Пока нет реальных отзывов
        totalPhotos: 0, // Пока нет реальных фото
        totalFriendships: 0, // Пока нет реальных друзей
        lastUpdated: DateTime.now(),
      );
      await _saveAppStats();
      notifyListeners();
      
      print('Статистика обновлена: Пользователей: $totalUsers, Активных: $activeUsers, Менеджеров: $managers, Админов: $admins');
    } catch (e) {
      print('Ошибка обновления статистики: $e');
    }
  }

  // Принудительное обновление списка пользователей
  Future<void> refreshUsers() async {
    await _loadUsersData();
    notifyListeners();
  }

  // Принудительное сохранение всех пользователей
  Future<void> forceSaveAllUsers() async {
    try {
      print('🔍 ПРИНУДИТЕЛЬНОЕ СОХРАНЕНИЕ ВСЕХ ПОЛЬЗОВАТЕЛЕЙ...');
      
      // Сохраняем всех пользователей из списка админ панели
      for (final adminUser in _users) {
        final user = User(
          id: adminUser.id,
          firstName: adminUser.name.split(' ').first,
          lastName: adminUser.name.split(' ').length > 1 ? adminUser.name.split(' ').last : '',
          email: adminUser.email,
          phone: '',
          createdAt: adminUser.createdAt,
          isEmailVerified: true,
          role: adminUser.role,
          isBlocked: !adminUser.isActive,
          lastLoginAt: DateTime.now(),
        );
        
        await _databaseService.saveUser(user);
        print('✅ Сохранен пользователь: ${user.email}');
      }
      
      // Обновляем данные
      await _loadUsersData();
      notifyListeners();
      
      print('✅ Все пользователи принудительно сохранены');
      
    } catch (e) {
      print('❌ Ошибка принудительного сохранения: $e');
    }
  }

  // Обновление городов менеджера
  Future<void> updateManagerCities(String userId, List<String> cityIds) async {
    try {
      final userIndex = _users.indexWhere((user) => user.id == userId);
      if (userIndex != -1) {
        _users[userIndex] = AdminUser(
          id: _users[userIndex].id,
          name: _users[userIndex].name,
          email: _users[userIndex].email,
          role: _users[userIndex].role,
          createdAt: _users[userIndex].createdAt,
          isActive: _users[userIndex].isActive,
          permissions: _users[userIndex].permissions,
          managedCities: cityIds,
        );
        
        // Сохраняем в обеих системах
        await _saveUsersData();
        
        // Обновляем в базе данных
        final user = await _databaseService.getUserById(userId);
        if (user != null) {
          // Создаем ManagerPermissions для сохранения городов
          final permissions = ManagerPermissions(
            managerId: userId,
            cityIds: cityIds,
            canManageAds: true,
            canManageOrganizations: true,
            createdAt: DateTime.now(),
            allowedCities: cityIds,
            canAddAds: true,
          );
          await _databaseService.saveManagerPermissions(permissions);
          print('✅ Города менеджера сохранены в БД: ${user.email} - ${cityIds.length} городов');
        }
        
        notifyListeners();
        
        print('Города менеджера обновлены: ${_users[userIndex].name} - ${cityIds.length} городов');
      }
    } catch (e) {
      print('Ошибка обновления городов менеджера: $e');
    }
  }

  // Получение городов менеджера
  List<String> getManagerCities(String userId) {
    try {
      final user = _users.firstWhere((user) => user.id == userId);
      return user.managedCities;
    } catch (e) {
      return [];
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
