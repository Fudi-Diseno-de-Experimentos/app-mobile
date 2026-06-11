# CENTRALIS Mobile

Flutter client for CENTRALIS, an internal company-communication platform:
announcements, events, 1:1 and group chat, member directory, and view
analytics for managers.

## Architecture

Clean architecture per feature (`lib/features/<feature>/{data,domain,presentation}`)
with BLoC for state management, GetIt for dependency injection, fpdart
`Either` for error handling, and GoRouter for navigation. Shared
infrastructure lives in `lib/core` (Dio API client, auth interceptor,
`TokenStore`, `TtlCache`, Cloudinary uploads, theme).

## Setup

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install)
   (Dart ≥ 3.9).
2. Create a `.env` file at the project root (it is bundled as an asset, so
   **never put secrets in it** — anything here ships inside the APK/IPA):

   ```env
   # Cloudinary cloud name (uploads use unsigned presets)
   CLOUD_NAME=<your-cloud-name>

   # Backend base URL
   URL_SERVICE=https://<your-backend-host>
   ```

3. Install dependencies and run:

   ```sh
   flutter pub get
   flutter run
   ```

## Tests

```sh
# Unit, bloc, model and repository-integration tests
flutter test

# End-to-end tests (patrol; requires a connected device or emulator)
dart pub global activate patrol_cli
patrol test
```

After changing any mocked interface, regenerate mocks with:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Project documentation

- `files/CODE-AUDIT.md` — latest code audit and fix log
- `files/UI-UX-STYLE-GUIDE.md` — UI/UX guidelines
- `files/theme-rules.md` — theming rules (use `Theme.of(context).colorScheme`,
  not raw colors)
