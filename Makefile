FLUTTER := /opt/homebrew/bin/flutter
BACKEND_DIR := backend
FRONTEND_DIR := frontend
BACKEND_PORT := 8787
FRONTEND_PORT := 9191
BACKEND_LOG := /tmp/dontforget_backend.log
FRONTEND_LOG := /tmp/dontforget_frontend.log
BACKEND_PID := /tmp/dontforget_backend.pid
FRONTEND_PID := /tmp/dontforget_frontend.pid

.DEFAULT_GOAL := help

.PHONY: help dev stop setup setup-backend setup-frontend \
        backend frontend logs logs-backend logs-frontend \
        clean clean-db test-api

# ── Help ────────────────────────────────────────────────────────────────────
help:
	@echo ""
	@echo "  DontForget — команды"
	@echo ""
	@echo "  make dev            Запустить всё (backend + frontend)"
	@echo "  make stop           Остановить всё"
	@echo "  make setup          Установить все зависимости"
	@echo ""
	@echo "  make backend        Запустить только backend (port $(BACKEND_PORT))"
	@echo "  make frontend       Запустить только frontend (port $(FRONTEND_PORT))"
	@echo ""
	@echo "  make logs           Показать логи обоих сервисов"
	@echo "  make logs-backend   Показать логи backend"
	@echo "  make logs-frontend  Показать логи frontend"
	@echo ""
	@echo "  make test-api       Тест API endpoints"
	@echo "  make clean-db       Удалить локальную БД (SQLite)"
	@echo "  make clean          Полная очистка (venv, build, db)"
	@echo ""

# ── Dev (всё сразу) ─────────────────────────────────────────────────────────
dev: setup
	@$(MAKE) -s _start-backend
	@$(MAKE) -s _start-frontend
	@echo ""
	@echo "  ✓ Backend:  http://localhost:$(BACKEND_PORT)"
	@echo "  ✓ Docs:     http://localhost:$(BACKEND_PORT)/docs"
	@echo "  ✓ Frontend: http://localhost:$(FRONTEND_PORT)"
	@echo ""
	@echo "  Логи: make logs"
	@echo "  Стоп: make stop"
	@echo ""
	@$(MAKE) -s _wait-and-open

_wait-and-open:
	@sleep 5
	@open http://localhost:$(FRONTEND_PORT) 2>/dev/null || true

# ── Stop ────────────────────────────────────────────────────────────────────
stop:
	@echo "Останавливаю сервисы..."
	@if [ -f $(BACKEND_PID) ]; then \
		kill $$(cat $(BACKEND_PID)) 2>/dev/null && echo "  ✓ Backend остановлен" || true; \
		rm -f $(BACKEND_PID); \
	fi
	@lsof -ti:$(BACKEND_PORT) | xargs kill -9 2>/dev/null || true
	@if [ -f $(FRONTEND_PID) ]; then \
		kill $$(cat $(FRONTEND_PID)) 2>/dev/null && echo "  ✓ Frontend остановлен" || true; \
		rm -f $(FRONTEND_PID); \
	fi
	@lsof -ti:$(FRONTEND_PORT) | xargs kill -9 2>/dev/null || true
	@echo "  Готово"

# ── Setup ───────────────────────────────────────────────────────────────────
setup: setup-backend setup-frontend
	@echo ""
	@echo "  ✓ Зависимости установлены"

setup-backend:
	@echo "→ Backend: настройка окружения..."
	@cd $(BACKEND_DIR) && \
		test -d .venv || python3 -m venv .venv && \
		.venv/bin/pip install -q --upgrade pip && \
		.venv/bin/pip install -q -r requirements.txt
	@test -f $(BACKEND_DIR)/.env || cp $(BACKEND_DIR)/.env.example $(BACKEND_DIR)/.env
	@echo "  ✓ Backend готов"

setup-frontend:
	@echo "→ Frontend: установка пакетов..."
	@cd $(FRONTEND_DIR) && $(FLUTTER) pub get --suppress-analytics 2>&1 | tail -3
	@echo "  ✓ Frontend готов"

# ── Backend ─────────────────────────────────────────────────────────────────
backend: setup-backend _start-backend
	@echo "  ✓ Backend: http://localhost:$(BACKEND_PORT)"
	@echo "  Логи: make logs-backend"

_start-backend:
	@echo "→ Запускаю backend на порту $(BACKEND_PORT)..."
	@lsof -ti:$(BACKEND_PORT) | xargs kill -9 2>/dev/null || true
	@sleep 1
	@cd $(BACKEND_DIR) && \
		.venv/bin/uvicorn app.main:app \
			--host 0.0.0.0 \
			--port $(BACKEND_PORT) \
			--reload \
			> $(BACKEND_LOG) 2>&1 & \
		echo $$! > $(BACKEND_PID)
	@sleep 3
	@curl -sf http://localhost:$(BACKEND_PORT)/health > /dev/null && \
		echo "  ✓ Backend запущен" || \
		(echo "  ✗ Backend не запустился. Лог:" && cat $(BACKEND_LOG) && exit 1)

# ── Frontend ────────────────────────────────────────────────────────────────
frontend: setup-frontend _start-frontend
	@echo "  ✓ Frontend: http://localhost:$(FRONTEND_PORT)"

_start-frontend:
	@echo "→ Запускаю Flutter Web на порту $(FRONTEND_PORT)..."
	@lsof -ti:$(FRONTEND_PORT) | xargs kill -9 2>/dev/null || true
	@cd $(FRONTEND_DIR) && \
		$(FLUTTER) run \
			-d chrome \
			--web-port $(FRONTEND_PORT) \
			--dart-define=API_BASE_URL=http://localhost:$(BACKEND_PORT) \
			--suppress-analytics \
			> $(FRONTEND_LOG) 2>&1 & \
		echo $$! > $(FRONTEND_PID)
	@echo "  ✓ Frontend запускается (Chrome откроется через ~10 сек)"

# ── Logs ────────────────────────────────────────────────────────────────────
logs:
	@echo "=== BACKEND ($(BACKEND_LOG)) ===" && \
	tail -30 $(BACKEND_LOG) 2>/dev/null || echo "(нет логов)" && \
	echo "" && \
	echo "=== FRONTEND ($(FRONTEND_LOG)) ===" && \
	tail -30 $(FRONTEND_LOG) 2>/dev/null || echo "(нет логов)"

logs-backend:
	@tail -f $(BACKEND_LOG) 2>/dev/null || echo "Backend не запущен"

logs-frontend:
	@tail -f $(FRONTEND_LOG) 2>/dev/null || echo "Frontend не запущен"

# ── Test API ────────────────────────────────────────────────────────────────
test-api:
	@echo "→ Тест API (http://localhost:$(BACKEND_PORT))"
	@echo ""
	@echo "[health]"
	@curl -sf http://localhost:$(BACKEND_PORT)/health | python3 -m json.tool
	@echo ""
	@echo "[profiles]"
	@curl -sf http://localhost:$(BACKEND_PORT)/api/v1/profiles/ | python3 -m json.tool
	@echo ""
	@echo "[AI: analyze Мелатонин]"
	@curl -sf -X POST http://localhost:$(BACKEND_PORT)/api/v1/medicines/analyze/name \
		-H "Content-Type: application/json" \
		-d '{"name": "Мелатонин"}' | python3 -m json.tool

# ── Clean ───────────────────────────────────────────────────────────────────
clean-db:
	@rm -f $(BACKEND_DIR)/dontforget.db
	@echo "  ✓ БД удалена"

clean: stop clean-db
	@rm -rf $(BACKEND_DIR)/.venv
	@rm -rf $(FRONTEND_DIR)/build
	@rm -rf $(FRONTEND_DIR)/.dart_tool
	@rm -f $(BACKEND_LOG) $(FRONTEND_LOG) $(BACKEND_PID) $(FRONTEND_PID)
	@echo "  ✓ Очистка завершена"
