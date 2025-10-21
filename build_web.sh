#!/bin/bash

# Установка Flutter
if [ ! -d "$HOME/flutter" ]; then
  echo "Installing Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
fi

# Добавляем Flutter в PATH
export PATH="$HOME/flutter/bin:$PATH"

# Включаем поддержку web
flutter config --enable-web

# Используем упрощенную версию зависимостей для web
cp pubspec_web.yaml pubspec.yaml

# Получаем зависимости
flutter pub get

# Собираем web версию с отключенным WASM
flutter build web --release --no-tree-shake-icons --no-wasm-dry-run --dart-define=FLUTTER_WEB_USE_SKIA=true

echo "Build completed successfully!"
