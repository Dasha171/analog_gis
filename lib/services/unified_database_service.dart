import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/organization_model.dart';
import '../models/advertisement_model.dart';
import '../models/friend_model.dart';
import '../models/manager_permissions_model.dart';
import '../models/business_user_model.dart';
import 'cross_platform_sync_service.dart';

/// Единый сервис для хранения всех данных приложения
/// Использует SharedPreferences для обеих платформ (веб и мобильная)
class UnifiedDatabaseService {
  static final UnifiedDatabaseService _instance = UnifiedDatabaseService._internal();
  factory UnifiedDatabaseService() => _instance;
  UnifiedDatabaseService._internal();

  // Кэш для быстрого доступа
  Map<String, dynamic> _usersCache = {};
  Map<String, dynamic> _organizationsCache = {};
  Map<String, dynamic> _advertisementsCache = {};
  bool _cacheInitialized = false;

  // Инициализация кэша
  Future<void> _initializeCache() async {
    if (_cacheInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Загружаем только основные данные в кэш
      final usersJson = prefs.getString('unified_users') ?? '[]';
      _usersCache = {'data': json.decode(usersJson), 'timestamp': DateTime.now().millisecondsSinceEpoch};
      
      _cacheInitialized = true;
      print('✅ Кэш инициализирован');
    } catch (e) {
      print('❌ Ошибка инициализации кэша: $e');
    }
  }

  // Сохранение кода приглашения пользователя
  Future<void> saveUserInvitationCode(String userId, String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final codesJson = prefs.getString('user_invitation_codes') ?? '{}';
      final Map<String, dynamic> codesMap = json.decode(codesJson);
      
      codesMap[userId] = code;
      await prefs.setString('user_invitation_codes', json.encode(codesMap));
      print('✅ Код приглашения сохранен для пользователя $userId: $code');
    } catch (e) {
      print('❌ Ошибка сохранения кода приглашения: $e');
    }
  }

  // Получение кода приглашения пользователя
  Future<String?> getUserInvitationCode(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final codesJson = prefs.getString('user_invitation_codes') ?? '{}';
      final Map<String, dynamic> codesMap = json.decode(codesJson);
      
      return codesMap[userId] as String?;
    } catch (e) {
      print('❌ Ошибка получения кода приглашения: $e');
      return null;
    }
  }

  // Получение ID пользователя по коду приглашения
  Future<String?> getUserIdByInvitationCode(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final codesJson = prefs.getString('user_invitation_codes') ?? '{}';
      final Map<String, dynamic> codesMap = json.decode(codesJson);
      
      // Ищем пользователя по коду
      for (final entry in codesMap.entries) {
        if (entry.value == code) {
          return entry.key;
        }
      }
      return null;
    } catch (e) {
      print('❌ Ошибка поиска пользователя по коду: $e');
      return null;
    }
  }

  Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('unified_users') ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);
      
      print('🔍 СОХРАНЕНИЕ ПОЛЬЗОВАТЕЛЯ: ${user.email}');
      print('🔍 ТЕКУЩЕЕ КОЛИЧЕСТВО ПОЛЬЗОВАТЕЛЕЙ: ${usersList.length}');
      
      // Удаляем существующего пользователя с таким же email
      final beforeCount = usersList.length;
      usersList.removeWhere((u) => u['email'] == user.email);
      final afterRemoveCount = usersList.length;
      print('🔍 УДАЛЕНО ПОЛЬЗОВАТЕЛЕЙ: ${beforeCount - afterRemoveCount}');
      
      // Добавляем нового пользователя
      usersList.add(user.toJson());
      print('🔍 ДОБАВЛЕН ПОЛЬЗОВАТЕЛЬ: ${user.email}');
      
      await prefs.setString('unified_users', json.encode(usersList));
      print('✅ Пользователь сохранен: ${user.email} (всего: ${usersList.length})');
      
      // Проверяем, что данные действительно сохранились
      final savedJson = prefs.getString('unified_users') ?? '[]';
      final savedList = json.decode(savedJson) as List;
      print('🔍 ПРОВЕРКА СОХРАНЕНИЯ: ${savedList.length} пользователей в SharedPreferences');
      
      // Синхронизируем данные между платформами
      await CrossPlatformSyncService().syncUsers();
      
    } catch (e) {
      print('❌ Ошибка сохранения пользователя: $e');
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      // Сначала пытаемся загрузить синхронизированные данные
      final syncedUsers = await CrossPlatformSyncService().loadSyncedUsers();
      if (syncedUsers.isNotEmpty) {
        print('🔍 ЗАГРУЗКА СИНХРОНИЗИРОВАННЫХ ПОЛЬЗОВАТЕЛЕЙ: ${syncedUsers.length}');
        return syncedUsers;
      }
      
      // Если синхронизированных данных нет, загружаем локальные
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('unified_users') ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);
      
      print('🔍 ЗАГРУЗКА ЛОКАЛЬНЫХ ПОЛЬЗОВАТЕЛЕЙ: ${usersList.length} пользователей');
      for (final userJson in usersList) {
        print('  - ${userJson['email']}: ${userJson['firstName']} ${userJson['lastName']} (${userJson['role']})');
      }
      
      return usersList.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      print('❌ Ошибка получения пользователей: $e');
      return [];
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

  Future<User?> getUserById(String id) async {
    try {
      final users = await getAllUsers();
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('unified_users') ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);
      
      // Находим и обновляем пользователя
      final index = usersList.indexWhere((u) => u['id'] == user.id);
      if (index != -1) {
        usersList[index] = user.toJson();
        await prefs.setString('unified_users', json.encode(usersList));
        print('✅ Пользователь обновлен: ${user.email}');
      }
    } catch (e) {
      print('❌ Ошибка обновления пользователя: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('unified_users') ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);
      
      // Удаляем пользователя
      usersList.removeWhere((u) => u['id'] == id);
      await prefs.setString('unified_users', json.encode(usersList));
      print('✅ Пользователь удален: $id');
    } catch (e) {
      print('❌ Ошибка удаления пользователя: $e');
    }
  }

  // ========== ОРГАНИЗАЦИИ ==========

  Future<void> saveOrganization(Organization organization) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orgsJson = prefs.getString('unified_organizations') ?? '[]';
      final List<dynamic> orgsList = json.decode(orgsJson);
      
      // Удаляем существующую организацию с таким же id
      orgsList.removeWhere((o) => o['id'] == organization.id);
      
      // Добавляем новую организацию
      orgsList.add(organization.toJson());
      
      await prefs.setString('unified_organizations', json.encode(orgsList));
      print('✅ Организация сохранена: ${organization.name}');
    } catch (e) {
      print('❌ Ошибка сохранения организации: $e');
    }
  }

  Future<List<Organization>> getAllOrganizations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orgsJson = prefs.getString('unified_organizations') ?? '[]';
      final List<dynamic> orgsList = json.decode(orgsJson);
      
      print('🔍 Получены организации: ${orgsList.length}');
      return orgsList.map((json) => Organization.fromJson(json)).toList();
    } catch (e) {
      print('❌ Ошибка получения организаций: $e');
      return [];
    }
  }

  Future<void> updateOrganization(Organization organization) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orgsJson = prefs.getString('unified_organizations') ?? '[]';
      final List<dynamic> orgsList = json.decode(orgsJson);
      
      // Находим и обновляем организацию
      final index = orgsList.indexWhere((o) => o['id'] == organization.id);
      if (index != -1) {
        orgsList[index] = organization.toJson();
        await prefs.setString('unified_organizations', json.encode(orgsList));
        print('✅ Организация обновлена: ${organization.name}');
      }
    } catch (e) {
      print('❌ Ошибка обновления организации: $e');
    }
  }

  Future<void> deleteOrganization(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orgsJson = prefs.getString('unified_organizations') ?? '[]';
      final List<dynamic> orgsList = json.decode(orgsJson);
      
      // Удаляем организацию
      orgsList.removeWhere((o) => o['id'] == id);
      await prefs.setString('unified_organizations', json.encode(orgsList));
      print('✅ Организация удалена: $id');
    } catch (e) {
      print('❌ Ошибка удаления организации: $e');
    }
  }

  // ========== ОБЪЯВЛЕНИЯ ==========

  Future<void> saveAdvertisement(Advertisement advertisement) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adsJson = prefs.getString('unified_advertisements') ?? '[]';
      final List<dynamic> adsList = json.decode(adsJson);
      
      // Удаляем существующее объявление с таким же id
      adsList.removeWhere((a) => a['id'] == advertisement.id);
      
      // Добавляем новое объявление
      adsList.add(advertisement.toJson());
      
      await prefs.setString('unified_advertisements', json.encode(adsList));
      print('✅ Объявление сохранено: ${advertisement.title}');
    } catch (e) {
      print('❌ Ошибка сохранения объявления: $e');
    }
  }

  Future<List<Advertisement>> getAllAdvertisements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adsJson = prefs.getString('unified_advertisements') ?? '[]';
      final List<dynamic> adsList = json.decode(adsJson);
      
      print('🔍 Получены объявления: ${adsList.length}');
      return adsList.map((json) => Advertisement.fromJson(json)).toList();
    } catch (e) {
      print('❌ Ошибка получения объявлений: $e');
      return [];
    }
  }

  Future<void> updateAdvertisement(Advertisement advertisement) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adsJson = prefs.getString('unified_advertisements') ?? '[]';
      final List<dynamic> adsList = json.decode(adsJson);
      
      // Находим и обновляем объявление
      final index = adsList.indexWhere((a) => a['id'] == advertisement.id);
      if (index != -1) {
        adsList[index] = advertisement.toJson();
        await prefs.setString('unified_advertisements', json.encode(adsList));
        print('✅ Объявление обновлено: ${advertisement.title}');
      }
    } catch (e) {
      print('❌ Ошибка обновления объявления: $e');
    }
  }

  Future<void> deleteAdvertisement(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adsJson = prefs.getString('unified_advertisements') ?? '[]';
      final List<dynamic> adsList = json.decode(adsJson);
      
      // Удаляем объявление
      adsList.removeWhere((a) => a['id'] == id);
      await prefs.setString('unified_advertisements', json.encode(adsList));
      print('✅ Объявление удалено: $id');
    } catch (e) {
      print('❌ Ошибка удаления объявления: $e');
    }
  }

  // ========== ДРУЗЬЯ ==========

  // Сохранение друга
  Future<void> saveFriend(Friend friend) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('unified_friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      // Удаляем существующего друга с таким же id
      friendsList.removeWhere((f) => f['id'] == friend.id);
      
      // Добавляем нового друга
      friendsList.add(friend.toJson());
      
      await prefs.setString('unified_friends', json.encode(friendsList));
      print('✅ Друг сохранен: ${friend.friendId}');
    } catch (e) {
      print('❌ Ошибка сохранения друга: $e');
    }
  }

  // Вставка друга (алиас для saveFriend)
  Future<void> insertFriend(Friend friend) async {
    await saveFriend(friend);
  }

  // Получение друзей пользователя
  Future<List<Friend>> getFriendsByUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('unified_friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      return friendsList
          .where((f) => f['userId'] == userId && f['status'] == 'accepted')
          .map((f) => Friend.fromJson(f as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Ошибка получения друзей: $e');
      return [];
    }
  }

  // Обновление статуса друга
  Future<void> updateFriendStatus(String friendId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('unified_friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      for (int i = 0; i < friendsList.length; i++) {
        if (friendsList[i]['id'] == friendId) {
          friendsList[i]['status'] = status;
          if (status == 'accepted') {
            friendsList[i]['acceptedAt'] = DateTime.now().toIso8601String();
          }
          break;
        }
      }
      
      await prefs.setString('unified_friends', json.encode(friendsList));
      print('✅ Статус друга обновлен: $friendId -> $status');
    } catch (e) {
      print('❌ Ошибка обновления статуса друга: $e');
    }
  }

  // Обновление локации друга
  Future<void> updateFriendLocation(String friendId, double latitude, double longitude, String? locationName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('unified_friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      for (int i = 0; i < friendsList.length; i++) {
        if (friendsList[i]['id'] == friendId) {
          friendsList[i]['latitude'] = latitude;
          friendsList[i]['longitude'] = longitude;
          friendsList[i]['locationName'] = locationName;
          friendsList[i]['lastLocationUpdate'] = DateTime.now().toIso8601String();
          break;
        }
      }
      
      await prefs.setString('unified_friends', json.encode(friendsList));
      print('✅ Локация друга обновлена: $friendId');
    } catch (e) {
      print('❌ Ошибка обновления локации друга: $e');
    }
  }

  // Получение друзей с локацией
  Future<List<Friend>> getFriendsWithLocation(String userId) async {
    try {
      final friends = await getFriendsByUserId(userId);
      return friends.where((f) => f.latitude != null && f.longitude != null).toList();
    } catch (e) {
      print('❌ Ошибка получения друзей с локацией: $e');
      return [];
    }
  }

  Future<List<Friend>> getAllFriends() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('unified_friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      print('🔍 Получены друзья: ${friendsList.length}');
      return friendsList.map((json) => Friend.fromJson(json)).toList();
    } catch (e) {
      print('❌ Ошибка получения друзей: $e');
      return [];
    }
  }

  Future<List<Friend>> getPendingFriendsByUserId(String userId) async {
    try {
      final friends = await getAllFriends();
      return friends.where((f) => f.friendId == userId && f.status == 'pending').toList();
    } catch (e) {
      print('❌ Ошибка получения ожидающих друзей: $e');
      return [];
    }
  }

  Future<void> updateFriend(Friend friend) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('unified_friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      // Находим и обновляем друга
      final index = friendsList.indexWhere((f) => f['id'] == friend.id);
      if (index != -1) {
        friendsList[index] = friend.toJson();
        await prefs.setString('unified_friends', json.encode(friendsList));
        print('✅ Друг обновлен: ${friend.friendId}');
      }
    } catch (e) {
      print('❌ Ошибка обновления друга: $e');
    }
  }

  Future<void> deleteFriend(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString('unified_friends') ?? '[]';
      final List<dynamic> friendsList = json.decode(friendsJson);
      
      // Удаляем друга
      friendsList.removeWhere((f) => f['id'] == id);
      await prefs.setString('unified_friends', json.encode(friendsList));
      print('✅ Друг удален: $id');
    } catch (e) {
      print('❌ Ошибка удаления друга: $e');
    }
  }

  // ========== РАЗРЕШЕНИЯ МЕНЕДЖЕРОВ ==========

  Future<void> saveManagerPermissions(ManagerPermissions permissions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permsJson = prefs.getString('unified_manager_permissions') ?? '[]';
      final List<dynamic> permsList = json.decode(permsJson);
      
      // Удаляем существующие разрешения с таким же managerId
      permsList.removeWhere((p) => p['managerId'] == permissions.managerId);
      
      // Добавляем новые разрешения
      permsList.add(permissions.toJson());
      
      await prefs.setString('unified_manager_permissions', json.encode(permsList));
      print('✅ Разрешения менеджера сохранены: ${permissions.managerId}');
    } catch (e) {
      print('❌ Ошибка сохранения разрешений менеджера: $e');
    }
  }

  Future<List<ManagerPermissions>> getAllManagerPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permsJson = prefs.getString('unified_manager_permissions') ?? '[]';
      final List<dynamic> permsList = json.decode(permsJson);
      
      print('🔍 Получены разрешения менеджеров: ${permsList.length}');
      return permsList.map((json) => ManagerPermissions.fromJson(json)).toList();
    } catch (e) {
      print('❌ Ошибка получения разрешений менеджеров: $e');
      return [];
    }
  }

  Future<ManagerPermissions?> getManagerPermissions(String managerId) async {
    try {
      final permissions = await getAllManagerPermissions();
      return permissions.firstWhere((p) => p.managerId == managerId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateManagerPermissions(ManagerPermissions permissions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permsJson = prefs.getString('unified_manager_permissions') ?? '[]';
      final List<dynamic> permsList = json.decode(permsJson);
      
      // Находим и обновляем разрешения
      final index = permsList.indexWhere((p) => p['managerId'] == permissions.managerId);
      if (index != -1) {
        permsList[index] = permissions.toJson();
        await prefs.setString('unified_manager_permissions', json.encode(permsList));
        print('✅ Разрешения менеджера обновлены: ${permissions.managerId}');
      }
    } catch (e) {
      print('❌ Ошибка обновления разрешений менеджера: $e');
    }
  }

  Future<void> deleteManagerPermissions(String managerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permsJson = prefs.getString('unified_manager_permissions') ?? '[]';
      final List<dynamic> permsList = json.decode(permsJson);
      
      // Удаляем разрешения
      permsList.removeWhere((p) => p['managerId'] == managerId);
      await prefs.setString('unified_manager_permissions', json.encode(permsList));
      print('✅ Разрешения менеджера удалены: $managerId');
    } catch (e) {
      print('❌ Ошибка удаления разрешений менеджера: $e');
    }
  }

  // ========== БИЗНЕС ПОЛЬЗОВАТЕЛИ ==========

  Future<void> saveBusinessUser(BusinessUser businessUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final businessUsersJson = prefs.getString('unified_business_users') ?? '[]';
      final List<dynamic> businessUsersList = json.decode(businessUsersJson);
      
      // Удаляем существующего бизнес-пользователя с таким же email
      businessUsersList.removeWhere((u) => u['email'] == businessUser.email);
      
      // Добавляем нового бизнес-пользователя
      businessUsersList.add(businessUser.toJson());
      
      await prefs.setString('unified_business_users', json.encode(businessUsersList));
      print('✅ Бизнес-пользователь сохранен: ${businessUser.email}');
    } catch (e) {
      print('❌ Ошибка сохранения бизнес-пользователя: $e');
    }
  }

  Future<List<BusinessUser>> getAllBusinessUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final businessUsersJson = prefs.getString('unified_business_users') ?? '[]';
      final List<dynamic> businessUsersList = json.decode(businessUsersJson);
      
      print('🔍 Получены бизнес-пользователи: ${businessUsersList.length}');
      return businessUsersList.map((json) => BusinessUser.fromJson(json)).toList();
    } catch (e) {
      print('❌ Ошибка получения бизнес-пользователей: $e');
      return [];
    }
  }

  Future<BusinessUser?> getBusinessUserByEmail(String email) async {
    try {
      final businessUsers = await getAllBusinessUsers();
      return businessUsers.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // ========== СИСТЕМНЫЕ МЕТОДЫ ==========

  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('unified_users');
      await prefs.remove('unified_organizations');
      await prefs.remove('unified_advertisements');
      await prefs.remove('unified_friends');
      await prefs.remove('unified_manager_permissions');
      await prefs.remove('unified_business_users');
      print('✅ Все данные очищены');
    } catch (e) {
      print('❌ Ошибка очистки данных: $e');
    }
  }

  // ========== МИГРАЦИЯ ДАННЫХ ==========

  /// Мигрирует данные из старых ключей в новые
  Future<void> migrateData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Мигрируем пользователей
      final oldUsersJson = prefs.getString('users') ?? '[]';
      if (oldUsersJson != '[]') {
        await prefs.setString('unified_users', oldUsersJson);
        print('✅ Пользователи мигрированы');
      }
      
      // Мигрируем организации
      final oldOrgsJson = prefs.getString('organizations') ?? '[]';
      if (oldOrgsJson != '[]') {
        await prefs.setString('unified_organizations', oldOrgsJson);
        print('✅ Организации мигрированы');
      }
      
      // Мигрируем объявления
      final oldAdsJson = prefs.getString('advertisements') ?? '[]';
      if (oldAdsJson != '[]') {
        await prefs.setString('unified_advertisements', oldAdsJson);
        print('✅ Объявления мигрированы');
      }
      
      // Мигрируем друзей
      final oldFriendsJson = prefs.getString('friends') ?? '[]';
      if (oldFriendsJson != '[]') {
        await prefs.setString('unified_friends', oldFriendsJson);
        print('✅ Друзья мигрированы');
      }
      
      // Мигрируем разрешения менеджеров
      final oldPermsJson = prefs.getString('manager_permissions') ?? '[]';
      if (oldPermsJson != '[]') {
        await prefs.setString('unified_manager_permissions', oldPermsJson);
        print('✅ Разрешения менеджеров мигрированы');
      }
      
      print('✅ Миграция данных завершена');
    } catch (e) {
      print('❌ Ошибка миграции данных: $e');
    }
  }
}
