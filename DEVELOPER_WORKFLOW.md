# Developer Workflow Guide

This guide explains the project architecture, code organization, and development workflow for the 282 Munro Bagging app. Read this to understand where to add new features and how different parts of the app work together.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Overview](#architecture-overview)
3. [Project Structure](#project-structure)
4. [App Initialization Flow](#app-initialization-flow)
5. [Data Flow & State Management](#data-flow--state-management)
6. [Adding New Features](#adding-new-features)
7. [Code Style Guidelines](#code-style-guidelines)
8. [Testing](#testing)

## Project Overview

282 is a Flutter app with the following architecture:

- **Frontend**: Flutter with Provider for state management
- **Backend**: Firebase (Authentication, Feature Flags & Storage) + Supabase (PostgreSQL database)
- **Maps**: Google Maps and Mapbox integration
- **Analytics**: Mixpanel
- **Error Tracking**: Sentry
- **Deep Linking**: Branch.io
- **Push Notifications**: Firebase Cloud Messaging

### App Flavors

The app has two flavors:

- **Development**: For testing and development
- **Production**: For the live app store versions

## Architecture Overview

### Repository Pattern

The app uses the **Repository pattern** for data access. Each repository encapsulates data operations for a specific domain:

- **Firebase repositories**: Handle authentication (`AuthRepository`) and storage (`StorageRepository`)
- **Supabase repositories**: Handle database operations for munros, posts, users, etc.
- **Local repositories**: Handle local preferences (`SettingsRepository`, `AppFlagsRepository`)
- **Third-party repositories**: Weather, deep links, analytics, etc.

**Example Repository:**

```dart
class MunroRepository {
  final SupabaseClient _db;
  MunroRepository(this._db);

  Future<List<Munro>> getMunroData() async {
    final response = await _db.from('vu_munros').select();
    return response.map((item) => Munro.fromJSON(item)).toList();
  }
}
```

Repositories are defined in `lib/repos/` and injected via Provider in `app_providers.dart`.

### State Management with Provider

The app uses **Provider** for state management with `ChangeNotifier` classes.

#### Global State (38 total states)

Key global states accessible throughout the app:

- **`UserState`**: Current user data, profile updates
- **`AuthState`**: Authentication status and operations
- **`MunroState`**: All munro data, filtering, and completion tracking
- **etc**

**Example State:**

```dart
class MunroState extends ChangeNotifier {
  final MunroRepository _repository;
  final Logger _logger;

  MunroState(this._repository, this._logger);

  List<Munro> _munroList = [];
  List<Munro> get munroList => _munroList;

  Future<void> loadMunros() async {
    try {
      _munroList = await _repository.getMunroData();
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
    }
  }
}
```

#### Screen-Specific States

Each feature screen can have its own `ChangeNotifier` states:

- **`ProfileState`**: User profile data for profile screens
- **`MunroDetailState`**: Detail data for individual munro screens
- **`WeatherState`**: Weather data for weather screens
- **`ReviewsState`**: Reviews for a specific munro
- **`AchievementsState`**: User achievement progress

### Dependency Injection

All dependencies are configured in **`app_providers.dart`**:

1. **`buildRepositories()`**: Creates all repository providers
2. **`buildGlobalStates()`**: Creates all global state providers with dependencies

Dependencies are injected using `context.read<T>()` in state classes.

**Example:**

```dart
ChangeNotifierProvider<FeedState>(
  create: (ctx) => FeedState(
    ctx.read<PostsRepository>(),
    ctx.read<UserState>(),
    ctx.read<UserLikeState>(),
    ctx.read<Logger>(),
  ),
),
```

## App Initialization Flow

Understanding how the app starts up:

1. **`main.dart`**: Entry point

   - Initializes Flutter bindings
   - Loads environment config from JSON file
   - Initializes Firebase, Supabase, Mixpanel, Sentry
   - Sets up error logging
   - Configures push notifications background handler
   - Creates all providers (repositories + states)
   - Launches the app

2. **`app_providers.dart`**: Dependency injection

   - `buildRepositories()` creates all data access layers
   - `buildGlobalStates()` creates all state managers

3. **`app.dart`**: Main app widget

   - Sets up MaterialApp with routing
   - Configures navigation observers for analytics
   - Wraps app in coordinators for deep links and overlays

4. **`app_bootstrap.dart`**: Splash screen & initialization

   - Shows splash screen while `AppBootstrapState` loads
   - Waits for critical data before showing main app

5. **`AppBootstrapState.init()`**: Loads initial data

   - Remote config
   - App settings
   - Munro data
   - Deep link initialization
   - Push notification setup
   - User data (if logged in)

6. **Coordinators**: Handle intents
   - **`NavigationIntentCoordinator`**: Handles navigation from deep links
   - **`OverlayIntentCoordinator`**: Handles overlays like dialogs

## Project Structure

```
lib/
├── main.dart                          # App entry point & initialization
├── app.dart                           # Main app widget with MaterialApp
├── app_bootstrap.dart                 # Splash screen & loading wrapper
├── app_providers.dart                 # Dependency injection setup
├── navigation_intent_coordinator.dart # Deep link navigation handler
├── overlay_intent_coordinator.dart    # Overlay/dialog handler
│
├── analytics/                         # Analytics abstraction
├── config/
│   └── app_config.dart               # Environment configuration
├── enums/                            # App-wide enums
├── extensions/                       # Dart type extensions
├── helpers/                          # Utility functions
├── logging/                          # Logging infrastructure
│
├── models/                           # Data models (26 models)
│   ├── app_user.dart
│   ├── munro_model.dart
|   └── ...
│
├── push/                             # Push notifications
│
├── repos/                            # Data access layer (27 repositories)
│   ├── auth_repository.dart          # Firebase Auth
│   ├── user_repository.dart          # User CRUD operations
│   ├── munro_repository.dart         # Munro data
│   └── ...
│
├── screens/                          # Feature screens (30+ features)
│   ├── auth/                         # Authentication flows
│   │   ├── screens/                  # Login, registration screens
│   │   ├── widgets/                  # Auth-specific widgets
│   │   └── state/                    # Auth & User state
│   │
│   ├── explore/                      # Munro discovery & maps
│   │   ├── screens/                  # Map view, search
│   │   ├── widgets/                  # Map markers, filters
│   │   └── state/                    # Munro state
│   │
│   ├── nav/                          # Navigation & global state
│   │   └── state/                    # Bootstrap, layout, deep link states
│   │
│   └── home/                         # Bottom navigation container
│
├── support/                          # App-wide utilities
│
└── widgets/                          # Reusable UI components
    └── popup_widgets/                # Dialogs and overlays
```

### Screen Structure Pattern

Most feature screens follow this structure:

```
feature_name/
├── feature_tab.dart                 # Main tab entry point (if applicable)
├── screens/                         # Feature screens
│   ├── feature_screen.dart         # Main screen widget
│   └── detail_screen.dart          # Sub-screens
├── widgets/                         # Feature-specific widgets
│   ├── feature_header.dart
│   └── feature_list_tile.dart
└── state/                           # Feature state management
    ├── feature_state.dart          # Main state
    └── other_state.dart            # Related states
```

## Data Flow & State Management

### How Data Flows Through the App

1. **UI (Screens/Widgets)** → Reads state via `context.watch<State>()`

   ```dart
   final munros = context.watch<MunroState>().munroList;
   ```

2. **User Action** → Calls method on state via `context.read<State>().method()`

   ```dart
   await context.read<MunroState>().loadMunros();
   ```

3. **State** → Calls repository methods to fetch/update data

   ```dart
   _munroList = await _munroRepository.getMunroData();
   ```

4. **Repository** → Interacts with Firebase/Supabase/Local storage

   ```dart
   final response = await _db.from('vu_munros').select();
   ```

5. **State** → Calls `notifyListeners()` to update UI
   ```dart
   notifyListeners();
   ```

### Best Practices

- **Global states** are accessible anywhere in the app
- **Screen states** are typically created when navigating to that screen
- Always inject dependencies via Provider, never create instances directly
- Use `context.read<T>()` for one-time reads (like calling methods)
- Use `context.watch<T>()` for reactive updates (rebuilds when state changes)
- Handle errors gracefully and log them using the `Logger`

## Code Style Guidelines

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex business logic
- Keep functions small and focused
- Private members start with `_`
- Use `final` for variables that don't change
- Prefer `const` constructors where possible
- Always handle errors and log them

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `camelCase`
- **Private members**: `_leadingUnderscore`

## Testing

### Running Tests

```bash
flutter test
```

### Writing Tests

- Write unit tests for state classes
- Write widget tests for complex UI components
- Test both success and error cases
- Mock dependencies using Mockito

**Example Unit Test:**

```dart
test('loadItems should update items list', () async {
  // Arrange
  when(mockRepository.getMyData())
    .thenAnswer((_) async => [MyModel(id: '1', name: 'Test')]);

  // Act
  await myFeatureState.loadItems();

  // Assert
  expect(myFeatureState.items.length, 1);
  expect(myFeatureState.items[0].name, 'Test');
});
```

### Testing Checklist

- [ ] Test development builds on both Android and iOS
- [ ] Test edge cases (empty states, errors, loading)
- [ ] Test navigation flows
- [ ] Verify analytics events are tracked
- [ ] Check error logging works correctly

---

**Next Steps**:

- Ready to contribute? Check out the [Contributing Guidelines](CONTRIBUTING.md)
- Need to set up your environment? See the [Setup Guide](SETUP.md)
