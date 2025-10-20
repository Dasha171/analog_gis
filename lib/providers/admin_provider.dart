import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'auth_provider.dart';
import 'advertisement_provider.dart';

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

  // Getters
  List<AdminUser> get users => _users;
  AppStats get appStats => _appStats;
  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;

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
  }

  // Загрузка данных пользователей
  Future<void> _loadUsersData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Загружаем всех пользователей из SharedPreferences
      final usersJson = prefs.getString('all_users') ?? '[]';
      final usersList = json.decode(usersJson) as List;
      
      print('Загружено пользователей из SharedPreferences: ${usersList.length}');
      for (var userData in usersList) {
        print('Пользователь: ${userData['firstName']} ${userData['lastName']} (${userData['email']})');
      }
      
      // Конвертируем в AdminUser
      _users = usersList.map((userData) {
        return AdminUser(
          id: userData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: userData['firstName'] != null && userData['lastName'] != null 
              ? '${userData['firstName']} ${userData['lastName']}'
              : userData['name'] ?? userData['fullName'] ?? 'Пользователь',
          email: userData['email'] ?? '',
          role: userData['role'] ?? 'user',
          createdAt: userData['createdAt'] != null 
              ? DateTime.parse(userData['createdAt'])
              : DateTime.now(),
          isActive: userData['isActive'] ?? true,
          permissions: _getDefaultPermissions(userData['role'] ?? 'user'),
          managedCities: List<String>.from(userData['managedCities'] ?? []),
        );
      }).toList();

      // Если нет пользователей, создаем демо данные
      if (_users.isEmpty) {
        await _createDemoUsers();
      }

      print('Загружены пользователи: ${_users.length}');
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
        );
        await _saveUsersData();
        notifyListeners();
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
        );
        await _saveUsersData();
        notifyListeners();
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
        await _saveUsersData();
        notifyListeners();
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
