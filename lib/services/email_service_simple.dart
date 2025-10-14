import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailServiceSimple {
  static final EmailServiceSimple _instance = EmailServiceSimple._internal();
  factory EmailServiceSimple() => _instance;
  EmailServiceSimple._internal();

  // Настройки EmailJS (рекомендуется - не нужна отдельная почта)
  static const String _emailjsServiceId = 'service_6wa35ji'; // ⚠️ ЗАМЕНИТЕ НА ВАШ SERVICE ID
  static const String _emailjsTemplateId = 'template_7va537s'; // ⚠️ ЗАМЕНИТЕ НА ВАШ TEMPLATE ID
  static const String _emailjsUserId = 'Wwt7VHuG-ggU53oEX'; // ⚠️ ЗАМЕНИТЕ НА ВАШ USER ID
  
  // Настройки Gmail SMTP (альтернатива)
  static const String _smtpHost = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const String _smtpUsername = 'daralazareva171@gmail.com'; // ⚠️ ЗАМЕНИТЕ НА ПАРОЛЬ ПРИЛОЖЕНИЯ
  static const String _smtpPassword = 'your-app-password'; // ⚠️ ЗАМЕНИТЕ НА ПАРОЛЬ ПРИЛОЖЕНИЯ (16 символов)
  
  /*
  🔧 ИНСТРУКЦИЯ ПО НАСТРОЙКЕ EMAILJS (РЕКОМЕНДУЕТСЯ):
  
  1. Зарегистрируйтесь на https://www.emailjs.com/
  2. Создайте сервис (Gmail, Outlook, Yahoo и т.д.)
  3. Создайте шаблон email
  4. Получите Service ID, Template ID и User ID
  5. Замените значения выше
  
  Пример:
  static const String _emailjsServiceId = 'service_abc123';
  static const String _emailjsTemplateId = 'template_xyz789';
  static const String _emailjsUserId = 'user_def456';
  
  🔧 АЛЬТЕРНАТИВА - GMAIL SMTP:
  
  1. Создайте Gmail аккаунт для приложения
  2. Включите двухфакторную аутентификацию в настройках Google
  3. Создайте пароль приложения: https://myaccount.google.com/apppasswords
  4. Замените 'your-email@gmail.com' на ваш Gmail
  5. Замените 'your-app-password' на пароль приложения (16 символов)
  
  Пример:
  static const String _smtpUsername = 'mymail@gmail.com';
  static const String _smtpPassword = 'abcd efgh ijkl mnop';
  */

  /// Генерирует 6-значный код подтверждения
  String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Отправляет код подтверждения на email
  Future<bool> sendVerificationCode(String email) async {
    try {
      final code = _generateVerificationCode();
      
      // Пробуем разные способы отправки
      bool success = false;
      
      // Способ 1: Через EmailJS (рекомендуется - не нужна отдельная почта)
      if (kIsWeb) {
        print('🌐 Веб-среда обнаружена, пробуем EmailJS...');
        success = await _sendViaEmailJS(email, code);
        print('📧 Результат EmailJS: $success');
      } else {
        print('📱 Мобильная среда, EmailJS недоступен');
      }
      
      // Способ 2: Через SMTP (если EmailJS не сработал или мобильная среда)
      if (!success) {
        print('📧 Пробуем Gmail SMTP...');
        success = await _sendViaGmail(email, code);
        print('📧 Результат Gmail SMTP: $success');
      }
      
      if (success) {
        // Сохраняем код для проверки
        _saveCodeForVerification(email, code);
        print('✅ Код отправлен на $email: $code');
        return true;
      } else {
        // Если не удалось отправить, сохраняем код для демо
        _saveCodeForVerification(email, code);
        print('⚠️ Демо режим. Код для $email: $code');
        return true;
      }
    } catch (e) {
      print('❌ Ошибка отправки email: $e');
      return false;
    }
  }

  /// Отправка через EmailJS
  Future<bool> _sendViaEmailJS(String email, String code) async {
    try {
      // Проверяем, настроены ли учетные данные
      if (_emailjsServiceId == 'service_analgis' || 
          _emailjsTemplateId == 'template_verification' || 
          _emailjsUserId == 'user_analgis') {
        print('⚠️ EmailJS не настроен. Замените ID в коде на реальные из EmailJS.');
        return false;
      }
      
      print('🔧 Отправка через EmailJS на $email с кодом $code');

              const url = 'https://api.emailjs.com/api/v1.0/email/send';
              
              final requestBody = {
                'service_id': _emailjsServiceId,
                'template_id': _emailjsTemplateId,
                'user_id': _emailjsUserId,
                'template_params': {
                  'to_email': email,
                  'passcode': code,
                  'subject': 'Anal GIS - Код подтверждения',
                  'message': 'Ваш код: $code',
                  'from_name': 'Anal GIS',
                  'reply_to': 'daralazareva171@gmail.com',
                }
              };
      
      print('📤 Отправляем запрос к EmailJS:');
      print('   Service ID: $_emailjsServiceId');
      print('   Template ID: $_emailjsTemplateId');
      print('   User ID: $_emailjsUserId');
      print('   Email: $email');
      print('   Code: $code');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('📥 Ответ от EmailJS:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Ошибка EmailJS: $e');
      return false;
    }
  }

  /// Отправка через Gmail SMTP
  Future<bool> _sendViaGmail(String email, String code) async {
    try {
      // Проверяем, настроены ли учетные данные
      if (_smtpUsername == 'your-email@gmail.com' || _smtpPassword == 'your-app-password') {
        print('⚠️ Gmail не настроен. Используйте демо режим.');
        return false;
      }

      // Создаем SMTP сервер
      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _smtpUsername,
        password: _smtpPassword,
        allowInsecure: false,
        ssl: false,
      );

      // Создаем сообщение
      final message = Message()
        ..from = Address(_smtpUsername, 'Anal GIS')
        ..recipients.add(email)
        ..subject = 'Код подтверждения - Anal GIS'
        ..html = _buildEmailTemplate(code);

      // Отправляем
      final sendReport = await send(message, smtpServer);
      return sendReport != null;
    } catch (e) {
      print('❌ Ошибка Gmail SMTP: $e');
      return false;
    }
  }

  /// HTML шаблон для email
  String _buildEmailTemplate(String code) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Код подтверждения</title>
        <style>
            body { font-family: Arial, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
            .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { text-align: center; margin-bottom: 30px; }
            .logo { color: #0C79FE; font-size: 24px; font-weight: bold; }
            .code-box { background-color: #0C79FE; color: white; padding: 20px; border-radius: 8px; text-align: center; margin: 20px 0; }
            .code { font-size: 32px; font-weight: bold; letter-spacing: 4px; }
            .footer { text-align: center; color: #666; font-size: 12px; margin-top: 30px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <div class="logo">Anal GIS</div>
                <h2>Код подтверждения</h2>
            </div>
            <p>Здравствуйте!</p>
            <p>Для завершения регистрации в приложении Anal GIS введите следующий код подтверждения:</p>
            <div class="code-box">
                <div class="code">$code</div>
            </div>
            <p><strong>Важно:</strong> Код действителен в течение 10 минут. Не передавайте его третьим лицам.</p>
            <p>Если вы не регистрировались в приложении Anal GIS, просто проигнорируйте это письмо.</p>
            <div class="footer">
                <p>© 2024 Anal GIS. Все права защищены.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Сохраняет код для проверки
  void _saveCodeForVerification(String email, String code) {
    _verificationCodes[email] = code;
    _codeExpiry[email] = DateTime.now().add(const Duration(minutes: 10));
  }

  /// Проверяет код подтверждения
  bool verifyCode(String email, String code) {
    final storedCode = _verificationCodes[email];
    final expiryTime = _codeExpiry[email];
    
    if (storedCode == null || expiryTime == null) {
      return false;
    }
    
    if (DateTime.now().isAfter(expiryTime)) {
      _verificationCodes.remove(email);
      _codeExpiry.remove(email);
      return false;
    }
    
    if (storedCode == code) {
      _verificationCodes.remove(email);
      _codeExpiry.remove(email);
      return true;
    }
    
    return false;
  }

  /// Получает оставшееся время действия кода в секундах
  int getRemainingTime(String email) {
    final expiryTime = _codeExpiry[email];
    if (expiryTime == null) return 0;
    
    final remaining = expiryTime.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Повторная отправка кода
  Future<bool> resendCode(String email) async {
    return await sendVerificationCode(email);
  }

  // Временное хранение кодов
  final Map<String, String> _verificationCodes = {};
  final Map<String, DateTime> _codeExpiry = {};
}
