import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/organization_model.dart';
import '../models/advertisement_model.dart';
import '../services/database_service.dart';

class OrganizationProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Organization> _organizations = [];
  List<Advertisement> _advertisements = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Organization> get organizations => _organizations;
  List<Advertisement> get advertisements => _advertisements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Загрузка всех организаций
  Future<void> loadOrganizations() async {
    try {
      _setLoading(true);
      _setError(null);
      
      _organizations = await _databaseService.getAllOrganizations();
      print('✅ Загружено организаций: ${_organizations.length}');
      
      _setLoading(false);
    } catch (e) {
      _setError('Ошибка загрузки организаций: $e');
      _setLoading(false);
    }
  }

  // Поиск организаций
  Future<List<Organization>> searchOrganizations(String query) async {
    try {
      if (query.trim().isEmpty) {
        return _organizations;
      }
      
      return await _databaseService.searchOrganizations(query);
    } catch (e) {
      print('Ошибка поиска организаций: $e');
      return [];
    }
  }

  // Поиск организаций поблизости
  Future<List<Organization>> getOrganizationsNearby(double latitude, double longitude, double radiusKm) async {
    try {
      return await _databaseService.getOrganizationsNearby(latitude, longitude, radiusKm);
    } catch (e) {
      print('Ошибка поиска поблизости: $e');
      return [];
    }
  }

  // Получение организаций по категории
  Future<List<Organization>> getOrganizationsByCategory(String category) async {
    try {
      return await _databaseService.getOrganizationsByCategory(category);
    } catch (e) {
      print('Ошибка получения по категории: $e');
      return [];
    }
  }

  // Добавление организации
  Future<bool> addOrganization(Organization organization) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _databaseService.insertOrganization(organization);
      _organizations.add(organization);
      
      print('✅ Организация добавлена: ${organization.name}');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Ошибка добавления организации: $e');
      _setLoading(false);
      return false;
    }
  }

  // Обновление организации
  Future<bool> updateOrganization(Organization organization) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _databaseService.updateOrganization(organization);
      
      final index = _organizations.indexWhere((org) => org.id == organization.id);
      if (index != -1) {
        _organizations[index] = organization;
      }
      
      print('✅ Организация обновлена: ${organization.name}');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Ошибка обновления организации: $e');
      _setLoading(false);
      return false;
    }
  }

  // Удаление организации
  Future<bool> deleteOrganization(String organizationId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _databaseService.deleteOrganization(organizationId);
      _organizations.removeWhere((org) => org.id == organizationId);
      
      print('✅ Организация удалена: $organizationId');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Ошибка удаления организации: $e');
      _setLoading(false);
      return false;
    }
  }

  // Загрузка рекламы
  Future<void> loadAdvertisements() async {
    try {
      _setLoading(true);
      _setError(null);
      
      _advertisements = await _databaseService.getActiveAdvertisements();
      print('✅ Загружено рекламы: ${_advertisements.length}');
      
      _setLoading(false);
    } catch (e) {
      _setError('Ошибка загрузки рекламы: $e');
      _setLoading(false);
    }
  }

  // Добавление рекламы
  Future<bool> addAdvertisement(Advertisement advertisement) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _databaseService.insertAdvertisement(advertisement);
      _advertisements.add(advertisement);
      
      print('✅ Реклама добавлена: ${advertisement.title}');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Ошибка добавления рекламы: $e');
      _setLoading(false);
      return false;
    }
  }

  // Обновление рекламы
  Future<bool> updateAdvertisement(Advertisement advertisement) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _databaseService.updateAdvertisement(advertisement);
      
      final index = _advertisements.indexWhere((adv) => adv.id == advertisement.id);
      if (index != -1) {
        _advertisements[index] = advertisement;
      }
      
      print('✅ Реклама обновлена: ${advertisement.title}');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Ошибка обновления рекламы: $e');
      _setLoading(false);
      return false;
    }
  }

  // Увеличение просмотров рекламы
  Future<void> incrementAdvertisementViews(String advertisementId) async {
    try {
      await _databaseService.incrementAdvertisementViews(advertisementId);
      
      final index = _advertisements.indexWhere((adv) => adv.id == advertisementId);
      if (index != -1) {
        _advertisements[index] = _advertisements[index].copyWith(
          viewCount: _advertisements[index].viewCount + 1,
        );
      }
    } catch (e) {
      print('Ошибка увеличения просмотров: $e');
    }
  }

  // Увеличение кликов рекламы
  Future<void> incrementAdvertisementClicks(String advertisementId) async {
    try {
      await _databaseService.incrementAdvertisementClicks(advertisementId);
      
      final index = _advertisements.indexWhere((adv) => adv.id == advertisementId);
      if (index != -1) {
        _advertisements[index] = _advertisements[index].copyWith(
          clickCount: _advertisements[index].clickCount + 1,
        );
      }
    } catch (e) {
      print('Ошибка увеличения кликов: $e');
    }
  }

  // Получение организации по ID
  Organization? getOrganizationById(String id) {
    try {
      return _organizations.firstWhere((org) => org.id == id);
    } catch (e) {
      return null;
    }
  }

  // Получение рекламы по ID
  Advertisement? getAdvertisementById(String id) {
    try {
      return _advertisements.firstWhere((adv) => adv.id == id);
    } catch (e) {
      return null;
    }
  }

  // Получение категорий организаций
  List<String> getCategories() {
    final categories = _organizations.map((org) => org.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Получение топ организаций по рейтингу
  List<Organization> getTopOrganizations({int limit = 10}) {
    final sorted = List<Organization>.from(_organizations);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  // Получение новых организаций
  List<Organization> getNewOrganizations({int limit = 10}) {
    final sorted = List<Organization>.from(_organizations);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }
}
