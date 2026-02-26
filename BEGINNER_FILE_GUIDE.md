# 🧑‍🏫 Beginner File Guide (Easy Meaning of Each File)

This file explains what each important file does in very simple words.

## 1) Root Files

- `manage.py` → Main command file for Django. You run server, migrations, superuser from here.
- `requirements.txt` → List of Python packages needed by backend.
- `README.md` → Main project guide.
- `FLUTTER_DJANGO_INTEGRATION.md` → How Flutter and Django talk to each other.
- `CSV_IMPORT_GUIDE.md` → How to import CSV/Kaggle data.
- `PROJECT_SUMMARY.md` → High-level project overview.
- `db.sqlite3` → Local database file (all saved data in development).

## 2) Django Project Core (`FarmBuddy_Backend/`)

- `FarmBuddy_Backend/__init__.py` → Marks this folder as a Python package.
- `FarmBuddy_Backend/settings.py` → Main backend settings (apps, database, CORS, REST config).
- `FarmBuddy_Backend/urls.py` → Main URL router (connects `/api/...` routes).
- `FarmBuddy_Backend/asgi.py` → ASGI entry point (async servers).
- `FarmBuddy_Backend/wsgi.py` → WSGI entry point (traditional servers).

## 3) Crops App (`FarmBuddy_Backend/crops/`)

- `models.py` → Crop-related database tables.
- `serializers.py` → Converts crop Python objects ⇄ JSON API data.
- `views.py` → Crop API logic (list, detail, filters, recommendations).
- `admin.py` → Crop models shown/configured in Django admin.
- `apps.py` → App configuration.
- `tests.py` → Tests for crops app.
- `migrations/` → Database change history for crops models.

## 4) Farmers App (`FarmBuddy_Backend/farmers/`)

- `models.py` → Farmer tables (profiles, farmer crops, inventory).
- `serializers.py` → Farmer data validation and JSON conversion.
- `views.py` → Farmer APIs (list/create/update/filter).
- `admin.py` → Farmer models in admin panel.
- `apps.py` → App configuration.
- `tests.py` → Tests for farmers app.
- `migrations/` → Database change history for farmers models.

### Farmers Management Commands (`FarmBuddy_Backend/farmers/management/commands/`)

- `seed_demo_data.py` → Creates practical demo data quickly.
- `import_csv_data.py` → Imports crops/farmers/tasks from CSV files.
- `__init__.py` files → Enable Python package/module loading.

## 5) Tasks App (`FarmBuddy_Backend/tasks/`)

- `models.py` → Task-related tables (task, reminder, log).
- `serializers.py` → Task JSON conversion + validation.
- `views.py` → Task APIs and status update logic.
- `admin.py` → Tasks in admin panel.
- `apps.py` → App configuration.
- `tests.py` → Tests for tasks app.
- `migrations/` → Database change history for task models.

## 6) Weather App (`FarmBuddy_Backend/weather/`)

- `models.py` → Weather data tables (current, alerts, forecast).
- `serializers.py` → Weather JSON conversion + validation.
- `views.py` → Weather APIs (location/farmer filters, alerts).
- `admin.py` → Weather models in admin panel.
- `apps.py` → App configuration.
- `tests.py` → Tests for weather app.
- `migrations/` → Database change history for weather models.

## 7) Flutter App Root (`farm_buddy_app/`)

- `pubspec.yaml` → Flutter dependencies + app metadata.
- `pubspec.lock` → Exact dependency versions resolved locally.
- `analysis_options.yaml` → Dart lint/analyzer rules.
- `README.md` → Flutter-specific guide.
- `QUICKSTART.md` → Fast run instructions.
- `INSTALLATION.md` → Full setup instructions.
- `FILE_STRUCTURE.md` → Folder tree explanation.
- `.gitignore` → Files/folders Git should not track.

## 8) Flutter Source (`farm_buddy_app/lib/`)

- `main.dart` → App entry point (starts UI, routes/screens setup).

### Models (`farm_buddy_app/lib/models/`)
- `crop_model.dart` → Crop data classes and JSON parsing.
- `farmer_model.dart` → Farmer data classes and JSON parsing.
- `task_model.dart` → Task data classes and JSON parsing.
- `weather_model.dart` → Weather data classes and JSON parsing.

### Services (`farm_buddy_app/lib/services/`)
- `api_service.dart` → All HTTP calls to Django backend.
- `localization_service.dart` → Language handling (English/Hindi/Marathi).

### Screens (`farm_buddy_app/lib/screens/`)
- `home_screen.dart` → Dashboard/home page.
- `crops_screen.dart` → Crops list, filters, recommendations, guide.
- `farmers_screen.dart` → Farmers list/details.
- `tasks_screen.dart` → Tasks list and status updates.
- `weather_screen.dart` → Weather info and alerts.

## 9) Flutter Other Important Folders

- `farm_buddy_app/test/widget_test.dart` → Basic Flutter widget test.
- `farm_buddy_app/web/` → Web app shell files (index, icons, manifest).
- `farm_buddy_app/android/` → Android platform project files.
- `farm_buddy_app/ios/` → iOS platform project files.
- `farm_buddy_app/windows/` → Windows desktop platform files.

## 10) Files You Can Ignore as Beginner (for now)

- `__pycache__/`, `.dart_tool/`, `build/`, `ephemeral/` → Auto-generated.
- Log files like `flutter_output.txt`, `output.log`, `flutter_error.log` → Debug logs.
- Generated registrant/platform files → Re-created by Flutter tools.

---

## Start Here (Beginner Path)

1. Read `README.md`
2. Run backend with `python manage.py runserver`
3. Run frontend from `farm_buddy_app` with `flutter run -d chrome`
4. Explore APIs in browser: `http://localhost:8000/api/`
5. Use this guide whenever you are confused about any file
