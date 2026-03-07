# Farm Buddy

Farm Buddy is a full-stack agriculture management platform with a Django REST backend and a Flutter frontend.

It helps manage:

- Crops and cultivation guidance
- Farmers and farmer profiles
- Farm tasks and priorities
- Weather alerts and advisories

## Repository Layout

- `FarmBuddy_Backend/`: Django project and apps (`crops`, `farmers`, `tasks`, `weather`)
- `farm_buddy_app/`: Flutter client app
- `import_templates/`: CSV templates for bulk import
- `requirements.txt`: backend dependencies
- `manage.py`: Django entry point

## Core Features

- REST API for all major farm operations
- Role-aware workflows (admin and farmer)
- Task lifecycle tracking with validation
- Crop filtering and recommendations
- Weather alerts and summaries
- Token-based authentication
- Session-expiry handling in Flutter (`401/403` auto logout)

## Tech Stack

- Backend: Python, Django, Django REST Framework
- Frontend: Flutter, Dart
- Database: SQLite (default)

## Quick Start

### 1. Backend

```powershell
cd D:\git\FarmBuddy
d:\git\.venv\Scripts\python.exe manage.py check
d:\git\.venv\Scripts\python.exe manage.py migrate
d:\git\.venv\Scripts\python.exe manage.py runserver 0.0.0.0:8000
```

### 2. Frontend

```powershell
cd D:\git\FarmBuddy\farm_buddy_app
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api
```

## API Base URL

Flutter reads API URL from `--dart-define`:

- key: `API_BASE_URL`
- default: `http://localhost:8000/api`

For Android emulator use:

- `http://10.0.2.2:8000/api`

## Development Checks

```powershell
# Backend
cd D:\git\FarmBuddy
d:\git\.venv\Scripts\python.exe manage.py check

# Frontend
cd D:\git\FarmBuddy\farm_buddy_app
flutter analyze
flutter test
```

## Documentation

- `PROJECT_SUMMARY.md`: architecture and system summary
- `BEGINNER_FILE_GUIDE.md`: beginner-friendly file explanations
- `farm_buddy_app/README.md`: Flutter app documentation
- `farm_buddy_app/INSTALLATION.md`: frontend setup details
- `farm_buddy_app/QUICKSTART.md`: fast startup commands
