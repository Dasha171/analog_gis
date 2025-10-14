# Настройка реальной отправки email

## 🚀 Быстрый старт

Приложение поддерживает несколько способов отправки email. По умолчанию работает демо-режим с показом кода в диалоге.

## 📧 Способы настройки

### 1. EmailJS (Рекомендуется для веб)

**Преимущества:** Простая настройка, бесплатный тариф, работает в браузере

**Настройка:**
1. Зарегистрируйтесь на [EmailJS.com](https://www.emailjs.com/)
2. Создайте сервис (Gmail, Outlook, Yahoo и т.д.)
3. Создайте шаблон email
4. Получите Service ID, Template ID и User ID
5. Обновите настройки в `lib/services/real_email_service.dart`:

```dart
static const String _emailjsServiceId = 'your-service-id';
static const String _emailjsTemplateId = 'your-template-id';
static const String _emailjsUserId = 'your-user-id';
```

### 2. SMTP (Gmail, Yandex, Mail.ru)

**Преимущества:** Прямая отправка, полный контроль

**Настройка Gmail:**
1. Включите двухфакторную аутентификацию
2. Создайте пароль приложения в настройках Google
3. Обновите настройки в `lib/services/real_email_service.dart`:

```dart
static const String _smtpUsername = 'your-email@gmail.com';
static const String _smtpPassword = 'your-app-password';
```

**Настройка Yandex:**
```dart
static const String _smtpHost = 'smtp.yandex.ru';
static const int _smtpPort = 587;
static const String _smtpUsername = 'your-email@yandex.ru';
static const String _smtpPassword = 'your-password';
```

### 3. Formspree (Резервный вариант)

**Преимущества:** Не требует настройки SMTP, простой API

**Настройка:**
1. Зарегистрируйтесь на [Formspree.io](https://formspree.io/)
2. Создайте форму
3. Получите Form ID
4. Обновите настройки в `lib/services/real_email_service.dart`:

```dart
const url = 'https://formspree.io/f/your-form-id';
```

## 🔧 Настройка шаблона EmailJS

Создайте шаблон с переменными:
- `{{to_email}}` - email получателя
- `{{verification_code}}` - код подтверждения
- `{{subject}}` - тема письма
- `{{message}}` - текст сообщения

Пример шаблона:
```
Тема: {{subject}}

Здравствуйте!

Ваш код подтверждения: {{verification_code}}

Код действителен 10 минут.

С уважением,
Команда Anal GIS
```

## 🛡️ Безопасность

1. **Никогда не коммитьте** реальные пароли и ключи в Git
2. Используйте переменные окружения для конфиденциальных данных
3. Для продакшена настройте отдельные email сервисы

## 🧪 Тестирование

1. Запустите приложение
2. Перейдите в регистрацию/вход
3. Введите email
4. Проверьте:
   - Консоль браузера (F12) для логов
   - Папку "Спам" в почте
   - Диалог с кодом (если email не настроен)

## 📱 Поддержка платформ

- ✅ **Web** - EmailJS, SMTP, Formspree
- ✅ **Android** - SMTP, Formspree
- ✅ **iOS** - SMTP, Formspree

## 🆘 Решение проблем

**Код не приходит:**
1. Проверьте настройки SMTP/EmailJS
2. Проверьте папку "Спам"
3. Убедитесь, что email корректный
4. Проверьте логи в консоли

**Ошибки SMTP:**
1. Проверьте логин/пароль
2. Включите "Менее безопасные приложения" (Gmail)
3. Используйте пароль приложения вместо обычного пароля

**Ошибки EmailJS:**
1. Проверьте Service ID, Template ID, User ID
2. Убедитесь, что шаблон опубликован
3. Проверьте лимиты бесплатного тарифа

## 📞 Поддержка

Если возникли проблемы с настройкой, проверьте:
1. Документацию EmailJS: https://www.emailjs.com/docs/
2. Документацию mailer: https://pub.dev/packages/mailer
3. Логи в консоли браузера (F12)
