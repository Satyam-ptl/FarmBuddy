# Farm Buddy Flutter App

Flutter client for Farm Buddy (multi-crop growth assistant), integrated with the Django REST backend.

## Overview

This app provides role-aware workflows for admins and farmers:

- Authentication (login, farmer registration, logout)
- Dashboard with core counts and quick actions
- Crop browsing, recommendations, and farmer crop selection
- Task creation and lifecycle management
- Farmer profile and crop visibility
- Weather alerts and summaries

## Technology Stack

- Flutter (Material 3)
- Dart
- HTTP API client (`http` package)
- Local session persistence (`shared_preferences`)

## Runtime Configuration

The API URL is configured at runtime with `--dart-define`.

- Config key: `API_BASE_URL`
- Default: `http://localhost:8000/api`

Examples:

```powershell
# Local default
flutter run -d chrome

# Explicit local API URL
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api

# Physical device on same network
flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8000/api
```

## Authentication and Session Behavior

- Token-based authentication is used for protected API calls.
- Session data is stored locally and restored on app start.
- If any protected request returns `401` or `403`, the app performs a forced logout and redirects to `LoginScreen`.
- A user-facing message is shown when session expiry is detected.

## Quick Start

1. Start backend:

```powershell
cd D:\git\FarmBuddy
python manage.py runserver 0.0.0.0:8000
```

2. Start frontend:

```powershell
cd D:\git\farm_buddy_app
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api
```

3. Verify app health:

```powershell
flutter analyze
flutter test
```

## Project Layout

See detailed structure in `FILE_STRUCTURE.md`.

High-level:

- `lib/main.dart`: app bootstrap + theme + auth gate
- `lib/screens/`: all feature screens
- `lib/services/`: API, auth, and auth UI/session handling
- `lib/models/`: DTOs and parsing
- `test/`: widget and service tests

## Development Notes

- Prefer passing API URL via `--dart-define` instead of hardcoding.
- Keep backend and frontend running in separate terminals.
- Run `flutter analyze` before committing.

## Documentation Index

- `README.md`: project overview and day-to-day usage
- `QUICKSTART.md`: shortest setup path
- `INSTALLATION.md`: full environment setup
- `FILE_STRUCTURE.md`: file-level mapping
