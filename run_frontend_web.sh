#!/bin/bash
# Alternative: build and serve as static files (no Chrome dev mode)
set -e

echo "=== DontForget Frontend — build & serve ==="

cd "$(dirname "$0")/frontend"
FLUTTER=/opt/homebrew/bin/flutter

$FLUTTER build web \
  --dart-define=API_BASE_URL=http://localhost:8787

echo ""
echo "Built. Serving on http://localhost:9191"
cd build/web && python3 -m http.server 9191
