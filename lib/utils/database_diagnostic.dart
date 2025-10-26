import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DatabaseDiagnostic {
  static Future<void> printAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      print('🔍 ДИАГНОСТИКА БАЗЫ ДАННЫХ:');
      print('================================');
      
      for (final key in keys) {
        final value = prefs.getString(key);
        if (value != null) {
          try {
            final jsonData = json.decode(value);
            if (jsonData is List) {
              print('📁 $key: ${jsonData.length} элементов');
              if (jsonData.isNotEmpty) {
                print('   Первый элемент: ${jsonData.first}');
              }
            } else {
              print('📄 $key: $jsonData');
            }
          } catch (e) {
            // Если не JSON, выводим как обычную строку
            print('📄 $key: $value (не JSON)');
          }
        }
      }
      
      print('================================');
      
      // Проверяем конкретно наши ключи
      final unifiedUsers = prefs.getString('unified_users') ?? '[]';
      final unifiedAds = prefs.getString('unified_advertisements') ?? '[]';
      final oldUsers = prefs.getString('users') ?? '[]';
      final oldAds = prefs.getString('advertisements') ?? '[]';
      
      print('🔍 СПЕЦИФИЧЕСКИЕ ПРОВЕРКИ:');
      print('unified_users: ${json.decode(unifiedUsers).length} пользователей');
      print('unified_advertisements: ${json.decode(unifiedAds).length} объявлений');
      print('users (старые): ${json.decode(oldUsers).length} пользователей');
      print('advertisements (старые): ${json.decode(oldAds).length} объявлений');
      
    } catch (e) {
      print('❌ Ошибка диагностики: $e');
    }
  }
  
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ Все данные очищены');
    } catch (e) {
      print('❌ Ошибка очистки: $e');
    }
  }
}
