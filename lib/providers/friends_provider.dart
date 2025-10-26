import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/friend_model.dart';
import '../models/user_model.dart';
import '../services/unified_database_service.dart';
import 'auth_provider.dart';

class FriendsProvider extends ChangeNotifier {
  final UnifiedDatabaseService _databaseService = UnifiedDatabaseService();
  List<Friend> _friends = [];
  List<Friend> _pendingInvitations = [];
  List<Friend> _sentInvitations = [];
  bool _isLoading = false;
  String? _invitationCode;

  // Getters
  List<Friend> get friends => _friends.where((f) => f.isAccepted).toList();
  List<Friend> get pendingInvitations => _pendingInvitations.where((f) => f.isPending).toList();
  List<Friend> get sentInvitations => _sentInvitations.where((f) => f.isPending).toList();
  bool get isLoading => _isLoading;
  String? get invitationCode => _invitationCode;

  // Инициализация
  Future<void> initialize(AuthProvider authProvider) async {
    if (authProvider.currentUser == null) return;
    
    _setLoading(true);
    await _loadFriends(authProvider.currentUser!.id);
    await _loadPendingInvitations(authProvider.currentUser!.id);
    await _loadSentInvitations(authProvider.currentUser!.id);
    _generateInvitationCode();
    _setLoading(false);
  }

  // Загрузка друзей
  Future<void> _loadFriends(String userId) async {
    try {
      _friends = await _databaseService.getFriendsByUserId(userId);
      notifyListeners();
    } catch (e) {
      print('Ошибка загрузки друзей: $e');
    }
  }

  // Загрузка входящих приглашений
  Future<void> _loadPendingInvitations(String userId) async {
    try {
      _pendingInvitations = await _databaseService.getPendingFriendsByUserId(userId);
      notifyListeners();
    } catch (e) {
      print('Ошибка загрузки входящих приглашений: $e');
    }
  }

  // Загрузка исходящих приглашений
  Future<void> _loadSentInvitations(String userId) async {
    try {
      // Пока используем простую логику
      _sentInvitations = [];
      notifyListeners();
    } catch (e) {
      print('Ошибка загрузки исходящих приглашений: $e');
    }
  }

  // Приглашение друга по email
  Future<bool> inviteFriendByEmail(String email, String currentUserId) async {
    try {
      // Проверяем, существует ли пользователь с таким email
      final user = await _databaseService.getUserByEmail(email);
      if (user == null) {
        return false; // Пользователь не найден
      }

      // Проверяем, не друзья ли уже
      final existingFriends = await _databaseService.getFriendsByUserId(currentUserId);
      if (existingFriends.any((f) => f.friendId == user.id)) {
        return false; // Уже друзья
      }

      // Создаем приглашение
      final friend = Friend(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUserId,
        friendId: user.id,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _databaseService.insertFriend(friend);
      await _loadSentInvitations(currentUserId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Ошибка приглашения друга: $e');
      return false;
    }
  }

  // Принятие приглашения
  Future<void> acceptInvitation(String friendId) async {
    try {
      await _databaseService.updateFriendStatus(friendId, 'accepted');
      await _loadFriends(friendId);
      await _loadPendingInvitations(friendId);
      notifyListeners();
    } catch (e) {
      print('Ошибка принятия приглашения: $e');
    }
  }

  // Отклонение приглашения
  Future<void> declineInvitation(String friendId) async {
    try {
      await _databaseService.updateFriendStatus(friendId, 'declined');
      await _loadPendingInvitations(friendId);
      notifyListeners();
    } catch (e) {
      print('Ошибка отклонения приглашения: $e');
    }
  }

  // Удаление друга
  Future<void> removeFriend(String friendId) async {
    try {
      await _databaseService.deleteFriend(friendId);
      await _loadFriends(friendId);
      notifyListeners();
    } catch (e) {
      print('Ошибка удаления друга: $e');
    }
  }

  // Обновление локации друга
  Future<void> updateFriendLocation(String friendId, double latitude, double longitude, String? locationName) async {
    try {
      await _databaseService.updateFriendLocation(friendId, latitude, longitude, locationName);
      await _loadFriends(friendId);
      notifyListeners();
    } catch (e) {
      print('Ошибка обновления локации друга: $e');
    }
  }

  // Получение друзей с локацией
  Future<List<Friend>> getFriendsWithLocation(String userId) async {
    try {
      return await _databaseService.getFriendsWithLocation(userId);
    } catch (e) {
      print('Ошибка получения друзей с локацией: $e');
      return [];
    }
  }

  // Генерация кода приглашения
  void _generateInvitationCode() {
    final random = Random();
    _invitationCode = 'FRIEND${random.nextInt(999999).toString().padLeft(6, '0')}';
  }

  // Получение кода приглашения пользователя
  Future<String> getUserInvitationCode(String userId) async {
    try {
      // Получаем код из базы данных или генерируем новый
      final user = await _databaseService.getUserById(userId);
      if (user != null) {
        // Если у пользователя уже есть код, возвращаем его
        final existingCode = await _databaseService.getUserInvitationCode(userId);
        if (existingCode != null && existingCode.isNotEmpty) {
          return existingCode;
        }
        
        // Генерируем новый код
        final newCode = 'FRIEND${Random().nextInt(999999).toString().padLeft(6, '0')}';
        await _databaseService.saveUserInvitationCode(userId, newCode);
        return newCode;
      }
      return 'ERROR';
    } catch (e) {
      print('Ошибка получения кода приглашения: $e');
      return 'ERROR';
    }
  }

  // Приглашение по коду
  Future<bool> inviteFriendByCode(String code, String currentUserId) async {
    try {
      // Ищем пользователя по коду приглашения
      final invitedUserId = await _databaseService.getUserIdByInvitationCode(code);
      if (invitedUserId == null) {
        return false; // Код не найден
      }

      if (invitedUserId == currentUserId) {
        return false; // Нельзя пригласить самого себя
      }

      // Проверяем, не друзья ли уже
      final existingFriends = await _databaseService.getFriendsByUserId(currentUserId);
      if (existingFriends.any((f) => f.friendId == invitedUserId)) {
        return false; // Уже друзья
      }

      // Создаем приглашение
      final friend = Friend(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUserId,
        friendId: invitedUserId,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _databaseService.insertFriend(friend);
      await _loadSentInvitations(currentUserId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Ошибка приглашения по коду: $e');
      return false;
    }
  }

  // Обновление статуса друга
  Future<void> updateFriendStatus(String friendId, String status) async {
    try {
      await _databaseService.updateFriendStatus(friendId, status);
      await _loadFriends(friendId);
      notifyListeners();
    } catch (e) {
      print('Ошибка обновления статуса друга: $e');
    }
  }

  // Получение информации о друге
  Future<User?> getFriendInfo(String friendId) async {
    try {
      return await _databaseService.getUserById(friendId);
    } catch (e) {
      print('Ошибка получения информации о друге: $e');
      return null;
    }
  }

  // Отклонение приглашения
  Future<void> rejectInvitation(String friendId) async {
    try {
      await _databaseService.updateFriendStatus(friendId, 'declined');
      await _loadPendingInvitations(friendId);
      notifyListeners();
    } catch (e) {
      print('Ошибка отклонения приглашения: $e');
    }
  }

  // Отправка приглашения
  Future<bool> sendInvitation(String email) async {
    try {
      // Получаем текущего пользователя из AuthProvider
      // Пока используем простую логику
      return await inviteFriendByEmail(email, 'current_user_id');
    } catch (e) {
      print('Ошибка отправки приглашения: $e');
      return false;
    }
  }

  // Обновление списка друзей
  Future<void> refreshFriends(String userId) async {
    await _loadFriends(userId);
    await _loadPendingInvitations(userId);
    await _loadSentInvitations(userId);
  }

  // Загрузка кода приглашения для текущего пользователя
  Future<void> loadInvitationCode(String userId) async {
    try {
      _invitationCode = await getUserInvitationCode(userId);
      notifyListeners();
    } catch (e) {
      print('Ошибка загрузки кода приглашения: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}