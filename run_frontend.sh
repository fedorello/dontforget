#!/bin/bash
set -e

echo "=== DontForget Frontend (Flutter Web) ==="
echo "Port: 9191"
echo ""

cd "$(dirname "$0")/frontend"

FLUTTER=/opt/homebrew/bin/flutter

echo "Getting packages..."
$FLUTTER pub get

echo ""
echo "Starting Flutter Web on http://localhost:9191"
echo ""

$FLUTTER run -d chrome \
  --web-port 9191 \
  --dart-define=API_BASE_URL=http://localhost:8787 \
  --web-browser-flag="--disable-web-security"
