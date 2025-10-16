import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  bool _isDarkMode = true; // По умолчанию темная тема
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? true; // По умолчанию темная тема
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
  
  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
  
  // Основные цвета для темной темы
  static const Color darkBackground = Color(0xFF151515);
  static const Color darkSurface = Color(0xFF151515);
  static const Color darkCard = Color(0xFF212121);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFF6C6C6C);
  static const Color darkBorder = Color(0xFF252525);
  
  // Основные цвета для светлой темы
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightCard = Colors.white;
  static const Color lightText = Colors.black;
  static const Color lightTextSecondary = Color(0xFF6C6C6C);
  static const Color lightBorder = Color(0xFFE0E0E0);
  
  // Получение цветов в зависимости от темы
  Color get backgroundColor => _isDarkMode ? darkBackground : lightBackground;
  Color get surfaceColor => _isDarkMode ? darkSurface : lightSurface;
  Color get cardColor => _isDarkMode ? darkCard : lightCard;
  Color get textColor => _isDarkMode ? darkText : lightText;
  Color get textSecondaryColor => _isDarkMode ? darkTextSecondary : lightTextSecondary;
  Color get borderColor => _isDarkMode ? darkBorder : lightBorder;
}
