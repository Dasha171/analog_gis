import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider extends ChangeNotifier {
  Locale _locale = const Locale('ru', 'RU');
  
  Locale get locale => _locale;
  
  LocalizationProvider() {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'ru';
    final countryCode = prefs.getString('country_code') ?? 'RU';
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }
  
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
    notifyListeners();
  }
  
  void toggleLanguage() {
    if (_locale.languageCode == 'ru') {
      setLocale(const Locale('en', 'US'));
    } else {
      setLocale(const Locale('ru', 'RU'));
    }
  }
}

