#!/bin/bash

# Install Flutter
if [ ! -d "$HOME/flutter" ]; then
  echo "Installing Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
fi

# Add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"

# Enable web support
flutter config --enable-web

# Get dependencies
flutter pub get

# Build web
flutter build web --release --no-tree-shake-icons

