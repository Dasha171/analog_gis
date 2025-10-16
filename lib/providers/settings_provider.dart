import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // Ключи для SharedPreferences
  static const String _mapTypeKey = 'map_type';
  static const String _trafficEnabledKey = 'traffic_enabled';
  static const String _voiceNavigationKey = 'voice_navigation';
  static const String _languageKey = 'language';
  static const String _regionKey = 'region';
  static const String _cacheSizeKey = 'cache_size';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _locationSharingKey = 'location_sharing';
  static const String _analyticsEnabledKey = 'analytics_enabled';

  // Настройки карты
  String _mapType = 'standard';
  bool _trafficEnabled = false;

  // Настройки навигации
  bool _voiceNavigation = true;

  // Настройки языка
  String _language = 'ru';
  String _region = 'RU';

  // Настройки данных
  int _cacheSize = 0; // в МБ

  // Настройки уведомлений
  bool _notificationsEnabled = true;

  // Настройки конфиденциальности
  bool _locationSharing = true;
  bool _analyticsEnabled = false;

  // Геттеры
  String get mapType => _mapType;
  bool get trafficEnabled => _trafficEnabled;
  bool get voiceNavigation => _voiceNavigation;
  String get language => _language;
  String get region => _region;
  int get cacheSize => _cacheSize;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationSharing => _locationSharing;
  bool get analyticsEnabled => _analyticsEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _mapType = prefs.getString(_mapTypeKey) ?? 'standard';
    _trafficEnabled = prefs.getBool(_trafficEnabledKey) ?? false;
    _voiceNavigation = prefs.getBool(_voiceNavigationKey) ?? true;
    _language = prefs.getString(_languageKey) ?? 'ru';
    _region = prefs.getString(_regionKey) ?? 'RU';
    _cacheSize = prefs.getInt(_cacheSizeKey) ?? 0;
    _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    _locationSharing = prefs.getBool(_locationSharingKey) ?? true;
    _analyticsEnabled = prefs.getBool(_analyticsEnabledKey) ?? false;
    
    notifyListeners();
  }

  // Настройки карты
  Future<void> setMapType(String type) async {
    _mapType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mapTypeKey, type);
    notifyListeners();
  }

  Future<void> setTrafficEnabled(bool enabled) async {
    _trafficEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trafficEnabledKey, enabled);
    notifyListeners();
  }

  // Настройки навигации
  Future<void> setVoiceNavigation(bool enabled) async {
    _voiceNavigation = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_voiceNavigationKey, enabled);
    notifyListeners();
  }

  // Настройки языка
  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang);
    notifyListeners();
  }

  Future<void> setRegion(String reg) async {
    _region = reg;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_regionKey, reg);
    notifyListeners();
  }

  // Настройки данных
  Future<void> clearCache() async {
    _cacheSize = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheSizeKey, 0);
    notifyListeners();
  }

  // Настройки уведомлений
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    notifyListeners();
  }

  // Настройки конфиденциальности
  Future<void> setLocationSharing(bool enabled) async {
    _locationSharing = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationSharingKey, enabled);
    notifyListeners();
  }

  Future<void> setAnalyticsEnabled(bool enabled) async {
    _analyticsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_analyticsEnabledKey, enabled);
    notifyListeners();
  }
}
