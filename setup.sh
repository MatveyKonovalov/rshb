#!/usr/bin/env bash
# Создаёт платформенные папки (android, linux, web и др.) и проверяет проект.
# Запуск из папки проекта: ./setup.sh
set -eu
cd "$(dirname "$0")"

if [ -d linux ] && [ -d android ]; then
  echo "Платформенные папки уже есть, пропускаю создание."
else
  TMP=$(mktemp -d)
  flutter create --project-name agrokorm --org ru.agrokorm "$TMP/agrokorm"
  for d in android ios linux macos web windows; do
    [ -d "$TMP/agrokorm/$d" ] && cp -r "$TMP/agrokorm/$d" .
  done
  rm -rf "$TMP"
fi

flutter pub get
flutter analyze
flutter test
echo
echo "Готово. Запуск приложения: flutter run -d linux"
