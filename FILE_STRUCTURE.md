# File Structure

This document maps the major files and directories in `farm_buddy_app`.

## Root

- `pubspec.yaml`: Flutter package metadata and dependencies.
- `analysis_options.yaml`: linting and analyzer configuration.
- `README.md`: project overview and usage.
- `QUICKSTART.md`: shortest path to run locally.
- `INSTALLATION.md`: full setup instructions.
- `FILE_STRUCTURE.md`: this document.

## Source (`lib/`)

- `main.dart`
  - App bootstrap.
  - Theme and app-level navigation/auth gate.

- `models/`
  - `crop_model.dart`: crop and recommendation data models.
  - `farmer_model.dart`: farmer profile and selected crop models.
  - `task_model.dart`: task and task-state models.
  - `weather_model.dart`: weather alert/forecast models.

- `services/`
  - `api_service.dart`: all HTTP calls to backend API.
  - `auth_service.dart`: login/logout, token persistence, session restore.
  - `auth_ui_service.dart`: logout confirmation and unauthorized (`401/403`) handling.
  - `localization_service.dart`: language/localization helpers.

- `screens/`
  - `login_screen.dart`: sign-in UI.
  - `register_farmer_screen.dart`: farmer registration flow.
  - `app_shell.dart`: bottom navigation shell.
  - `home_screen.dart`: dashboard summary and entry actions.
  - `crops_screen.dart`: crop listing, filtering, recommendations, assignment.
  - `tasks_screen.dart`: task list, creation, status updates.
  - `farmers_screen.dart`: farmer listing/profile views.
  - `weather_screen.dart`: weather alerts and summaries.

- `widgets/`
  - Shared reusable UI components (if/when added).

## Tests (`test/`)

- `widget_test.dart`: app smoke/widget tests.
- `services/auth_ui_service_test.dart`: auth-ui helper and unauthorized detection tests.

## Platform Folders

- `android/`: Android runner project.
- `ios/`: iOS runner project.
- `web/`: web entry files and manifest.
- `windows/`: Windows runner project.
- `linux/`: Linux runner project.
- `macos/`: macOS runner project.

## Generated/Build Artifacts

Usually not edited manually:

- `build/`
- `.dart_tool/`
- platform-generated registrant files
