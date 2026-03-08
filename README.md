# DontForget

Smart reminders for medications, shopping and tasks.

## Quick Start

### Backend (Port 8787)
```bash
./run_backend.sh
# API: http://localhost:8787
# Docs: http://localhost:8787/docs
```

### Frontend (Port 9191)
```bash
./run_frontend.sh
# App: http://localhost:9191
```

## Architecture
- **Frontend**: Flutter 3.38 (Web, Android, iOS)
- **Backend**: FastAPI + SQLAlchemy + SQLite (dev) / PostgreSQL (prod)
- **AI**: OpenRouter `x-ai/grok-4.1-fast`
- **Deploy**: Railway.app

## Railway Deploy

### Backend
1. Create new Railway project → `backend/` directory
2. Add PostgreSQL plugin
3. Set env vars from `backend/.env.example`
4. `ALLOWED_ORIGINS` → set your frontend URL

### Frontend (Flutter Web)
1. Build: `flutter build web --dart-define=API_BASE_URL=https://your-backend.railway.app`
2. Deploy `frontend/build/web/` as static site (Railway Static or Vercel/Netlify)

## Ports
| Service | Local port |
|---------|-----------|
| Backend (FastAPI) | **8787** |
| Frontend (Flutter Web) | **9191** |

## Features
- 💊 Medicines & supplements with AI photo recognition
- 👥 Multiple profiles (family/friends)
- ⚕️ Drug compatibility checking
- 🛒 Multiple shopping lists
- ✅ Tasks with priorities and due dates
- 🌍 Russian / English (multilingual)
