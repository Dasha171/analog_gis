import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class Friend {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final double? latitude;
  final double? longitude;
  final DateTime lastSeen;
  final bool isOnline;
  final String status; // 'pending', 'accepted', 'blocked'

  Friend({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.latitude,
    this.longitude,
    required this.lastSeen,
    required this.isOnline,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'lastSeen': lastSeen.toIso8601String(),
      'isOnline': isOnline,
      'status': status,
    };
  }

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      lastSeen: DateTime.parse(json['lastSeen']),
      isOnline: json['isOnline'],
      status: json['status'],
    );
  }

  Friend copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    double? latitude,
    double? longitude,
    DateTime? lastSeen,
    bool? isOnline,
    String? status,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      status: status ?? this.status,
    );
  }
}

class FriendsProvider extends ChangeNotifier {
  List<Friend> _friends = [];
  List<Friend> _pendingInvitations = [];
  List<Friend> _sentInvitations = [];
  bool _isLoading = false;
  String? _invitationCode;

  // Getters
  List<Friend> get friends => _friends.where((f) => f.status == 'accepted').toList();
  List<Friend> get pendingInvitations => _pendingInvitations.where((f) => f.status == 'pending').toList();
  List<Friend> get sentInvitations => _sentInvitations.where((f) => f.status == 'pending').toList();
  bool get isLoading => _isLoading;
  String? get invitationCode => _invitationCode;

  // Инициализация
  Future<void> initialize() async {
    _setLoading(true);
    await _loadFriendsData();
    await _generateInvitationCode();
    _setLoading(false);
  }

  // Загрузка данных из SharedPreferences
  Future<void> _loadFriendsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Загружаем друзей
      final friendsJson = prefs.getString('user_friends') ?? '[]';
      final friendsList = json.decode(friendsJson) as List;
      _friends = friendsList.map((json) => Friend.fromJson(json)).toList();

      // Загружаем входящие приглашения
      final pendingJson = prefs.getString('user_pending_invitations') ?? '[]';
      final pendingList = json.decode(pendingJson) as List;
      _pendingInvitations = pendingList.map((json) => Friend.fromJson(json)).toList();

      // Загружаем исходящие приглашения
      final sentJson = prefs.getString('user_sent_invitations') ?? '[]';
      final sentList = json.decode(sentJson) as List;
      _sentInvitations = sentList.map((json) => Friend.fromJson(json)).toList();

      print('Загружены друзья: ${_friends.length}, входящие: ${_pendingInvitations.length}, исходящие: ${_sentInvitations.length}');
    } catch (e) {
      print('Ошибка загрузки данных друзей: $e');
    }
  }

  // Сохранение данных в SharedPreferences
  Future<void> _saveFriendsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('user_friends', json.encode(_friends.map((e) => e.toJson()).toList()));
      await prefs.setString('user_pending_invitations', json.encode(_pendingInvitations.map((e) => e.toJson()).toList()));
      await prefs.setString('user_sent_invitations', json.encode(_sentInvitations.map((e) => e.toJson()).toList()));
      
      print('Данные друзей сохранены');
    } catch (e) {
      print('Ошибка сохранения данных друзей: $e');
    }
  }

  // Генерация кода приглашения
  Future<void> _generateInvitationCode() async {
    final prefs = await SharedPreferences.getInstance();
    _invitationCode = prefs.getString('user_invitation_code');
    
    if (_invitationCode == null) {
      _invitationCode = _generateRandomCode();
      await prefs.setString('user_invitation_code', _invitationCode!);
    }
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  // Принятие приглашения по коду
  Future<bool> acceptInvitationByCode(String code, String friendName, String friendEmail) async {
    try {
      // Проверяем, не добавлен ли уже этот пользователь
      if (_friends.any((f) => f.email == friendEmail)) {
        return false;
      }

      final friend = Friend(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: friendName,
        email: friendEmail,
        lastSeen: DateTime.now(),
        isOnline: true,
        status: 'accepted',
      );

      _friends.add(friend);
      await _saveFriendsData();
      notifyListeners();
      return true;
    } catch (e) {
      print('Ошибка принятия приглашения: $e');
      return false;
    }
  }

  // Отправка приглашения
  Future<bool> sendInvitation(String friendEmail) async {
    try {
      // Проверяем, не отправлено ли уже приглашение
      if (_sentInvitations.any((f) => f.email == friendEmail)) {
        return false;
      }

      final invitation = Friend(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Приглашение отправлено',
        email: friendEmail,
        lastSeen: DateTime.now(),
        isOnline: false,
        status: 'pending',
      );

      _sentInvitations.add(invitation);
      await _saveFriendsData();
      notifyListeners();
      return true;
    } catch (e) {
      print('Ошибка отправки приглашения: $e');
      return false;
    }
  }

  // Принятие входящего приглашения
  Future<void> acceptInvitation(String friendId) async {
    try {
      final invitationIndex = _pendingInvitations.indexWhere((f) => f.id == friendId);
      if (invitationIndex != -1) {
        final invitation = _pendingInvitations[invitationIndex];
        final friend = invitation.copyWith(status: 'accepted');
        
        _friends.add(friend);
        _pendingInvitations.removeAt(invitationIndex);
        
        await _saveFriendsData();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка принятия приглашения: $e');
    }
  }

  // Отклонение приглашения
  Future<void> rejectInvitation(String friendId) async {
    try {
      _pendingInvitations.removeWhere((f) => f.id == friendId);
      await _saveFriendsData();
      notifyListeners();
    } catch (e) {
      print('Ошибка отклонения приглашения: $e');
    }
  }

  // Удаление друга
  Future<void> removeFriend(String friendId) async {
    try {
      _friends.removeWhere((f) => f.id == friendId);
      await _saveFriendsData();
      notifyListeners();
    } catch (e) {
      print('Ошибка удаления друга: $e');
    }
  }

  // Обновление геолокации друга
  Future<void> updateFriendLocation(String friendId, double latitude, double longitude) async {
    try {
      final friendIndex = _friends.indexWhere((f) => f.id == friendId);
      if (friendIndex != -1) {
        _friends[friendIndex] = _friends[friendIndex].copyWith(
          latitude: latitude,
          longitude: longitude,
          lastSeen: DateTime.now(),
          isOnline: true,
        );
        await _saveFriendsData();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка обновления геолокации друга: $e');
    }
  }

  // Получение друзей с геолокацией
  List<Friend> getFriendsWithLocation() {
    return _friends.where((f) => f.latitude != null && f.longitude != null).toList();
  }

  // Получение онлайн друзей
  List<Friend> getOnlineFriends() {
    return _friends.where((f) => f.isOnline).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
