import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/email_service_simple.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Временное хранение данных регистрации
  Map<String, String> _pendingRegistration = {};
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Включаем Google Sign-In для веб-версии с Client ID
    clientId: kIsWeb ? '230044526443-o5c8ns3lpd1a36phjc6acto5klr05g0u.apps.googleusercontent.com' : null,
    scopes: ['email', 'profile'],
  );
  final EmailServiceSimple _emailService = EmailServiceSimple();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Принудительно загружает пользователя из хранилища
  Future<void> loadUserSession() async {
    await _loadUserFromStorage();
  }

  AuthProvider() {
    _loadUserFromStorage();
  }

  /// Загружает пользователя из локального хранилища
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        final user = User.fromJson(userMap);
        
        // Проверяем, что email верифицирован
        if (user.isEmailVerified) {
          _currentUser = user;
          print('Пользователь загружен из хранилища: ${user.fullName}');
        } else {
          // Если email не верифицирован, очищаем данные
          print('Email не верифицирован, очищаем данные');
          await prefs.remove('current_user');
          _currentUser = null;
        }
        notifyListeners();
      } else {
        print('Нет сохраненного пользователя');
      }
    } catch (e) {
      print('Ошибка загрузки пользователя: $e');
      // При ошибке очищаем данные
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('current_user');
      } catch (clearError) {
        print('Ошибка очистки данных: $clearError');
      }
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Сохраняет пользователя в локальное хранилище
  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', json.encode(user.toJson()));
      
      // Также сохраняем в список всех пользователей
      await _addUserToAllUsers(user);
      
      print('Пользователь сохранен в хранилище: ${user.fullName}');
    } catch (e) {
      print('Ошибка сохранения пользователя: $e');
    }
  }

  /// Добавление пользователя в список всех пользователей
  Future<void> _addUserToAllUsers(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allUsersJson = prefs.getString('all_users') ?? '[]';
      final allUsersList = json.decode(allUsersJson) as List;
      
      // Проверяем, есть ли уже такой пользователь
      final existingUserIndex = allUsersList.indexWhere((u) => u['email'] == user.email);
      
      if (existingUserIndex != -1) {
        // Обновляем существующего пользователя
        allUsersList[existingUserIndex] = user.toJson();
      } else {
        // Добавляем нового пользователя
        allUsersList.add(user.toJson());
      }
      
      await prefs.setString('all_users', json.encode(allUsersList));
      print('Пользователь добавлен в общий список: ${user.email}');
      print('Данные пользователя: firstName=${user.firstName}, lastName=${user.lastName}, fullName=${user.fullName}');
    } catch (e) {
      print('Ошибка добавления пользователя в общий список: $e');
    }
  }

  /// Очищает локальное хранилище
  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      print('Данные пользователя очищены из хранилища');
    } catch (e) {
      print('Ошибка очистки хранилища: $e');
    }
  }

  /// Устанавливает ошибку
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Очищает ошибку
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Устанавливает состояние загрузки
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Регистрация через Google
  Future<bool> signUpWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setError('Регистрация отменена');
        _setLoading(false);
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Создаем пользователя из данных Google
      final user = User(
        id: googleUser.id,
        firstName: googleUser.displayName?.split(' ').first ?? '',
        lastName: (googleUser.displayName?.split(' ').length ?? 0) > 1 
            ? googleUser.displayName!.split(' ').sublist(1).join(' ') 
            : '',
        email: googleUser.email,
        phone: '', // Google не предоставляет телефон
        profileImageUrl: googleUser.photoUrl,
        createdAt: DateTime.now(),
        isEmailVerified: true, // Google аккаунты уже верифицированы
      );

      _currentUser = user;
      await _saveUserToStorage(user);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Ошибка регистрации через Google: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Регистрация с email и паролем
  Future<bool> signUpWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Отправляем код подтверждения
      final success = await _emailService.sendVerificationCode(email);
      if (!success) {
        _setError('Ошибка отправки кода подтверждения');
        _setLoading(false);
        return false;
      }

      // Сохраняем данные регистрации для использования после верификации
      _pendingRegistration[email] = json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      });

      // Создаем временного пользователя (будет подтвержден после ввода кода)
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        isEmailVerified: false,
      );

      _currentUser = user;
      await _saveUserToStorage(user);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Ошибка регистрации: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Подтверждение email кода
  Future<bool> verifyEmailCode(String code) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentUser == null) {
        _setError('Пользователь не найден');
        _setLoading(false);
        return false;
      }

      final isValid = _emailService.verifyCode(_currentUser!.email, code);
      if (!isValid) {
        _setError('Неверный код подтверждения');
        _setLoading(false);
        return false;
      }

      // Обновляем пользователя как верифицированного
      _currentUser = _currentUser!.copyWith(isEmailVerified: true);
      await _saveUserToStorage(_currentUser!);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Ошибка подтверждения: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Вход в аккаунт
  Future<bool> signInWithEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      // Отправляем код подтверждения
      final success = await _emailService.sendVerificationCode(email);
      if (!success) {
        _setError('Ошибка отправки кода подтверждения');
        _setLoading(false);
        return false;
      }

      // НЕ создаем пользователя до подтверждения кода
      // Пользователь будет создан только после успешной верификации
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Ошибка входа: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Подтверждение входа по коду
  Future<bool> signInWithCode(String email, String code) async {
    try {
      _setLoading(true);
      _clearError();

      final isValid = _emailService.verifyCode(email, code);
      if (!isValid) {
        _setError('Неверный код подтверждения');
        _setLoading(false);
        return false;
      }

      // Создаем пользователя после успешной верификации
      // Используем сохраненные данные регистрации или данные существующего пользователя
      String firstName = 'Пользователь';
      String lastName = '';
      String phone = '';
      
      // Проверяем, есть ли сохраненные данные регистрации
      if (_pendingRegistration.containsKey(email)) {
        final registrationJson = _pendingRegistration[email];
        if (registrationJson != null) {
          final registrationData = json.decode(registrationJson);
          firstName = registrationData['firstName'] ?? 'Пользователь';
          lastName = registrationData['lastName'] ?? '';
          phone = registrationData['phone'] ?? '';
          _pendingRegistration.remove(email); // Удаляем после использования
        }
      } else if (_currentUser != null) {
        // Используем данные существующего пользователя
        firstName = _currentUser!.firstName;
        lastName = _currentUser!.lastName;
        phone = _currentUser!.phone;
      }
      
      final user = User(
        id: email,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        isEmailVerified: true,
      );

      _currentUser = user;
      await _saveUserToStorage(user);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Ошибка входа: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Повторная отправка кода
  Future<bool> resendCode(String email) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _emailService.sendVerificationCode(email);
      if (!success) {
        _setError('Ошибка отправки кода подтверждения');
        _setLoading(false);
        return false;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Ошибка отправки кода: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Выход из аккаунта
  Future<void> signOut() async {
    try {
      _setLoading(true);
      
      // Выходим из Google аккаунта
      await _googleSignIn.signOut();
      
      // Очищаем данные пользователя
      _currentUser = null;
      _pendingRegistration.clear(); // Очищаем временные данные регистрации
      await _clearUserFromStorage();
      
      _setLoading(false);
      notifyListeners();
      print('Пользователь вышел из аккаунта');
    } catch (e) {
      _setError('Ошибка выхода: $e');
      _setLoading(false);
      notifyListeners();
    }
  }


  /// Получает оставшееся время действия кода
  int getRemainingCodeTime(String email) {
    return _emailService.getRemainingTime(email);
  }

  // Проверка, является ли пользователь администратором
  bool get isAdmin {
    return _currentUser?.email == 'admin@gmail.com';
  }

  // Проверка, является ли пользователь менеджером
  bool get isManager {
    return _currentUser?.email == 'manager@gmail.com' || _currentUser?.email == 'maneger@gmail.com';
  }

  // Получение роли пользователя
  String get userRole {
    if (isAdmin) return 'admin';
    if (isManager) return 'manager';
    return 'user';
  }
}
