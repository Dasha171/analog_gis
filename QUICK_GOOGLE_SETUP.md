# 🚀 БЫСТРАЯ НАСТРОЙКА GOOGLE SIGN-IN

## ✅ **Что уже готово:**
- ✅ Firebase удален полностью
- ✅ Google Sign-In код реализован
- ✅ Кнопки Google Sign-In добавлены
- ✅ Приложение работает без ошибок

## 🔧 **Что нужно настроить:**

### **1. Google Cloud Console (5 минут)**
1. Перейдите на [Google Cloud Console](https://console.cloud.google.com/)
2. Создайте проект или выберите существующий
3. Включите Google+ API
4. Создайте OAuth 2.0 Client ID:
   - **Web application**
   - **Authorized origins:** `http://localhost:3000`
   - **Authorized redirect URIs:** `http://localhost:3000`

### **2. Обновить код (1 минута)**
1. Откройте `lib/providers/auth_provider.dart`
2. Найдите строку 18:
```dart
clientId: kIsWeb ? '230044526443-o5c8ns3lpd1a36phjc6acto5klr05g0u.apps.googleusercontent.com' : null,
```
3. Замените на ваш Client ID:
```dart
clientId: kIsWeb ? 'ВАШ_CLIENT_ID.apps.googleusercontent.com' : null,
```

### **3. Для Android (опционально)**
1. Создайте Android OAuth Client ID
2. Package name: `com.example.anal_gis`
3. SHA-1 fingerprint: получите командой:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## 🎯 **Результат:**
- ✅ **Быстрая регистрация** через Google (1 клик)
- ✅ **Быстрый вход** через Google (1 клик)
- ✅ **EmailJS работает** (код на почту)
- ✅ **Два способа входа** (Google + Email)
- ✅ **Безопасность** (OAuth 2.0)

## 📱 **Тестирование:**
1. Запустите приложение: `flutter run`
2. Перейдите в регистрацию или вход
3. Нажмите "Войти через Google"
4. Выберите аккаунт Google
5. Проверьте успешный вход

**Google Sign-In готов к использованию!** 🎉
