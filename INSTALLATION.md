# Installation Guide

This document covers complete setup for local development on Windows (primary), with notes for other platforms.

## Prerequisites

Required software:

- Flutter SDK (stable channel)
- Git
- VS Code or Android Studio
- Python environment for backend (managed in `D:\git\FarmBuddy`)

Verify Flutter:

```powershell
flutter --version
flutter doctor
```

## Clone and Prepare Repositories

Expected layout:

- Backend: `D:\git\FarmBuddy`
- Frontend: `D:\git\farm_buddy_app`

Install Flutter dependencies:

```powershell
cd D:\git\farm_buddy_app
flutter pub get
```

## Backend Setup (Django)

From backend repository:

```powershell
cd D:\git\FarmBuddy
d:\git\.venv\Scripts\python.exe manage.py check
d:\git\.venv\Scripts\python.exe manage.py migrate
d:\git\.venv\Scripts\python.exe manage.py runserver 0.0.0.0:8000
```

Optional smoke check:

```powershell
curl http://localhost:8000/api/crops/
```

## Frontend Setup (Flutter)

Run with explicit API URL:

```powershell
cd D:\git\farm_buddy_app
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api
```

Android emulator URL:

```text
http://10.0.2.2:8000/api
```

Physical device URL:

```text
http://<your-lan-ip>:8000/api
```

## Build Commands

```powershell
# Static checks
flutter analyze
flutter test

# Production outputs
flutter build apk --release
flutter build appbundle --release
flutter build web --release
```

## Authentication Notes

- Login and registration are token-based.
- Token/session is persisted locally.
- On `401` or `403`, the app automatically logs out and redirects to login.

## Troubleshooting

1. Flutter not found:
   - Add Flutter `bin` directory to PATH.
2. API calls failing on Android emulator:
   - Use `10.0.2.2` instead of `localhost`.
3. CORS issues in web:
   - Confirm backend CORS middleware/configuration.
4. App stuck after expired token:
   - Restart app or clear browser/app storage, then sign in again.

## Recommended Developer Workflow

1. Start backend server.
2. Run frontend with `--dart-define=API_BASE_URL=...`.
3. Run `flutter analyze` before every commit.
4. Run `flutter test` for verification.
