# 🌿 Plantlers

> **Grow Your Space** — A premium plant commerce and care app built with Flutter.

Plantlers connects plant lovers with freshly nurtured plants, delivered with care. From small desk succulents to statement fiddle leaf figs, Plantlers makes it effortless to bring nature into your space.


## 📱 Screenshots

<p align="center">
  <img src="assets/Figma%20Ss.png" alt="Plantlers App Showcase" width="100%">
</p>

✨ Features

- 🌱 **Browse & Shop** — Curated plant collections for every space
- 📦 **Same-day Delivery** — Freshly packed and delivered to your door
- 🔐 **Secure Auth** — Email/password + Google Sign-In
- 🌙 **Dark Mode** — Full system theme support
- 🔔 **Plant Care Reminders** — Never forget to water again
- 👤 **Plant Parent Profile** — Track your collection and journey

---

## 🎥 Demo Video



https://github.com/user-attachments/assets/42efc90d-8868-4b97-af61-8d2985ec4bfe





## 🏗️ Architecture

Plantlers is built following **Clean Architecture** principles with a feature-first folder structure.

```
lib/
├── core/                        # Shared infrastructure
│   ├── constants/               # API URLs, app keys
│   ├── di/                      # GetIt dependency injection
│   ├── errors/                  # Failures & exceptions
│   ├── network/                 # Dio client + interceptors
│   ├── router/                  # GoRouter config + route guards
│   ├── services/                # StorageService (secure + prefs)
│   ├── theme/                   # Colors, text styles, ThemeData
│   ├── usecases/                # Base UseCase<T, P>
│   └── utils/                   # Extensions, validators
│
├── features/
│   ├── splash/                  # Splash screen + launch routing
│   ├── onboarding/              # 3-slide onboarding flow
│   └── auth/                    # Login, signup, forgot password
│       ├── data/                # Models, datasources, repo impl
│       ├── domain/              # Entities, repo contracts, usecases
│       └── presentation/        # BLoC, pages, widgets
│
└── shared/
    └── widgets/                 # AppButton, AppTextField, etc.
```

### Layer Rules
- **Domain** — Pure Dart. Zero Flutter or external dependencies.
- **Data** → implements Domain contracts. Owns JSON, tokens, API calls.
- **Presentation** → calls UseCases only. Never touches repositories directly.
- **Dependency flow**: `Presentation → Domain ← Data`

---

## 🛠️ Tech Stack

| Category | Package |
|----------|---------|
| State Management | `flutter_bloc` + `bloc` |
| Dependency Injection | `get_it` |
| Navigation | `go_router` |
| Networking | `dio` |
| Local Storage | `shared_preferences` + `flutter_secure_storage` |
| Functional Programming | `dartz` (Either, Option) |
| Connectivity | `connectivity_plus` |
| Fonts | `google_fonts` (DM Serif Display, DM Sans) |
| SVG | `flutter_svg` |
| Auth | `google_sign_in` *(wired, pending Firebase config)* |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.10.0`
- Dart SDK `^3.10.8`
- Android Studio / VS Code
- A Firebase project (for Google Sign-In)

### Installation

```bash
# Clone the repo
git clone https://github.com/your-org/plantlers.git
cd plantlers

# Install dependencies
flutter pub get

# Run on device
flutter run
```

### Firebase Setup (Google Sign-In)

1. Create a project at [Firebase Console](https://console.firebase.google.com)
2. Add an Android app with package name `com.example.plantlers`
3. Enable **Google** in Authentication → Sign-in methods
4. Download `google-services.json` → place in `android/app/`
5. Add your debug SHA-1 fingerprint in Firebase → Project Settings

```bash
# Get your debug SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

---

## 📁 Environment & Configuration

| File | Purpose |
|------|---------|
| `lib/core/constants/api_constants.dart` | Base URL + all API endpoints |
| `lib/core/constants/app_constants.dart` | App name, storage keys, timeouts |
| `android/app/google-services.json` | Firebase config *(not committed)* |

> ⚠️ Never commit `google-services.json` or any secrets. Add them to `.gitignore`.

---

## 🎨 Design System

| Token | Value |
|-------|-------|
| Primary Green | `#00450D` |
| Primary Light | `#1B5E20` |
| Background (Light) | `#FAFAF5` |
| Background (Dark) | `#121212` |
| Field Background | `#E3E2E0` |
| Font — Display | DM Serif Display |
| Font — Body | DM Sans |

---

## 📋 App Flow

```
Launch
  └── Splash (2.5s, brand green)
        └── [First time] Onboarding (3 slides, auto-advance 3s, swipeable)
              └── Sign Up / Log In
                    └── Home
```

**Auth flow:**
```
Login ──────────────────────────────────────────── Home
  └── Forgot Password → OTP → Reset Password → Login
Sign Up ─────────────────────────────────────────── Home
```

---

## 🧱 Clean Architecture — Key Decisions

**Why tokens are NOT in `AuthEntity`**
Tokens are infrastructure concerns. `AuthEntity` carries only user identity (`id`, `email`, `name`, `avatarUrl`). Tokens live in `AuthModel` (data layer) and are persisted via `StorageService`.

**Why `StorageService` is injected, not instantiated**
Every class that needs storage receives it via constructor. This makes testing trivial — swap the real implementation for a mock without touching any business logic.

**Why BLoC is registered as `registerFactory`**
Each page gets a fresh BLoC instance. No stale state leaking between navigation events.

---

## 🗺️ Roadmap

- [x] Splash screen
- [x] Onboarding flow
- [x] Login screen
- [x] Sign up screen
- [x] Forgot password (OTP flow)
- [x] Light / Dark mode
- [ ] Home screen
- [ ] Plant detail screen
- [ ] Cart & checkout
- [ ] Order tracking
- [ ] Plant care reminders
- [ ] User profile
- [ ] Google Sign-In (Firebase)
- [ ] Push notifications

---

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Follow the clean architecture structure — new features go in `lib/features/`
4. Run `dart analyze` before pushing — zero issues required
5. Open a pull request

---

## 📄 License

© 2024 Plantlers Botanical Atelier. All rights reserved.

---

<p align="center">
  <strong>🌿 Grow Your Space</strong>
</p>
