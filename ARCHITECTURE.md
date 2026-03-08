# DontForget — Архитектура приложения

## Принципы разработки

| Принцип | Как применяется |
|---------|----------------|
| **SOLID** | Каждый класс — одна ответственность, зависимости только от абстракций, интерфейсы узкие |
| **DRY** | Общие виджеты, базовые классы, кодогенерация (freezed, injectable) |
| **KISS** | Feature-first Clean Architecture, Cubit вместо BLoC там где состояние простое, минимум абстракций |

---

## Инструмент скаффолдинга

### Very Good CLI + Mason

**Very Good CLI** (by Very Good Ventures) — официально рекомендуемый инструмент для production-ready Flutter-приложений. Генерирует правильную структуру, настраивает тесты, линтеры, CI.

**Mason** — система шаблонов (bricks) для генерации фичей по единому шаблону.

```bash
# Установка инструментов
dart pub global activate very_good_cli
dart pub global activate mason_cli

# Создание проекта
very_good create flutter_app dontforget \
  --desc "Smart reminders for medications, shopping and tasks" \
  --org "com.dontforget"

# Добавление brick для фичей
mason add feature          # кастомный brick для генерации feature-модуля
mason add l10n_arb_entry   # brick для добавления новых строк локализации

# Генерация новой фичи (пример)
mason make feature --name medicines
mason make feature --name profiles
mason make feature --name reminders
mason make feature --name shopping
mason make feature --name todos
```

Каждый вызов `mason make feature --name X` создаёт полную структуру модуля: data / domain / presentation — по единому шаблону, устраняя рутину и обеспечивая консистентность (DRY).

---

## Структура Flutter-проекта

```
dontforget/
├── frontend/                          # Flutter app
│   ├── lib/
│   │   ├── core/                      # Ядро, не зависит от фич
│   │   │   ├── constants/
│   │   │   │   ├── app_constants.dart
│   │   │   │   └── api_constants.dart
│   │   │   ├── di/
│   │   │   │   └── injection.dart     # get_it + injectable setup
│   │   │   ├── error/
│   │   │   │   └── failures.dart      # sealed class Failure
│   │   │   ├── network/
│   │   │   │   ├── api_client.dart    # Dio + interceptors
│   │   │   │   └── network_info.dart  # connectivity check
│   │   │   ├── router/
│   │   │   │   └── app_router.dart    # go_router
│   │   │   ├── theme/
│   │   │   │   ├── app_theme.dart
│   │   │   │   ├── app_colors.dart
│   │   │   │   └── app_text_styles.dart
│   │   │   └── l10n/                  # Локализация
│   │   │       ├── arb/
│   │   │       │   ├── app_ru.arb     # Русский (основной)
│   │   │       │   ├── app_en.arb     # Английский
│   │   │       │   └── app_de.arb     # Немецкий (пример расширения)
│   │   │       └── l10n.dart          # re-export сгенерированных классов
│   │   ├── features/
│   │   │   ├── medicines/             # Лекарства и БАДы
│   │   │   │   ├── data/
│   │   │   │   │   ├── datasources/
│   │   │   │   │   │   ├── medicines_remote_datasource.dart
│   │   │   │   │   │   └── medicines_local_datasource.dart
│   │   │   │   │   ├── models/
│   │   │   │   │   │   ├── medicine_model.dart        # freezed + json
│   │   │   │   │   │   └── compatibility_model.dart
│   │   │   │   │   └── repositories/
│   │   │   │   │       └── medicines_repository_impl.dart
│   │   │   │   ├── domain/
│   │   │   │   │   ├── entities/
│   │   │   │   │   │   ├── medicine.dart              # чистые бизнес-объекты
│   │   │   │   │   │   └── compatibility_result.dart
│   │   │   │   │   ├── repositories/
│   │   │   │   │   │   └── medicines_repository.dart  # abstract interface
│   │   │   │   │   └── usecases/
│   │   │   │   │       ├── analyze_photo_usecase.dart
│   │   │   │   │       ├── check_compatibility_usecase.dart
│   │   │   │   │       ├── add_medicine_usecase.dart
│   │   │   │   │       └── get_medicines_usecase.dart
│   │   │   │   └── presentation/
│   │   │   │       ├── cubit/
│   │   │   │       │   ├── medicines_cubit.dart
│   │   │   │       │   ├── medicines_state.dart
│   │   │   │       │   ├── analyze_cubit.dart
│   │   │   │       │   └── analyze_state.dart
│   │   │   │       ├── pages/
│   │   │   │       │   ├── medicines_page.dart
│   │   │   │       │   ├── add_medicine_page.dart
│   │   │   │       │   ├── medicine_detail_page.dart
│   │   │   │       │   └── compatibility_page.dart
│   │   │   │       └── widgets/
│   │   │   │           ├── medicine_card.dart
│   │   │   │           ├── compatibility_badge.dart
│   │   │   │           └── recommendation_sheet.dart
│   │   │   ├── profiles/              # Профили пользователей
│   │   │   │   └── ...               # аналогичная структура
│   │   │   ├── reminders/            # Напоминания
│   │   │   │   └── ...
│   │   │   ├── shopping/             # Списки покупок
│   │   │   │   └── ...
│   │   │   ├── todos/                # Задачи
│   │   │   │   └── ...
│   │   │   └── dashboard/            # Главный экран "Сегодня"
│   │   │       └── ...
│   │   ├── shared/                   # Переиспользуемое между фичами
│   │   │   ├── widgets/
│   │   │   │   ├── df_button.dart        # Design System кнопки
│   │   │   │   ├── df_card.dart
│   │   │   │   ├── df_text_field.dart
│   │   │   │   ├── df_bottom_sheet.dart
│   │   │   │   ├── df_loading.dart
│   │   │   │   └── df_empty_state.dart
│   │   │   └── utils/
│   │   │       ├── date_formatter.dart
│   │   │       └── validators.dart
│   │   └── main.dart
│   ├── test/
│   │   ├── core/
│   │   ├── features/
│   │   │   └── medicines/
│   │   │       ├── data/
│   │   │       ├── domain/
│   │   │       └── presentation/
│   │   └── shared/
│   ├── l10n.yaml                      # конфиг генерации локализации
│   └── pubspec.yaml
├── backend/                           # FastAPI
│   └── ...
└── CONCEPT.md
```

---

## Clean Architecture — принципы применения

```
Presentation  →  Domain  ←  Data
  (Cubit)       (UseCase)   (Repository impl)
  (Pages)       (Entity)    (Model)
  (Widgets)     (Repo iface)(Datasource)
```

### Правило зависимостей (Dependency Rule)
- **Domain** не знает ни о Presentation, ни о Data
- **Data** реализует интерфейсы из Domain
- **Presentation** вызывает UseCases, не знает о Data

### S — Single Responsibility
```dart
// ПЛОХО: один класс делает всё
class MedicineManager { ... }

// ХОРОШО: каждый класс — одна задача
class AnalyzePhotoUseCase { ... }       // только анализ фото
class CheckCompatibilityUseCase { ... } // только совместимость
class MedicinesRepositoryImpl { ... }   // только доступ к данным
```

### O — Open/Closed
```dart
// Интерфейс не меняется при добавлении нового источника данных
abstract interface class MedicinesRepository {
  Future<Either<Failure, Medicine>> analyzePhoto(List<File> photos);
  Future<Either<Failure, CompatibilityResult>> checkCompatibility(
    String newMedicineId, List<String> activeMedicineIds);
}

// Легко заменить реализацию (AI-провайдер, кэш, офлайн-база)
@Injectable(as: MedicinesRepository)
class MedicinesRepositoryImpl implements MedicinesRepository { ... }
```

### L — Liskov Substitution
```dart
// Любая реализация MedicinesRemoteDataSource взаимозаменяема
abstract interface class MedicinesRemoteDataSource {
  Future<MedicineModel> analyzePhoto(List<String> base64Images);
}

@Injectable(as: MedicinesRemoteDataSource)
class OpenRouterMedicineDataSource implements MedicinesRemoteDataSource { ... }

// В тестах заменяется на мок без изменения кода
class MockMedicineDataSource implements MedicinesRemoteDataSource { ... }
```

### I — Interface Segregation
```dart
// Не один жирный интерфейс
abstract interface class MedicinesRemoteDataSource {
  Future<MedicineModel> analyzePhoto(List<String> base64Images);
  Future<CompatibilityModel> checkCompatibility(List<String> ids);
}

abstract interface class MedicinesLocalDataSource {
  Future<List<MedicineModel>> getCachedMedicines();
  Future<void> cacheMedicine(MedicineModel medicine);
}
// Имплементации зависят только от нужного интерфейса
```

### D — Dependency Inversion
```dart
// get_it + injectable: всё через интерфейсы
@injectable
class CheckCompatibilityUseCase {
  final MedicinesRepository _repository; // зависим от абстракции
  CheckCompatibilityUseCase(this._repository);

  Future<Either<Failure, CompatibilityResult>> call(
    CheckCompatibilityParams params) => _repository.checkCompatibility(...);
}
```

---

## Пакеты Flutter

### Архитектура и DI
```yaml
dependencies:
  # State management
  flutter_bloc: ^8.1.6

  # Dependency injection
  get_it: ^8.0.0
  injectable: ^2.5.0

  # Функциональное программирование (Either, Option)
  dartz: ^0.10.1

  # Навигация
  go_router: ^14.0.0

  # Сеть
  dio: ^5.7.0

  # Локальное хранилище
  hive_flutter: ^1.1.0        # офлайн-кэш
  shared_preferences: ^2.3.0  # настройки, язык

  # Локализация
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

  # Работа с изображениями
  image_picker: ^1.1.2
  camera: ^0.11.0

  # Уведомления
  flutter_local_notifications: ^17.2.0
  firebase_messaging: ^15.1.0

  # UI
  cached_network_image: ^3.4.0
  shimmer: ^3.0.0
  lottie: ^3.1.0              # анимации (мягкие, ненавязчивые)

dev_dependencies:
  # Кодогенерация
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  injectable_generator: ^2.6.0
  build_runner: ^2.4.12

  # Тесты
  mocktail: ^1.0.4
  bloc_test: ^9.1.7
  very_good_analysis: ^6.0.0  # линтер от VGC
```

---

## Мультиязычность

### Подход: flutter_localizations + ARB-файлы

ARB (Application Resource Bundle) — официальный стандарт Flutter для локализации. Файлы хранятся в `lib/core/l10n/arb/`, при сборке генерируется строго типизированный класс `AppLocalizations`.

### Конфигурация `l10n.yaml`
```yaml
arb-dir: lib/core/l10n/arb
template-arb-file: app_ru.arb
output-localization-file: app_localizations.dart
output-class: AppL10n
synthetic-package: false
output-dir: lib/core/l10n
```

### Пример ARB-файла `app_ru.arb`
```json
{
  "@@locale": "ru",
  "appName": "DontForget",
  "dashboard_greeting_morning": "Доброе утро, {name}!",
  "@dashboard_greeting_morning": {
    "placeholders": {
      "name": { "type": "String" }
    }
  },
  "medicine_take_now": "Сейчас нужно принять",
  "medicine_taken": "Принял",
  "medicine_snooze": "Отложить на 15 мин",
  "medicine_skip": "Пропустить сегодня",
  "compatibility_ok": "Совместим",
  "compatibility_caution": "С осторожностью",
  "compatibility_danger": "Несовместим",
  "profile_age_years": "{count, plural, one{{count} год} few{{count} года} other{{count} лет}}",
  "@profile_age_years": {
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

### Пример `app_en.arb`
```json
{
  "@@locale": "en",
  "appName": "DontForget",
  "dashboard_greeting_morning": "Good morning, {name}!",
  "medicine_take_now": "Time to take",
  "medicine_taken": "Taken",
  "medicine_snooze": "Snooze 15 min",
  "medicine_skip": "Skip today",
  "compatibility_ok": "Compatible",
  "compatibility_caution": "Use with caution",
  "compatibility_danger": "Incompatible",
  "profile_age_years": "{count, plural, one{{count} year} other{{count} years}}"
}
```

### LocaleCubit — переключение языка
```dart
// features ближе к core, но как отдельный cubit
@injectable
class LocaleCubit extends Cubit<Locale> {
  final SharedPreferences _prefs;

  LocaleCubit(this._prefs) : super(
    Locale(_prefs.getString('locale') ?? 'ru'),
  );

  void changeLocale(String languageCode) {
    _prefs.setString('locale', languageCode);
    emit(Locale(languageCode));
  }
}
```

### Подключение в `main.dart`
```dart
MaterialApp.router(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: const [
    Locale('ru'),
    Locale('en'),
    Locale('de'),
    // Добавить новый язык = 1 ARB-файл + строка здесь
  ],
  locale: context.watch<LocaleCubit>().state,
  ...
)
```

### Использование в виджетах
```dart
// Строго типизировано, IDE подскажет все ключи
Text(AppLocalizations.of(context)!.medicine_take_now)

// Или через extension (DRY):
extension LocalizationX on BuildContext {
  AppL10n get l10n => AppL10n.of(this)!;
}
// Использование:
Text(context.l10n.medicine_take_now)
```

### Поддерживаемые языки (план)
| Этап | Языки |
|------|-------|
| MVP | Русский, Английский |
| v2  | Немецкий, Французский |
| v3  | Испанский, Арабский (RTL) |

Добавление нового языка = создать один ARB-файл + добавить `Locale` в список. Никаких изменений в коде.

---

## Структура Backend (FastAPI)

```
backend/
├── app/
│   ├── core/
│   │   ├── config.py            # pydantic-settings, читает .env
│   │   ├── database.py          # SQLAlchemy async engine
│   │   ├── dependencies.py      # DI FastAPI (get_db, get_ai_client)
│   │   └── ai/
│   │       ├── client.py        # OpenRouter HTTP client
│   │       └── prompts.py       # все промпты в одном месте (DRY)
│   ├── features/
│   │   ├── medicines/
│   │   │   ├── models.py        # SQLAlchemy ORM
│   │   │   ├── schemas.py       # Pydantic request/response
│   │   │   ├── repository.py    # abstract + impl (DIP)
│   │   │   ├── service.py       # бизнес-логика
│   │   │   └── router.py        # FastAPI endpoints
│   │   ├── profiles/
│   │   ├── reminders/
│   │   ├── shopping/
│   │   └── todos/
│   ├── shared/
│   │   ├── base_repository.py   # Generic[T] базовый CRUD (DRY)
│   │   └── exceptions.py        # общие исключения
│   └── main.py                  # app factory
├── migrations/                  # Alembic
├── tests/
├── .env
├── .env.example
├── requirements.txt
└── railway.toml
```

### `.env.example`
```env
# Database
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/dontforget

# AI
OPENROUTER_API_KEY=sk-or-...
OPENROUTER_MODEL=x-ai/grok-4.1-fast
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
OPENROUTER_MAX_TOKENS=2000

# Storage (Cloudflare R2 или любой S3-совместимый)
S3_BUCKET=dontforget-photos
S3_ENDPOINT=https://<account>.r2.cloudflarestorage.com
S3_ACCESS_KEY=
S3_SECRET_KEY=

# Push notifications
FCM_SERVER_KEY=

# App
APP_SECRET_KEY=
APP_DEBUG=false
ALLOWED_ORIGINS=*
```

### `app/core/config.py`
```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str
    openrouter_api_key: str
    openrouter_model: str = "x-ai/grok-4.1-fast"
    openrouter_base_url: str = "https://openrouter.ai/api/v1"
    openrouter_max_tokens: int = 2000
    s3_bucket: str
    s3_endpoint: str
    s3_access_key: str
    s3_secret_key: str
    fcm_server_key: str
    app_secret_key: str
    app_debug: bool = False

settings = Settings()
```

### Базовый репозиторий (DRY + SOLID)
```python
from typing import Generic, TypeVar, Type
from sqlalchemy.ext.asyncio import AsyncSession

T = TypeVar("T")

class BaseRepository(Generic[T]):
    def __init__(self, model: Type[T], session: AsyncSession):
        self.model = model
        self.session = session

    async def get_by_id(self, id: str) -> T | None: ...
    async def get_all(self) -> list[T]: ...
    async def create(self, obj: T) -> T: ...
    async def update(self, obj: T) -> T: ...
    async def delete(self, id: str) -> None: ...

# Фича-репозиторий только добавляет специфические методы
class MedicinesRepository(BaseRepository[Medicine]):
    async def search_by_name(self, name: str) -> list[Medicine]: ...
    async def get_active_for_profile(self, profile_id: str) -> list[Medicine]: ...
```

### `railway.toml`
```toml
[build]
builder = "nixpacks"

[deploy]
startCommand = "uvicorn app.main:app --host 0.0.0.0 --port $PORT"
healthcheckPath = "/health"
healthcheckTimeout = 30
restartPolicyType = "on_failure"
```

---

## Поток данных (Medicine Flow)

```
Пользователь делает фото
         ↓
[Flutter] ImagePicker → base64
         ↓
[Cubit] AnalyzeCubit.analyzePhoto(files)
         ↓
[UseCase] AnalyzePhotoUseCase.call(params)
         ↓
[Repository interface] MedicinesRepository.analyzePhoto(base64List)
         ↓
[Repository impl] → HTTP POST /api/v1/medicines/analyze
         ↓
[FastAPI] MedicinesRouter → MedicinesService
         ↓
[Service] → проверить кэш в БД → если нет → OpenRouter AI
         ↓
[AI] grok-4.1-fast с vision → структурированный JSON
         ↓
[Service] → сохранить в БД → вернуть MedicineSchema
         ↓
[Flutter] MedicineModel → domain entity Medicine
         ↓
[Cubit] emit(AnalyzeSuccess(medicine))
         ↓
[Page] RecommendationSheet показывает карточку
```

---

## Тестирование

Уровни покрытия по слоям:

| Слой | Вид тестов | Инструменты |
|------|-----------|-------------|
| Domain (UseCases) | Unit | mocktail |
| Data (Repository) | Unit | mocktail, fake_async |
| Presentation (Cubit) | Unit | bloc_test |
| Widgets | Widget tests | flutter_test |
| Интеграция | Integration | integration_test |

Команды:
```bash
# Запуск всех тестов
very_good test --coverage

# Кодогенерация
dart run build_runner build --delete-conflicting-outputs
```

---

## CI/CD (GitHub Actions → Railway)

```yaml
# .github/workflows/main.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: dart run build_runner build
      - run: very_good test --coverage

  deploy_backend:
    needs: test
    if: github.ref == 'refs/heads/main'
    # Railway auto-deploys из main ветки через GitHub integration
```

---

## Схема БД (ключевые таблицы)

```sql
-- Профили пользователей
profiles (id, name, birth_date, gender, weight_kg, health_notes, allergies, avatar_url, created_at)

-- База знаний препаратов (кэш AI-ответов)
medicines_kb (id, name_trade, name_generic, substance, form, dosage_per_unit,
              category, action_simple, side_effects, interactions_json, source, created_at)

-- Активные препараты профиля
profile_medicines (id, profile_id, medicine_kb_id, dose, frequency_per_day,
                   times_json, course_days, start_date, end_date, notes, is_active)

-- История приёмов
intake_logs (id, profile_medicine_id, scheduled_at, taken_at, status) -- status: taken|skipped|snoozed

-- Списки покупок
shopping_lists (id, profile_id, name, created_at)
shopping_items (id, list_id, text, category, is_done, position)

-- Задачи
todos (id, profile_id, text, due_at, is_done, priority, repeat_rule, parent_id, tags_json)
```

---

## Масштабирование и расширяемость

- **Новая фича** → `mason make feature --name X` → готовая структура за 10 секунд
- **Новый язык** → создать ARB-файл → добавить Locale → готово
- **Смена AI-провайдера** → заменить только `OpenRouterMedicineDataSource`, интерфейс не меняется
- **Офлайн-режим** → добавить `HiveMedicinesLocalDataSource`, репозиторий выбирает источник
- **Новый тип напоминаний** → новый feature-модуль, не трогая существующие
