import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/advertisement_model.dart';

class AdvertisementProvider extends ChangeNotifier {
  List<Advertisement> _advertisements = [];
  List<City> _cities = [];
  List<ManagerPermissions> _managerPermissions = [];
  bool _isLoading = false;

  // Getters
  List<Advertisement> get advertisements => _advertisements;
  List<City> get cities => _cities;
  List<ManagerPermissions> get managerPermissions => _managerPermissions;
  bool get isLoading => _isLoading;

  // Получение одобренных рекламных объявлений для отображения
  List<Advertisement> get approvedAdvertisements {
    return _advertisements.where((ad) => ad.status == 'approved').toList();
  }

  // Получение рекламы по городу
  List<Advertisement> getAdvertisementsByCity(String cityId) {
    return approvedAdvertisements.where((ad) => ad.cityId == cityId).toList();
  }

  // Получение разрешений менеджера
  ManagerPermissions? getManagerPermissions(String managerId) {
    try {
      return _managerPermissions.firstWhere((perm) => perm.managerId == managerId);
    } catch (e) {
      return null;
    }
  }

  // Получение городов менеджера из AdminProvider
  List<City> getManagerCitiesFromAdmin(String managerId, List<String> cityIds) {
    return _cities.where((city) => cityIds.contains(city.id)).toList();
  }

  // Инициализация
  Future<void> initialize() async {
    _setLoading(true);
    await _loadCities();
    await _loadAdvertisements();
    await _loadManagerPermissions();
    _setLoading(false);
  }

  // Загрузка городов
  Future<void> _loadCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final citiesJson = prefs.getString('advertisement_cities') ?? '[]';
      final citiesList = json.decode(citiesJson) as List;
      _cities = citiesList.map((json) => City.fromJson(json)).toList();

      // Если нет городов, создаем демо данные
      if (_cities.isEmpty) {
        await _createDemoCities();
      }

      print('Загружены города: ${_cities.length}');
    } catch (e) {
      print('Ошибка загрузки городов: $e');
    }
  }

  // Создание демо городов
  Future<void> _createDemoCities() async {
    _cities = [
      // Основные города Казахстана
      City(
        id: '1',
        name: 'Алматы',
        country: 'Казахстан',
        latitude: 43.2220,
        longitude: 76.8512,
      ),
      City(
        id: '2',
        name: 'Нур-Султан',
        country: 'Казахстан',
        latitude: 51.1694,
        longitude: 71.4491,
      ),
      City(
        id: '3',
        name: 'Шымкент',
        country: 'Казахстан',
        latitude: 42.3417,
        longitude: 69.5901,
      ),
      City(
        id: '4',
        name: 'Актобе',
        country: 'Казахстан',
        latitude: 50.2800,
        longitude: 57.2100,
      ),
      City(
        id: '5',
        name: 'Тараз',
        country: 'Казахстан',
        latitude: 42.9000,
        longitude: 71.3667,
      ),
      City(
        id: '6',
        name: 'Павлодар',
        country: 'Казахстан',
        latitude: 52.3000,
        longitude: 76.9500,
      ),
      City(
        id: '7',
        name: 'Семей',
        country: 'Казахстан',
        latitude: 50.4000,
        longitude: 80.2500,
      ),
      City(
        id: '8',
        name: 'Усть-Каменогорск',
        country: 'Казахстан',
        latitude: 49.9500,
        longitude: 82.6167,
      ),
      City(
        id: '9',
        name: 'Караганда',
        country: 'Казахстан',
        latitude: 49.8000,
        longitude: 73.1167,
      ),
      City(
        id: '10',
        name: 'Атырау',
        country: 'Казахстан',
        latitude: 47.1167,
        longitude: 51.8833,
      ),
      City(
        id: '11',
        name: 'Костанай',
        country: 'Казахстан',
        latitude: 53.2167,
        longitude: 63.6333,
      ),
      City(
        id: '12',
        name: 'Кызылорда',
        country: 'Казахстан',
        latitude: 44.8500,
        longitude: 65.5167,
      ),
      City(
        id: '13',
        name: 'Уральск',
        country: 'Казахстан',
        latitude: 51.2333,
        longitude: 51.3667,
      ),
      City(
        id: '14',
        name: 'Петропавловск',
        country: 'Казахстан',
        latitude: 54.8667,
        longitude: 69.1500,
      ),
      City(
        id: '15',
        name: 'Туркестан',
        country: 'Казахстан',
        latitude: 43.3000,
        longitude: 68.2500,
      ),
      City(
        id: '16',
        name: 'Темиртау',
        country: 'Казахстан',
        latitude: 50.0500,
        longitude: 72.9667,
      ),
      City(
        id: '17',
        name: 'Экибастуз',
        country: 'Казахстан',
        latitude: 51.7167,
        longitude: 75.3167,
      ),
      City(
        id: '18',
        name: 'Жезказган',
        country: 'Казахстан',
        latitude: 47.7833,
        longitude: 67.7000,
      ),
      City(
        id: '19',
        name: 'Кокшетау',
        country: 'Казахстан',
        latitude: 53.2833,
        longitude: 69.4000,
      ),
      City(
        id: '20',
        name: 'Талдыкорган',
        country: 'Казахстан',
        latitude: 45.0167,
        longitude: 78.3667,
      ),
      // Дополнительные города России для демо
      City(
        id: '21',
        name: 'Москва',
        country: 'Россия',
        latitude: 55.7558,
        longitude: 37.6176,
      ),
      City(
        id: '22',
        name: 'Санкт-Петербург',
        country: 'Россия',
        latitude: 59.9311,
        longitude: 30.3609,
      ),
      City(
        id: '23',
        name: 'Минск',
        country: 'Беларусь',
        latitude: 53.9006,
        longitude: 27.5590,
      ),
    ];
    await _saveCities();
  }

  // Загрузка рекламных объявлений
  Future<void> _loadAdvertisements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adsJson = prefs.getString('advertisements') ?? '[]';
      final adsList = json.decode(adsJson) as List;
      _advertisements = adsList.map((json) => Advertisement.fromJson(json)).toList();

      print('Загружены рекламные объявления: ${_advertisements.length}');
    } catch (e) {
      print('Ошибка загрузки рекламных объявлений: $e');
    }
  }

  // Загрузка разрешений менеджеров
  Future<void> _loadManagerPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permissionsJson = prefs.getString('manager_permissions') ?? '[]';
      final permissionsList = json.decode(permissionsJson) as List;
      _managerPermissions = permissionsList.map((json) => ManagerPermissions.fromJson(json)).toList();

      print('Загружены разрешения менеджеров: ${_managerPermissions.length}');
    } catch (e) {
      print('Ошибка загрузки разрешений менеджеров: $e');
    }
  }

  // Сохранение городов
  Future<void> _saveCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('advertisement_cities', json.encode(_cities.map((e) => e.toJson()).toList()));
      print('Города сохранены');
    } catch (e) {
      print('Ошибка сохранения городов: $e');
    }
  }

  // Сохранение рекламных объявлений
  Future<void> _saveAdvertisements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('advertisements', json.encode(_advertisements.map((e) => e.toJson()).toList()));
      print('Рекламные объявления сохранены');
    } catch (e) {
      print('Ошибка сохранения рекламных объявлений: $e');
    }
  }

  // Сохранение разрешений менеджеров
  Future<void> _saveManagerPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('manager_permissions', json.encode(_managerPermissions.map((e) => e.toJson()).toList()));
      print('Разрешения менеджеров сохранены');
    } catch (e) {
      print('Ошибка сохранения разрешений менеджеров: $e');
    }
  }

  // Добавление рекламного объявления
  Future<bool> addAdvertisement({
    required String title,
    required String imageUrl,
    required String linkUrl,
    required String cityId,
    required String managerId,
    required String managerName,
  }) async {
    try {
      final city = _cities.firstWhere((c) => c.id == cityId);
      
      final advertisement = Advertisement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        imageUrl: imageUrl,
        linkUrl: linkUrl,
        cityId: cityId,
        cityName: city.name,
        managerId: managerId,
        managerName: managerName,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      _advertisements.add(advertisement);
      await _saveAdvertisements();
      notifyListeners();
      return true;
    } catch (e) {
      print('Ошибка добавления рекламного объявления: $e');
      return false;
    }
  }

  // Одобрение рекламного объявления
  Future<void> approveAdvertisement(String adId) async {
    try {
      final adIndex = _advertisements.indexWhere((ad) => ad.id == adId);
      if (adIndex != -1) {
        _advertisements[adIndex] = _advertisements[adIndex].copyWith(
          status: 'approved',
          approvedAt: DateTime.now(),
        );
        await _saveAdvertisements();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка одобрения рекламного объявления: $e');
    }
  }

  // Отклонение рекламного объявления
  Future<void> rejectAdvertisement(String adId, String reason) async {
    try {
      final adIndex = _advertisements.indexWhere((ad) => ad.id == adId);
      if (adIndex != -1) {
        _advertisements[adIndex] = _advertisements[adIndex].copyWith(
          status: 'rejected',
          rejectionReason: reason,
        );
        await _saveAdvertisements();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка отклонения рекламного объявления: $e');
    }
  }

  // Блокировка рекламного объявления
  Future<void> blockAdvertisement(String adId) async {
    try {
      final adIndex = _advertisements.indexWhere((ad) => ad.id == adId);
      if (adIndex != -1) {
        _advertisements[adIndex] = _advertisements[adIndex].copyWith(
          status: 'blocked',
        );
        await _saveAdvertisements();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка блокировки рекламного объявления: $e');
    }
  }

  // Удаление рекламного объявления
  Future<void> deleteAdvertisement(String adId) async {
    try {
      _advertisements.removeWhere((ad) => ad.id == adId);
      await _saveAdvertisements();
      notifyListeners();
    } catch (e) {
      print('Ошибка удаления рекламного объявления: $e');
    }
  }

  // Увеличение просмотров
  Future<void> incrementViews(String adId) async {
    try {
      final adIndex = _advertisements.indexWhere((ad) => ad.id == adId);
      if (adIndex != -1) {
        _advertisements[adIndex] = _advertisements[adIndex].copyWith(
          views: _advertisements[adIndex].views + 1,
        );
        await _saveAdvertisements();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка увеличения просмотров: $e');
    }
  }

  // Увеличение кликов
  Future<void> incrementClicks(String adId) async {
    try {
      final adIndex = _advertisements.indexWhere((ad) => ad.id == adId);
      if (adIndex != -1) {
        _advertisements[adIndex] = _advertisements[adIndex].copyWith(
          clicks: _advertisements[adIndex].clicks + 1,
        );
        await _saveAdvertisements();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка увеличения кликов: $e');
    }
  }

  // Установка разрешений менеджеру
  Future<void> setManagerPermissions({
    required String managerId,
    required List<String> allowedCities,
    bool canAddAds = true,
    bool canEditAds = true,
    bool canDeleteAds = false,
  }) async {
    try {
      // Удаляем существующие разрешения
      _managerPermissions.removeWhere((perm) => perm.managerId == managerId);
      
      // Добавляем новые разрешения
      final permissions = ManagerPermissions(
        managerId: managerId,
        allowedCities: allowedCities,
        canAddAds: canAddAds,
        canEditAds: canEditAds,
        canDeleteAds: canDeleteAds,
        createdAt: DateTime.now(),
      );
      
      _managerPermissions.add(permissions);
      await _saveManagerPermissions();
      notifyListeners();
    } catch (e) {
      print('Ошибка установки разрешений менеджеру: $e');
    }
  }

  // Добавление города
  Future<void> addCity({
    required String name,
    required String country,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final city = City(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        country: country,
        latitude: latitude,
        longitude: longitude,
      );
      
      _cities.add(city);
      await _saveCities();
      notifyListeners();
    } catch (e) {
      print('Ошибка добавления города: $e');
    }
  }

  // Получение статистики рекламы
  Map<String, dynamic> getAdvertisementStats() {
    final totalAds = _advertisements.length;
    final pendingAds = _advertisements.where((ad) => ad.status == 'pending').length;
    final approvedAds = _advertisements.where((ad) => ad.status == 'approved').length;
    final rejectedAds = _advertisements.where((ad) => ad.status == 'rejected').length;
    final blockedAds = _advertisements.where((ad) => ad.status == 'blocked').length;
    final totalViews = _advertisements.fold(0, (sum, ad) => sum + ad.views);
    final totalClicks = _advertisements.fold(0, (sum, ad) => sum + ad.clicks);

    return {
      'totalAds': totalAds,
      'pendingAds': pendingAds,
      'approvedAds': approvedAds,
      'rejectedAds': rejectedAds,
      'blockedAds': blockedAds,
      'totalViews': totalViews,
      'totalClicks': totalClicks,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
