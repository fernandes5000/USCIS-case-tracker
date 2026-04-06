# USCIS Case Tracker

A mobile app for tracking USCIS immigration case statuses, built with Flutter and Rust.

## Architecture

```
claude-uscis/
├── backend/        # Rust API server (Axum + SQLite)
└── mobile/         # Flutter app (iOS, Android, macOS)
```

The Flutter app never talks directly to the USCIS API. All requests go through the Rust backend, which holds the USCIS OAuth2 credentials and proxies requests on behalf of authenticated users.

```
Flutter App  ──JWT──►  Rust Backend  ──OAuth2──►  USCIS Case Status API
                              │
                           SQLite
```

## Features

- Register / login with JWT authentication (access + refresh tokens)
- Add multiple USCIS receipt numbers to track (e.g. `EAC9999103403`)
- View current case status and full history timeline
- Optional nickname per case
- 5-minute server-side cache to avoid redundant USCIS API calls
- English, Brazilian Portuguese, and Spanish UI
- Light / Dark / System theme
- Locale and theme persist across sessions

## Prerequisites

| Tool | Version |
|---|---|
| Rust | 1.75+ (`rustup`) |
| Flutter | 3.22+ |
| Xcode | 15+ (for iOS/macOS) |
| Android Studio | (for Android) |

## Backend

### Setup

```bash
cd backend
cp .env.example .env
# Edit .env and fill in your USCIS credentials
```

**.env**
```env
HOST=0.0.0.0
PORT=8080

DATABASE_URL=sqlite:./data/uscis.db

JWT_SECRET=your-long-random-secret
JWT_EXPIRATION_HOURS=24
JWT_REFRESH_EXPIRATION_DAYS=30

USCIS_API_BASE_URL=https://api-int.uscis.gov
USCIS_TOKEN_URL=https://api-int.uscis.gov/oauth/accesstoken
USCIS_CLIENT_ID=your_client_id
USCIS_CLIENT_SECRET=your_client_secret
```

### Run

```bash
cargo run
# Listening on 0.0.0.0:8080
```

The SQLite database and migrations are applied automatically on first start.

### API Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| `POST` | `/api/auth/register` | No | Create account |
| `POST` | `/api/auth/login` | No | Login |
| `POST` | `/api/auth/refresh` | No | Refresh access token |
| `POST` | `/api/auth/logout` | Yes | Revoke refresh token |
| `GET` | `/api/cases` | Yes | List tracked cases |
| `POST` | `/api/cases` | Yes | Add a case |
| `GET` | `/api/cases/:receipt` | Yes | Get case + USCIS status |
| `PATCH` | `/api/cases/:receipt` | Yes | Update nickname |
| `DELETE` | `/api/cases/:receipt` | Yes | Remove case |
| `GET` | `/api/health` | No | Health check |

## Mobile

### Setup

```bash
cd mobile
flutter pub get
flutter gen-l10n
```

By default the app points to `http://192.168.50.51:8080`. Update the base URL in [lib/core/config/app_config.dart](mobile/lib/core/config/app_config.dart) or pass it at build time:

```bash
flutter run --dart-define=API_BASE_URL=http://your-server:8080
```

### Run

```bash
# macOS
flutter run -d macos

# iOS Simulator
open -a Simulator
flutter run

# Android Emulator
flutter emulators --launch <emulator_id>
flutter run
```

### Project Structure

```
mobile/lib/
├── app.dart                        # Root widget, theme, locale
├── main.dart
├── core/
│   ├── config/app_config.dart      # API base URL, storage keys
│   ├── network/                    # Dio client + auth interceptor
│   ├── providers/                  # locale_provider, theme_provider
│   ├── router/app_router.dart      # GoRouter + auth redirect
│   ├── storage/secure_storage.dart # Keychain / encrypted storage
│   └── theme/app_theme.dart        # Material 3 light + dark themes
├── features/
│   ├── auth/                       # Login, register, auth state
│   └── cases/                      # Case list, detail, add, profile
├── l10n/                           # ARB translation files (en, pt, es)
└── shared/widgets/
```

## USCIS Sandbox

The sandbox API only operates **Monday–Friday, 7:00 AM – 8:00 PM EST**.  
Outside those hours the API returns `503 Service Unavailable` — this is expected.

**Sandbox receipt numbers with case history:**

```
EAC9999103403  EAC9999103404  EAC9999103405  LIN9999106498
LIN9999106499  SRC9999102777  SRC9999102778  SRC9999132710
```

**Sandbox receipt numbers without history:**

```
EAC9999103400  EAC9999103402  EAC9999103406  LIN9999106501
```

> Sandbox credentials are obtained by registering at [developer.uscis.gov](https://developer.uscis.gov).

## Adding a New Language

1. Create `mobile/lib/l10n/app_XX.arb` (copy from `app_en.arb`)
2. Translate all values
3. Add `Locale('xx')` to `LocaleNotifier.supportedLocales` in [locale_provider.dart](mobile/lib/core/providers/locale_provider.dart)
4. Add a tile in the Profile screen language selector
5. Run `flutter gen-l10n`

## Security Notes

- USCIS OAuth2 credentials are **server-side only** — never shipped in the app
- Refresh tokens are stored as hashes in SQLite, not plaintext
- Mobile tokens are stored in Keychain (iOS/macOS) or EncryptedSharedPreferences (Android)
- JWT secret must be a long random string in production
