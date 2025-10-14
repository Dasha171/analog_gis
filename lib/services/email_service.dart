import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  // В реальном приложении здесь был бы API для отправки email
  // Для демонстрации мы будем симулировать отправку и хранить коды в памяти
  final Map<String, String> _verificationCodes = {};
  final Map<String, DateTime> _codeExpiry = {};

  /// Генерирует 6-значный код подтверждения
  String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Отправляет код подтверждения на email
  Future<bool> sendVerificationCode(String email, {BuildContext? context}) async {
    try {
      // Генерируем код
      final code = _generateVerificationCode();
      
      // Сохраняем код с временем истечения (10 минут)
      _verificationCodes[email] = code;
      _codeExpiry[email] = DateTime.now().add(const Duration(minutes: 10));
      
      // В реальном приложении здесь был бы вызов API для отправки email
      print('Отправлен код подтверждения на $email: $code');
      
      // Для демонстрации показываем код в консоли браузера
      if (kIsWeb) {
        print('🔐 КОД ПОДТВЕРЖДЕНИЯ: $code');
        print('📧 Email: $email');
        print('⏰ Код действителен 10 минут');
      }
      
      // Показываем диалог с кодом для демонстрации
      if (context != null) {
        _showCodeDialog(context, email, code);
      }
      
      // Симулируем задержку отправки
      await Future.delayed(const Duration(seconds: 1));
      
      return true;
    } catch (e) {
      print('Ошибка отправки кода: $e');
      return false;
    }
  }

  /// Показывает диалог с кодом подтверждения (для демонстрации)
  void _showCodeDialog(BuildContext context, String email, String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF212121),
          title: const Text(
            'Код подтверждения',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Для демонстрации показываем код:',
                style: TextStyle(color: Color(0xFF6C6C6C)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C79FE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF0C79FE)),
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                    color: Color(0xFF0C79FE),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Отправлен на: $email',
                style: const TextStyle(
                  color: Color(0xFF6C6C6C),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Понятно',
                style: TextStyle(color: Color(0xFF0C79FE)),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Проверяет код подтверждения
  bool verifyCode(String email, String code) {
    final storedCode = _verificationCodes[email];
    final expiryTime = _codeExpiry[email];
    
    if (storedCode == null || expiryTime == null) {
      return false;
    }
    
    if (DateTime.now().isAfter(expiryTime)) {
      // Код истек
      _verificationCodes.remove(email);
      _codeExpiry.remove(email);
      return false;
    }
    
    if (storedCode == code) {
      // Код верный, удаляем его
      _verificationCodes.remove(email);
      _codeExpiry.remove(email);
      return true;
    }
    
    return false;
  }

  /// Проверяет, есть ли активный код для email
  bool hasActiveCode(String email) {
    final expiryTime = _codeExpiry[email];
    if (expiryTime == null) return false;
    
    if (DateTime.now().isAfter(expiryTime)) {
      _verificationCodes.remove(email);
      _codeExpiry.remove(email);
      return false;
    }
    
    return true;
  }

  /// Получает оставшееся время действия кода в секундах
  int getRemainingTime(String email) {
    final expiryTime = _codeExpiry[email];
    if (expiryTime == null) return 0;
    
    final remaining = expiryTime.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Очищает все коды (для тестирования)
  void clearAllCodes() {
    _verificationCodes.clear();
    _codeExpiry.clear();
  }
}
