# 🔧 Настройка Google OAuth для веб-версии

## 🚨 ПРОБЛЕМА
Google Sign-In не работает в веб-версии из-за отсутствия Client ID.

## ✅ РЕШЕНИЕ

### 1. Создайте Google OAuth проект

1. Перейдите в [Google Cloud Console](https://console.cloud.google.com/)
2. Создайте новый проект или выберите существующий
3. Включите Google+ API

### 2. Создайте OAuth 2.0 Client ID

1. Перейдите в **APIs & Services** → **Credentials**
2. Нажмите **Create Credentials** → **OAuth 2.0 Client ID**
3. Выберите **Web application**
4. Добавьте **Authorized JavaScript origins**:
   - `http://localhost:8136` (для разработки)
   - `https://your-domain.com` (для продакшена)
5. Скопируйте **Client ID**

### 3. Добавьте Client ID в HTML

Откройте `web/index.html` и добавьте:

```html
<!DOCTYPE html>
<html>
<head>
  <!-- ... существующие теги ... -->
  
  <!-- Google OAuth Client ID -->
  <meta name="google-signin-client_id" content="YOUR_CLIENT_ID_HERE">
  
  <!-- Google Sign-In API -->
  <script src="https://apis.google.com/js/platform.js" async defer></script>
  
  <!-- ... остальные теги ... -->
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

### 4. Обновите AuthProvider

В `lib/providers/auth_provider.dart` измените:

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: kIsWeb ? 'YOUR_CLIENT_ID_HERE' : null,
  scopes: ['email', 'profile'],
);
```

### 5. Протестируйте

1. Перезапустите приложение
2. Попробуйте войти через Google
3. Должно открыться окно Google OAuth

## 🔒 БЕЗОПАСНОСТЬ

- **НЕ** коммитьте Client ID в публичный репозиторий
- Используйте переменные окружения для продакшена
- Ограничьте домены в Google Console

## 📱 МОБИЛЬНАЯ ВЕРСИЯ

Для Android/iOS настройка не требуется - Google Sign-In работает автоматически.

## 🚀 БЫСТРОЕ РЕШЕНИЕ

Если не хотите настраивать OAuth сейчас, используйте только **вход по email** - он работает без дополнительной настройки.
