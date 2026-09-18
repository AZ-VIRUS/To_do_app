# Simple To-Do App (Flutter + Firebase)

A multi-screen Flutter app for managing personal to-dos, with Firebase
Authentication, real-time Cloud Firestore CRUD, Provider-based state
management, and a dynamic Light/Dark theme toggle.

## Screenshots

> Replace these placeholders with your own screenshots or a screen
> recording/GIF before submitting (e.g. drag images into `docs/` and
> update the paths below).

| Login | Home | Add / Edit | Settings |
|---|---|---|---|
| `docs/login.png` | `docs/home.png` | `docs/add_edit.png` | `docs/settings.png` |

## Features

- **Authentication:** Email/Password sign up, sign in, and sign out via
  Firebase Auth. A single `AuthGate` widget listens to
  `FirebaseAuth.authStateChanges()` and redirects unauthenticated users
  to the login screen — so every other screen is protected automatically,
  and the session persists across app restarts.
- **Real-time CRUD:** To-do items live in Cloud Firestore's `todos`
  collection, each tagged with the owner's `uid`.
  - **Create** — add a new to-do from the `+` button.
  - **Read** — a live `StreamBuilder`-backed list updates instantly as
    data changes in Firestore.
  - **Update** — tap a to-do to edit its title/description, or tap the
    checkbox to toggle completion.
  - **Delete** — swipe a to-do left, confirm in the dialog, and it's
    removed.
- **State management:** [`provider`](https://pub.dev/packages/provider)
  is used throughout. `AuthProvider`, `TodoProvider`, and `ThemeProvider`
  hold all business logic and talk to `AuthService` / `FirestoreService`
  — widgets never call Firebase APIs directly.
- **Theming:** Custom `ThemeData` for Light and Dark mode
  (`lib/theme/app_theme.dart`), toggled instantly from the Settings
  screen without losing any app state (the toggle just flips
  `ThemeMode` in a provider that sits above `MaterialApp`).

## Project Structure

```
lib/
├── models/
│   └── todo_model.dart          # Todo model with toJson/fromJson
├── services/
│   ├── auth_service.dart        # Firebase Auth wrapper
│   └── firestore_service.dart   # Firestore CRUD wrapper
├── providers/
│   ├── auth_provider.dart       # Sign in/up/out state
│   ├── todo_provider.dart       # Real-time todo list + CRUD
│   └── theme_provider.dart      # Light/Dark mode state
├── theme/
│   └── app_theme.dart           # Light & Dark ThemeData
├── screens/
│   ├── splash_screen.dart       # AuthGate: routes to Login or Home
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── add_edit_todo_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── widgets/
│   └── todo_tile.dart           # List tile with swipe-to-delete
├── firebase_options.dart        # ⚠️ placeholder — regenerate, see below
└── main.dart                    # Firebase init + root providers
```

## Firebase Setup

This repo ships with a **placeholder** `lib/firebase_options.dart` and no
platform config files (`google-services.json`,
`GoogleService-Info.plist`) since those are project-specific and should
not be committed with real secrets in a public repo. To run the app
against your own Firebase project:

1. **Create a Firebase project** at
   [console.firebase.google.com](https://console.firebase.google.com).

2. **Enable services** in the console:
   - Authentication → Sign-in method → enable **Email/Password**.
   - Firestore Database → create a database (start in test mode for
     development, then apply `firestore.rules` from this repo before
     going to production).

3. **Install the FlutterFire CLI** (if you don't have it):
   ```bash
   dart pub global activate flutterfire_cli
   ```

4. **Log in and configure** from the project root:
   ```bash
   firebase login
   flutterfire configure
   ```
   Select your Firebase project and the platforms you want (Android,
   iOS, web, etc). This overwrites `lib/firebase_options.dart` with your
   real project values and adds any needed native config files
   automatically.

5. **Install dependencies and run:**
   ```bash
   flutter pub get
   flutter run
   ```

6. **Deploy the security rules** (recommended once you're past test
   mode), so users can only read/write their own to-dos:
   ```bash
   firebase deploy --only firestore:rules
   ```
   The included `firestore.rules` restricts every `todos/{id}` document
   to the authenticated user whose `uid` matches the document's
   `userId` field.

## Tech Stack

- Flutter (Material 3)
- `firebase_core`, `firebase_auth`, `cloud_firestore`
- `provider` for state management
- `intl` for date formatting

## Notes for Reviewers

- Business logic and Firebase calls live only in `services/` and
  `providers/` — `screens/` and `widgets/` are presentation-only.
- The Dismissible swipe gesture on each to-do triggers a confirmation
  `AlertDialog` before deleting, per the assignment's delete
  requirement.
- Every write to Firestore includes the current user's `uid`, and reads
  are filtered by it (`where('userId', isEqualTo: uid)`), satisfying the
  "linked to logged-in user" requirement end-to-end.
