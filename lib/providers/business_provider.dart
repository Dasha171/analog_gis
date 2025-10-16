import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/business_user_model.dart';
import '../models/organization_model.dart';

class BusinessProvider extends ChangeNotifier {
  BusinessUser? _currentBusinessUser;
  List<Organization> _organizations = [];
  bool _isLoading = false;
  String? _errorMessage;

  BusinessUser? get currentBusinessUser => _currentBusinessUser;
  List<Organization> get organizations => _organizations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentBusinessUser != null;

  BusinessProvider() {
    _loadBusinessUserFromStorage();
  }

  Future<void> _loadBusinessUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('business_user');
      
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _currentBusinessUser = BusinessUser.fromJson(userMap);
        await _loadOrganizations();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка загрузки бизнес-пользователя: $e');
    }
  }

  Future<void> _saveBusinessUserToStorage() async {
    if (_currentBusinessUser == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('business_user', json.encode(_currentBusinessUser!.toJson()));
    } catch (e) {
      print('Ошибка сохранения бизнес-пользователя: $e');
    }
  }

  Future<void> _loadOrganizations() async {
    if (_currentBusinessUser == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final organizationsJson = prefs.getStringList('organizations_${_currentBusinessUser!.id}') ?? [];
      
      _organizations = organizationsJson
          .map((json) => Organization.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Ошибка загрузки организаций: $e');
    }
  }

  Future<void> _saveOrganizations() async {
    if (_currentBusinessUser == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final organizationsJson = _organizations
          .map((org) => jsonEncode(org.toJson()))
          .toList();
      
      await prefs.setStringList('organizations_${_currentBusinessUser!.id}', organizationsJson);
    } catch (e) {
      print('Ошибка сохранения организаций: $e');
    }
  }

  Future<bool> registerBusinessUser({
    required String name,
    required String surname,
    required String email,
    required String phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Имитация регистрации
      await Future.delayed(const Duration(seconds: 1));
      
      final businessUser = BusinessUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        surname: surname,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      _currentBusinessUser = businessUser;
      await _saveBusinessUserToStorage();
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка регистрации: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loginBusinessUser({
    required String email,
    required String phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Имитация входа
      await Future.delayed(const Duration(seconds: 1));
      
      // Проверяем, есть ли пользователь в хранилище
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('business_user');
      
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        final user = BusinessUser.fromJson(userMap);
        
        if (user.email == email && user.phone == phone) {
          _currentBusinessUser = user.copyWith(lastLoginAt: DateTime.now());
          await _saveBusinessUserToStorage();
          await _loadOrganizations();
          
          _setLoading(false);
          notifyListeners();
          return true;
        }
      }
      
      _setError('Пользователь не найден');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Ошибка входа: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addOrganization({
    required String name,
    required String address,
    required String phone,
    required String category,
    String? website,
    double? latitude,
    double? longitude,
  }) async {
    if (_currentBusinessUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final organization = Organization(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        businessUserId: _currentBusinessUser!.id,
        name: name,
        address: address,
        phone: phone,
        category: category,
        website: website,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _organizations.add(organization);
      await _saveOrganizations();
      
      // Обновляем количество организаций у пользователя
      _currentBusinessUser = _currentBusinessUser!.copyWith(
        totalOrganizations: _organizations.length,
      );
      await _saveBusinessUserToStorage();
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка добавления организации: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateOrganization(Organization organization) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _organizations.indexWhere((org) => org.id == organization.id);
      if (index != -1) {
        _organizations[index] = organization.copyWith(updatedAt: DateTime.now());
        await _saveOrganizations();
        
        _setLoading(false);
        notifyListeners();
        return true;
      }
      
      _setError('Организация не найдена');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Ошибка обновления организации: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteOrganization(String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      _organizations.removeWhere((org) => org.id == organizationId);
      await _saveOrganizations();
      
      // Обновляем количество организаций у пользователя
      _currentBusinessUser = _currentBusinessUser!.copyWith(
        totalOrganizations: _organizations.length,
      );
      await _saveBusinessUserToStorage();
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка удаления организации: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _currentBusinessUser = null;
    _organizations.clear();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('business_user');
    } catch (e) {
      print('Ошибка выхода: $e');
    }
    
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
