# Настройка Gmail для отправки кодов подтверждения

## 🚀 Быстрая настройка Gmail

### Шаг 1: Подготовка Gmail аккаунта

1. **Войдите в Gmail** и перейдите в настройки
2. **Включите двухфакторную аутентификацию:**
   - Перейдите в [myaccount.google.com](https://myaccount.google.com)
   - Выберите "Безопасность"
   - Включите "Двухэтапная аутентификация"

### Шаг 2: Создание пароля приложения

1. **Перейдите в настройки Google:**
   - [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
   - Или: Настройки → Безопасность → Пароли приложений

2. **Создайте пароль приложения:**
   - Выберите "Почта" или "Другое (указать название)"
   - Введите название: "Anal GIS"
   - Скопируйте сгенерированный пароль (16 символов)

### Шаг 3: Настройка в приложении

1. **Откройте файл:** `lib/services/email_service_simple.dart`

2. **Замените настройки:**
```dart
static const String _smtpUsername = 'your-email@gmail.com'; // Ваш Gmail
static const String _smtpPassword = 'your-app-password';    // Пароль приложения
```

**Пример:**
```dart
static const String _smtpUsername = 'mymail@gmail.com';
static const String _smtpPassword = 'abcd efgh ijkl mnop';
```

### Шаг 4: Тестирование

1. **Запустите приложение**
2. **Перейдите в регистрацию**
3. **Введите ваш email**
4. **Проверьте почту** (включая папку "Спам")

## 🔧 Альтернативные настройки

### Yandex Mail
```dart
static const String _smtpHost = 'smtp.yandex.ru';
static const int _smtpPort = 587;
static const String _smtpUsername = 'your-email@yandex.ru';
static const String _smtpPassword = 'your-password';
```

### Mail.ru
```dart
static const String _smtpHost = 'smtp.mail.ru';
static const int _smtpPort = 587;
static const String _smtpUsername = 'your-email@mail.ru';
static const String _smtpPassword = 'your-password';
```

### Outlook/Hotmail
```dart
static const String _smtpHost = 'smtp-mail.outlook.com';
static const int _smtpPort = 587;
static const String _smtpUsername = 'your-email@outlook.com';
static const String _smtpPassword = 'your-password';
```

## 🛡️ Безопасность

### ⚠️ Важно:
- **НЕ коммитьте** реальные пароли в Git
- Используйте **пароль приложения**, а не основной пароль
- **Не делитесь** паролем приложения

### 🔒 Для продакшена:
1. Используйте переменные окружения
2. Настройте отдельный email для приложения
3. Используйте сервисы типа SendGrid, Mailgun

## 🧪 Проверка работы

### В консоли должно появиться:
```
✅ Код отправлен на your-email@gmail.com: 123456
```

### Если не работает:
```
⚠️ Gmail не настроен. Используйте демо режим.
⚠️ Демо режим. Код для your-email@gmail.com: 123456
```

## 🆘 Решение проблем

### "Не удается войти в аккаунт"
- Проверьте правильность email и пароля приложения
- Убедитесь, что включена двухфакторная аутентификация

### "Письмо не приходит"
- Проверьте папку "Спам"
- Убедитесь, что email корректный
- Проверьте логи в консоли

### "Ошибка SMTP"
- Проверьте настройки хоста и порта
- Убедитесь, что используете пароль приложения

## 📱 Поддержка платформ

- ✅ **Web** - Полная поддержка
- ✅ **Android** - Полная поддержка  
- ✅ **iOS** - Полная поддержка

## 📞 Поддержка

Если возникли проблемы:
1. Проверьте логи в консоли (F12 в браузере)
2. Убедитесь, что настройки корректные
3. Попробуйте другой email провайдер
