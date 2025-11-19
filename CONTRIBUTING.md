# Contributing to 282 - Munro Bagging App

Welcome to the 282 project! This guide will help you set up your development environment and get the app running locally. 282 is a Flutter app for munro bagging that includes social features, tracking, and discovery.

You'll need to create your own development projects for Firebase, Supabase, and other third-party services.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Overview](#project-overview)
3. [Getting Started](#getting-started)
4. [Firebase Setup](#firebase-setup)
5. [Supabase Setup](#supabase-setup)
6. [Third-Party Services](#third-party-services)
7. [Environment Configuration](#environment-configuration)
8. [Development Workflow](#development-workflow)
9. [Building and Running](#building-and-running)
10. [Contributing Guidelines](#contributing-guidelines)

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (>=3.8.1): [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **Visual Studio Code** with Flutter extensions
- **Xcode** (for iOS development, macOS only)
- **Git**
- **Node.js** (for Firebase Functions)
- **Firebase CLI**: `npm install -g firebase-tools`
- **Supabase CLI**: [Installation Guide](https://supabase.com/docs/guides/cli) (optional)

## Project Overview

282 is a Flutter app with the following architecture:

- **Frontend**: Flutter with Provider for state management
- **Backend**: Firebase (Authentication, FeatureFlags & Storage) + Supabase (PostgreSQL database)
- **Maps**: Google Maps and Mapbox integration
- **Analytics**: Mixpanel
- **Error Tracking**: Sentry
- **Deep Linking**: Branch.io
- **Push Notifications**: Firebase Cloud Messaging

### App Flavors

The app has two flavors:

- **Development**: For testing and development
- **Production**: For the live app store versions

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/alastairrmcneill/282.git
cd 282
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Install Firebase Functions Dependencies

```bash
cd functions
npm install
cd ..
```

## Firebase Setup

You'll need to create your own Firebase project for development.

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name your project (e.g., "282-dev-yourname")
4. Enable Google Analytics (optional)
5. Create the project

### 2. Enable Firebase Services

In your Firebase project, enable these services:

#### Authentication

1. Go to Authentication → Sign-in method
2. Enable the following providers:
   - **Google**: You'll need to configure OAuth consent screen
   - **Apple**: For iOS (requires Apple Developer account)
   - **Anonymous** (optional, for testing)

#### Firestore Database

1. Go to Firestore Database
2. Create database in test mode (you can change rules later)
3. Choose a location close to your users

#### Storage

1. Go to Storage
2. Get started with default rules
3. Choose the same location as Firestore

#### Cloud Functions

1. Enable Cloud Functions (will be configured later)

#### Cloud Messaging

1. Go to Cloud Messaging
2. No additional setup needed initially

### 3. Configure Android App

1. In Firebase Console, click "Add app" → Android
2. Use package name: `com.alastairrmcneill.TwoEightTwo.dev` (for development flavor)
3. Download `google-services.json`
4. Place the file in: `android/app/src/development/google-services.json`
5. For production flavor, repeat with package name: `com.alastairrmcneill.TwoEightTwo`
6. Place production file in: `android/app/src/production/google-services.json`

### 4. Configure iOS App

1. In Firebase Console, click "Add app" → iOS
2. Use bundle ID: `com.alastairrmcneill.TwoEightTwo.dev` (for development)
3. Download `GoogleService-Info.plist`
4. Place the file in: `ios/config/development/GoogleService-Info.plist`
5. For production flavor, repeat with bundle ID: `com.alastairrmcneill.TwoEightTwo`
6. Place production file in: `ios/config/production/GoogleService-Info.plist`

### 5. Configure Google Maps API

#### Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project (or create a new one)
3. Enable Google Maps SDK for Android and iOS
4. Create credentials → API Key
5. Restrict the API key to your app (recommended for production)

#### Configure iOS

Update `ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
```

#### Configure Android

Add to `android/app/src/main/AndroidManifest.xml` inside `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

### 6. Deploy Firebase Functions

1. Login to Firebase CLI:

```bash
firebase login
```

2. Initialize Firebase in your project:

```bash
firebase init
```

Select your project and choose Functions.

3. Install dependencies:

```bash
cd functions
npm install
```

4. Deploy functions:

```bash
npm run deploy
```

### 7. Configure Firestore Security Rules

Copy the rules from `firestore.rules` and apply them in Firebase Console → Firestore → Rules.

### 8. Configure Storage Security Rules

Copy the rules from `storage.rules` and apply them in Firebase Console → Storage → Rules.

## Supabase Setup

The app uses Supabase for additional database functionality and views.

### 1. Create Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Create a new project
3. Choose a name (e.g., "282-dev-yourname")
4. Generate a strong password
5. Select a region
6. Wait for the project to be created

### 2. Get Project Credentials

1. In your project dashboard, go to Settings → API
2. Copy your project URL and anon/public key
3. Save these for your environment configuration

### 3. Set Up Database Schema

1. Go to SQL Editor in your Supabase dashboard
2. Run the SQL migration files from `supabase/migrations/` in order
3. Alternatively, if you have the Supabase CLI installed:

```bash
supabase link --project-ref your-project-ref
supabase db push
```

### 4. Configure Row Level Security (RLS)

The migrations include RLS policies, but verify they're applied correctly in your Supabase dashboard.

## Third-Party Services

### 1. Weather API

The app uses a weather API for mountain weather information.

1. Sign up for a weather API service (e.g., OpenWeatherMap, WeatherAPI)
2. Get your API key
3. Add it to your `.env` file as `WEATHER_API_KEY`

### 2. Mixpanel Analytics

1. Go to [Mixpanel](https://mixpanel.com/)
2. Create a new project
3. Get your project token
4. Add it to your `.env` file as `MIXPANEL_TOKEN`

### 3. Mapbox

1. Go to [Mapbox](https://mapbox.com/)
2. Create an account and get an access token
3. Add it to your `.env` file as `MAPBOX_TOKEN`

### 4. Sentry (Error Tracking)

1. Go to [Sentry](https://sentry.io/)
2. Create a new Flutter project
3. Get your DSN
4. Update the DSN in `lib/main_development.dart` and `lib/main_production.dart`

### 5. Branch.io (Deep Linking)

1. Go to [Branch.io](https://branch.io/)
2. Create an app
3. Configure deep linking according to Branch documentation
4. The app is already configured to use Branch in the codebase

## Environment Configuration

### 1. Create Environment Files

Copy the example environment file:

```bash
cp .env.example .env.dev
cp .env.example .env.prod
```

### 2. Configure Development Environment

Update `.env.dev` with your development credentials:

```bash
# Weather API
WEATHER_API_KEY=your_weather_api_key

# Analytics
MIXPANEL_TOKEN=your_mixpanel_development_token

# Maps
MAPBOX_TOKEN=your_mapbox_access_token

# Supabase
SUPABASE_URL=your_supabase_project_url
SUPABASE_PUBLISHABLE_KEY=your_supabase_anon_key
```

### 3. Configure Production Environment

Update `.env.prod` with your production credentials (use separate accounts/projects for production).

### 4. Set Active Environment

For development:

```bash
# Use the VS Code task
# Or manually:
cp .env.dev .env
```

## Development Workflow

### 1. Project Structure

```
lib/
├── app.dart                 # Main app widget
├── main_development.dart    # Development entry point
├── main_production.dart     # Production entry point
├── enums/                   # App enumerations
├── extensions/              # Dart extensions
├── helpers/                 # Utility helpers
├── models/                  # Data models
├── repos/                   # Data repositories
├── screens/                 # UI screens
├── services/                # Business logic services
├── support/                 # Theme and constants
└── widgets/                 # Reusable widgets
```

### 2. State Management

The app uses Provider for state management. Key state classes:

- `UserState`: Current user information
- `FlavorState`: App flavor (dev/prod)
- `SettingsState`: User settings

### 3. Services Architecture

Services handle business logic:

- `AuthService`: Authentication with Firebase
- `UserService`: User data management
- `MunroService`: Mountain data and completions
- `PostService`: Social posts
- `WeatherService`: Weather information
- And many more...

### 4. Database Architecture

**Firebase Firestore**: Real-time data

- Users, posts, likes, comments, follows
- Real-time updates and social features

**Supabase PostgreSQL**: Complex queries and views

- Munro data, completions, achievements
- Complex analytics and reporting queries

## Building and Running

### 1. Start Development Environment

First, start both emulator suites:

```bash
# Terminal 1: Start Supabase
supabase start

# Terminal 2: Start Firebase emulators
firebase emulators:start
```

Or use the provided script:

```bash
./scripts/start-dev.sh
```

### 2. Development Build

```bash
# Android
flutter run --flavor development --target lib/main_development.dart

# iOS
flutter run --flavor development --target lib/main_development.dart
```

### 3. Production Build

```bash
# Android
flutter build apk --flavor production --target lib/main_production.dart

# iOS
flutter build ios --flavor production --target lib/main_production.dart
```

### 4. Running Tests

```bash
flutter test
```

### 5. Code Generation

If you modify models or add new services, run:

```bash
flutter packages pub run build_runner build
```

## Production Deployment

For production deployment, you'll need to set up actual Firebase and Supabase projects:

### 1. Create Production Firebase Project

Follow the standard Firebase setup process for production.

### 2. Create Production Supabase Project

Deploy your local database schema to production:

```bash
supabase link --project-ref your-production-project-ref
supabase db push
```

## Contributing Guidelines

### 1. Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex business logic
- Keep functions small and focused

### 2. Git Workflow

1. Create a feature branch:

```bash
git checkout -b feature/your-feature-name
```

2. Make your changes and commit:

```bash
git add .
git commit -m "feat: add your feature description"
```

3. Push to your fork:

```bash
git push origin feature/your-feature-name
```

4. Create a pull request

### 3. Commit Messages

Follow conventional commits:

- `feat:` new features
- `fix:` bug fixes
- `docs:` documentation updates
- `style:` formatting changes
- `refactor:` code refactoring
- `test:` adding tests
- `chore:` maintenance tasks

### 4. Testing

- Write unit tests for services
- Write widget tests for complex UI components
- Test both development and production builds
- Test on both Android and iOS

### 5. Documentation

- Update README.md if needed
- Document new services or significant changes
- Add inline documentation for complex functions

## Troubleshooting

### Common Issues

1. **Build failures**: Make sure all environment files are properly configured
2. **Firebase connection issues**: Verify your `google-services.json` and `GoogleService-Info.plist` files are in the correct locations
3. **Dependency conflicts**: Run `flutter clean && flutter pub get`
4. **iOS signing issues**: Configure your development team in Xcode
5. **Android build issues**: Check your Android SDK and build tools versions

### Getting Help

- Check existing [Issues](https://github.com/alastairrmcneill/282/issues)
- Create a new issue with detailed description
- Include logs and error messages
- Specify your development environment (OS, Flutter version, etc.)

## Security Notes

- Never commit API keys or sensitive credentials
- Use different Firebase projects for development and production
- Configure proper security rules for Firebase services
- Test Row Level Security policies in Supabase
- Use strong passwords for all services

## License

This project is licensed under [LICENSE]. Please review the license before contributing.

---

Thank you for contributing to 282! Your help makes this munro bagging app better for the Scottish hiking community. 🏔️
