#!/bin/bash
set -e

echo "=== DontForget Backend ==="
echo "Port: 8787"
echo ""

cd "$(dirname "$0")/backend"

# Create venv if not exists
if [ ! -d ".venv" ]; then
  echo "Creating virtual environment..."
  python3 -m venv .venv
fi

source .venv/bin/activate

echo "Installing dependencies..."
pip install -q -r requirements.txt

echo ""
echo "Starting FastAPI on http://localhost:8787"
echo "Docs: http://localhost:8787/docs"
echo ""

uvicorn app.main:app --host 0.0.0.0 --port 8787 --reload
