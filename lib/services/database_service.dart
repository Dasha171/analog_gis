import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/organization_model.dart';
import '../models/advertisement_model.dart';
import '../models/friend_model.dart';
import '../models/manager_permissions_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // ========== ПОЛЬЗОВАТЕЛИ ==========

  Future<void> insertUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);
      
      // Удаляем существующего пользователя с таким же email
      usersList.removeWhere((u) => u['email'] == user.email);
      
      // Добавляем нового пользователя
      usersList.add(user.toJson());
      
      await prefs.setString('users', json.encode(usersList));
      print('✅ Пользователь добавлен: ${user.email}');
    } catch (e) {
      print('❌ Ошибка добавления пользователя: $e');
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);
      
      print('🔍 Получены данные пользователей из SharedPreferences: ${usersList.length}');
      return usersList.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      print('❌ Ошибка получения пользователей: $e');
      return [];
    }
  }

  Future<User?> getUserById(String id) async {
    try {
      final users = await getAllUsers();
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final users = await getAllUsers();
      return users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);
      
      // Находим и обновляем пользователя
      final index = usersList.indexWhere((u) => u['id'] == user.id);
      if (index != -1) {
        usersList[index] = user.toJson();
        await prefs.setString('users', json.encode(usersList));
        print('✅ Пользователь обновлен: ${user.email}');
      }
    } catch (e) {
      print('❌ Ошибка обновления пользователя: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);
      
      // Удаляем пользователя
      usersList.removeWhere((u) => u['id'] == id);
      await prefs.setString('users', json.encode(usersList));
      print('✅ Пользователь удален: $id');
    } catch (e) {
      print('❌ Ошибка удаления пользователя: $e');
    }
  }

  // ========== ОРГАНИЗАЦИИ ==========

  Future<void> insertOrganization(Organization organization) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orgsJson = prefs.getString('organizations') ?? '[]';
      final List<dynamic> orgsList = json.decode(orgsJson);
      
      // Удаляем существующую организацию с таким же id
      orgsList.removeWhere((o) => o['id'] == organization.id);
      
      // Добавляем новую организацию
      orgsList.add(organization.toJson());
      
      await prefs.setString('organizations', json.encode(orgsList));
      print('✅ Организация добавлена: ${organization.name}');
    } catch (e) {
      print('❌ Ошибка добавления организации: $e');
    }
  }

  Future<List<Organization>> getAllOrganizations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orgsJson = prefs.getString('organizations') ?? '[]';
      final List<dynamic> orgsList = json.decode(orgsJson);
      
      print('🔍 Получены данные организаций из SharedPreferences: ${orgsList.length}');
      return orgsList.map((json) => Organization.fromJson(json)).toList();
    } catch (e) {
      print('❌ Ошибка получения организаций: $e');
      return [];
    }
  }

  Future<List<Organization>> getOrganizationsByCategory(String category) async {
    try {
      final organizations = await getAllOrganizations();
      return organizations.where((org) => org.category == category).toList();
    } catch (e) {
      print('❌ Ошибка получения организаций по категории: $e');
      return [];
    }
  }

  Future<List<Organization>> searchOrganizations(String query) async {
    try {
      final organizations = await getAllOrganizations();
      return organizations.where((org) => 
        org.name.toLowerCase().contains(query.toLowerCase()) ||
        org.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      print('❌ Ошибка поиска организаций: $e');
      return [];
    }
  }

  Future<List<Organization>> getOrganizationsNearby(double latitude, double longitude, double radiusKm) async {
    try {
      final organizations = await getAllOrganizations();
      return organizations.where((org) {
        final distance = _calculateDistance(latitude, longitude, org.latitude, org.longitude);
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      print('❌ Ошибка получения ближайших организаций: $e');
      return [];
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Радиус Земли в километрах
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  Future<void> updateOrganization(Organization organization) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orgsJson = prefs.getString('organizations') ?? '[]';
      final List<dynamic> orgsList = json.decode(orgsJson);
      
      // Находим и обновляем организацию
      final index = orgsList.indexWhere((o) => o['id'] == organization.id);
      if (index != -1) {
        orgsList[index] = organization.toJson();
        await prefs.setString('organizations', json.encode(orgsList));
        print('✅ Организация обновлена: ${organization.name}');
      }
    } catch (e) {
      print('❌ Ошибка обновления организации: $e');
    }
  }

  Future<void> deleteOrganization(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orgsJson = prefs.getString('organizations') ?? '[]';
      final List<dynamic> orgsList = json.decode(orgsJson);
      
      // Удаляем организацию
      orgsList.removeWhere((o) => o['id'] == id);
      await prefs.setString('organizations', json.encode(orgsList));
      print('✅ Организация удалена: $id');
    } catch (e) {
      print('❌ Ошибка удаления организации: $e');
    }
  }

  // ========== ОБЪЯВЛЕНИЯ ==========

  Future<void> insertAdvertisement(Advertisement advertisement) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adsJson = prefs.getString('advertisements') ?? '[]';
      final List<dynamic> adsList = json.decode(adsJson);
      
      // Удаляем существующее объявление с таким же id
      adsList.removeWhere((a) => a['id'] == advertisement.id);
      
      // Добавляем новое объявление
      adsList.add(advertisement.toJson());
      
      await prefs.setString('advertisements', json.encode(adsList));
      print('✅ Объявление добавлено: ${advertisement.title}');
    } catch (e) {
      print('❌ Ошибка добавления объявления: $e');
    }
  }

  Future<List<Advertisement>> getAllAdvertisements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adsJson = prefs.getString('advertisements') ?? '[]';
      final List<dynamic> adsList = json.decode(adsJson);
      
      print('🔍 Получены данные объявлений из SharedPreferences: ${adsList.length}');
      return adsList.map((json) => Advertisement.fromJson(json)).toList();
    } catch (e) {
      print('❌ Ошибка получения объявлений: $e');
      return [];
    }
  }

  Future<List<Advertisement>> getActiveAdvertisements() async {
    try {
      final advertisements = await getAllAdvertisements();
      final now = DateTime.now();
      return advertisements.where((ad) => 
        ad.isActive && 
        ad.startDate.isBefore(now) && 
        ad.endDate.isAfter(now)
      ).toList();
    } catch (e) {
      print('❌ Ошибка получения активных объявлений: $e');
      return [];
    }
  }

  Future<void> updateAdvertisement(Advertisement advertisement) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adsJson = prefs.getString('advertisements') ?? '[]';
      final List<dynamic> adsList = json.decode(adsJson);
      
      // Находим и обновляем объявление
      final index = adsList.indexWhere((a) => a['id'] == advertisement.id);
      if (index != -1) {
        adsList[index] = advertisement.toJson();
        await prefs.setString('advertisements', json.encode(adsList));
        print('✅ Объявление обновлено: ${advertisement.title}');
      }
    } catch (e) {
      print('❌ Ошибка обновления объявления: $e');
    }
  }

  Future<void> deleteAdvertisement(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adsJson = prefs.getString('advertisements') ?? '[]';
      final List<dynamic> adsList = json.decode(adsJson);
      
      // Удаляем объявление
      adsList.removeWhere((a) => a['id'] == id);
      await prefs.setString('advertisements', json.encode(adsList));
      print('✅ Объявление удалено: $id');
    } catch (e) {
      print('❌ Ошибка удаления объявления: $e');
    }
  }

  Future<void> incrementAdvertisementViews(String id) async {
    try {
      final advertisements = await getAllAdvertisements();
      final adIndex = advertisements.indexWhere((ad) => ad.id == id);
      if (adIndex != -1) {
        final updatedAd = advertisements[adIndex].copyWith(
          viewCount: advertisements[adIndex].viewCount + 1,
        );
        await updateAdvertisement(updatedAd);
      }
    } catch (e) {
      print('❌ Ошибка увеличения просмотров: $e');
    }
  }

  Future<void> incrementAdvertisementClicks(String id) async {
    try {
      final advertisements = await getAllAdvertisements();
      final adIndex = advertisements.indexWhere((ad) => ad.id == id);
      if (adIndex != -1) {
        final updatedAd = advertisements[adIndex].copyWith(
          clickCount: advertisements[adIndex].clickCount + 1,
        );
        await updateAdvertisement(updatedAd);
      }
    } catch (e) {
      print('❌ Ошибка увеличения кликов: $e');
    }
  }

  // ========== ДРУЗЬЯ ==========

  Future<void> insertFriend(Friend friend) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      // Удаляем существующего друга с таким же id
      friendsList.removeWhere((f) => f['id'] == friend.id);
      
      // Добавляем нового друга
      friendsList.add(friend.toJson());
      
      await prefs.setString('friends', json.encode(friendsList));
      print('✅ Друг добавлен: ${friend.friendId}');
    } catch (e) {
      print('❌ Ошибка добавления друга: $e');
    }
  }

  Future<List<Friend>> getFriendsByUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      final userFriends = friendsList
          .where((f) => f['userId'] == userId && f['status'] == 'accepted')
          .map((json) => Friend.fromJson(json))
          .toList();
      
      return userFriends;
    } catch (e) {
      print('❌ Ошибка получения друзей: $e');
      return [];
    }
  }

  Future<List<Friend>> getPendingFriendsByUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      final pendingFriends = friendsList
          .where((f) => f['friendId'] == userId && f['status'] == 'pending')
          .map((json) => Friend.fromJson(json))
          .toList();
      
      return pendingFriends;
    } catch (e) {
      print('❌ Ошибка получения ожидающих друзей: $e');
      return [];
    }
  }

  Future<void> updateFriendStatus(String friendId, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      // Находим и обновляем статус друга
      final index = friendsList.indexWhere((f) => f['id'] == friendId);
      if (index != -1) {
        friendsList[index]['status'] = newStatus;
        if (newStatus == 'accepted') {
          friendsList[index]['acceptedAt'] = DateTime.now().toIso8601String();
        }
        await prefs.setString('friends', json.encode(friendsList));
        print('✅ Статус друга обновлен: $newStatus');
      }
    } catch (e) {
      print('❌ Ошибка обновления статуса друга: $e');
    }
  }

  Future<void> updateFriendLocation(String friendId, double latitude, double longitude, String? locationName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      // Находим и обновляем локацию друга
      final index = friendsList.indexWhere((f) => f['id'] == friendId);
      if (index != -1) {
        friendsList[index]['latitude'] = latitude;
        friendsList[index]['longitude'] = longitude;
        friendsList[index]['locationName'] = locationName;
        friendsList[index]['lastLocationUpdate'] = DateTime.now().toIso8601String();
        await prefs.setString('friends', json.encode(friendsList));
        print('✅ Локация друга обновлена');
      }
    } catch (e) {
      print('❌ Ошибка обновления локации друга: $e');
    }
  }

  Future<List<Friend>> getFriendsWithLocation(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      final friendsWithLocation = friendsList
          .where((f) => 
            f['userId'] == userId && 
            f['status'] == 'accepted' && 
            f['shareLocation'] == 1 && 
            f['latitude'] != null && 
            f['longitude'] != null
          )
          .map((json) => Friend.fromJson(json))
          .toList();
      
      return friendsWithLocation;
    } catch (e) {
      print('❌ Ошибка получения друзей с локацией: $e');
      return [];
    }
  }

  Future<void> deleteFriend(String friendId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      // Удаляем друга
      friendsList.removeWhere((f) => f['id'] == friendId);
      await prefs.setString('friends', json.encode(friendsList));
      print('✅ Друг удален: $friendId');
    } catch (e) {
      print('❌ Ошибка удаления друга: $e');
    }
  }

  // ========== МЕНЕДЖЕРЫ И РАЗРЕШЕНИЯ ==========

  Future<void> insertManagerPermissions(ManagerPermissions permissions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permsJson = prefs.getString('manager_permissions') ?? '[]';
      final List<dynamic> permsList = json.decode(permsJson);
      
      // Удаляем существующие разрешения с таким же managerId
      permsList.removeWhere((p) => p['managerId'] == permissions.managerId);
      
      // Добавляем новые разрешения
      permsList.add(permissions.toJson());
      
      await prefs.setString('manager_permissions', json.encode(permsList));
      print('✅ Разрешения менеджера добавлены: ${permissions.managerId}');
    } catch (e) {
      print('❌ Ошибка добавления разрешений менеджера: $e');
    }
  }

  Future<ManagerPermissions?> getManagerPermissions(String managerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permsJson = prefs.getString('manager_permissions') ?? '[]';
      final List<dynamic> permsList = json.decode(permsJson);
      
      final managerPerms = permsList
          .where((p) => p['managerId'] == managerId)
          .map((json) => ManagerPermissions.fromJson(json))
          .toList();
      
      return managerPerms.isNotEmpty ? managerPerms.first : null;
    } catch (e) {
      print('❌ Ошибка получения разрешений менеджера: $e');
      return null;
    }
  }

  Future<void> updateManagerPermissions(ManagerPermissions permissions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permsJson = prefs.getString('manager_permissions') ?? '[]';
      final List<dynamic> permsList = json.decode(permsJson);
      
      // Находим и обновляем разрешения
      final index = permsList.indexWhere((p) => p['managerId'] == permissions.managerId);
      if (index != -1) {
        permsList[index] = permissions.toJson();
        await prefs.setString('manager_permissions', json.encode(permsList));
        print('✅ Разрешения менеджера обновлены: ${permissions.managerId}');
      }
    } catch (e) {
      print('❌ Ошибка обновления разрешений менеджера: $e');
    }
  }

  Future<void> deleteManagerPermissions(String managerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permsJson = prefs.getString('manager_permissions') ?? '[]';
      final List<dynamic> permsList = json.decode(permsJson);
      
      // Удаляем разрешения
      permsList.removeWhere((p) => p['managerId'] == managerId);
      await prefs.setString('manager_permissions', json.encode(permsList));
      print('✅ Разрешения менеджера удалены: $managerId');
    } catch (e) {
      print('❌ Ошибка удаления разрешений менеджера: $e');
    }
  }

  // ========== СИСТЕМНЫЕ МЕТОДЫ ==========

  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('users');
      await prefs.remove('organizations');
      await prefs.remove('advertisements');
      await prefs.remove('friends');
      await prefs.remove('manager_permissions');
      print('✅ Все данные очищены');
    } catch (e) {
      print('❌ Ошибка очистки данных: $e');
    }
  }
}