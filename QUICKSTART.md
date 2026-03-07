# Quick Start

Use this guide if you already have Flutter and the backend environment installed.

## 1. Start Backend

```powershell
cd D:\git\FarmBuddy
d:\git\.venv\Scripts\python.exe manage.py runserver 0.0.0.0:8000
```

Health check:

```powershell
curl http://localhost:8000/api/crops/
```

## 2. Start Flutter App

```powershell
cd D:\git\farm_buddy_app
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api
```

## 3. Verify Quality Gates

```powershell
cd D:\git\farm_buddy_app
flutter analyze
flutter test
```

## 4. Optional: Run on Android Emulator

```powershell
flutter emulators
flutter emulators --launch <emulator_id>
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

## 5. Optional: Run on Physical Device

Use your machine IP and ensure device + machine are on same network:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8000/api
```

## Common Startup Issues

1. Backend unreachable: confirm Django is running on `0.0.0.0:8000`.
2. Wrong API URL: pass correct `--dart-define=API_BASE_URL=...` value.
3. Session expiry loops: clear app data/browser storage and sign in again.
4. Web CORS errors: verify Django CORS settings in backend project.
