# Development Environment Setup

This guide will help you set up your development environment and get the 282 Munro Bagging app running locally. You'll need to create your own development projects for Firebase, Supabase, and other third-party services.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Getting Started](#getting-started)
3. [Required Setup](#required-setup)
4. [Optional Setup](#optional-setup)
5. [Running the App](#running-the-app)

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (>=3.8.1): [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **Visual Studio Code** with Flutter extensions
- **Xcode** (for iOS development, macOS only)
- **Git**
- **Node.js** (for Firebase Functions)
- **Firebase CLI**: `npm install -g firebase-tools`
- **Supabase CLI**: [Installation Guide](https://supabase.com/docs/guides/cli)
- **Docker Desktop** (for Supabase): [Installation Guide](https://docs.docker.com/desktop/)

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

# Required Setup

## Environment Configuration

### 1. Create Configuration Files

Copy the example configuration file:

```bash
cp config/example.json config/dev.json
```

### 2. Configure Development Environment (Required)

Update `config/dev.json` with your required credentials:

```json
{
  "APP_ENV": "dev",
  "WEATHER_API_KEY": "your_weather_api_key",
  "SUPABASE_URL": "your_supabase_project_url",
  "SUPABASE_ANON": "your_supabase_anon_key",
  "MIXPANEL_TOKEN": "your_mixpanel_token",
  "MAPBOX_TOKEN": "your_mapbox_token",
  "SENTRY_DSN": "your_sentry_dsn",
  "IMAGE_PROXY_BASE_URL": ""
}
```

Leave the image_proxy_base_url as blank so that you can load images from firebase. So leave it as `"IMAGE_PROXY_BASE_URL": ""` in the `config/dev.json` file.

### 2. Copy Branch.io Config

Copy the example branch-config.json file. This file is required but the content is optional. See [branch details](#branchio) for more info.

```bash
cp assets/branch-config.json.example assets/branch-config.json
```

**Required fields:**

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON`: Your Supabase anon/public key

**Optional fields:**

- `WEATHER_API_KEY`: Your weather API key
- `MIXPANEL_TOKEN`: Analytics token (can be left empty for development)
- `MAPBOX_TOKEN`: Maps token (can be left empty for development)
- `SENTRY_DSN`: Error tracking DSN (can be left empty for development)

## Firebase Setup

You'll need to create your own Firebase project for development.

### 1. Create Firebase Project and Configure Apps

1. **Create Firebase Project** (if you don't have one):

   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project"
   - Name your project (e.g., "282-dev-yourname")
   - Don't enable Google Analytics
   - Create the project

2. **Add Firebase Apps to Your Project**:

   In your Firebase Console, add both Android and iOS apps:

   **For Development:**

   - **Android App**: Package name `com.alastairrmcneill.TwoEightTwo.dev`
   - **iOS App**: Bundle ID `com.alastairrmcneill.TwoEightTwo.dev`
   - Download `google-services.json` → place in `android/app/src/development/`
   - Download `GoogleService-Info.plist` → place in `ios/config/development/`

   **Note**: Contributors only set up development apps. Production is handled by the project owner.

### 2. Enable Firebase Services

In your Firebase project, enable these services:

#### Authentication

1. Go to Build>Authentication>Sign-in method
2. Enable the following providers:
   - **Email/Password**: Required
   - **Google**: Optional. You'll need to redownload `google-services.json` and replace the one from the step above. More detail found at [Google Sign-In](#google-sign-in)
   - **Apple**: Optional. For iOS (requires Apple Developer account) more info found at [Sign in with Apple](#sign-in-with-apple)
3. Got to Build>Authentication>Settings and enable Blocking Functions. This requires upgrading to a paid plan. This is a pay as you go service and unless something goes wrong it will be free for development

#### Storage

1. Go to Build>Storage
2. Upgrade plan to Blaze if required. This is a pay as you go service and unless something goes wrong it will be free for development
3. Confgiure the Storage
4. Choose any region
5. Start in Test mode

#### Cloud Functions

1. Enable Build>Cloud Functions (will be configured later)

#### Cloud Messaging

1. Go to Run>Cloud Messaging
2. No additional setup needed initially

### 3. Configure Firebase Services

1. Login to Firebase CLI:

```bash
firebase login
```

2. Use your project ID found in your project url eg: https://console.firebase.google.com/u/1/project/{your-project-id}/overview

```bash
firebase use your-project-id
```

3. Deploy configuration:

```bash
firbease deploy
```

Type `y` if prompted by the message:

```
Cloud Storage for Firebase needs an IAM Role to use cross-service rules. Grant the new role?
```

## Supabase Setup

The app uses Supabase for additional database functionality and views.

### 1. Create Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Create a new account and organisation if needed.
3. Create a new project.(If having toruble creating a new project trying logging out and back in.)
4. Choose a name (e.g., "282-dev-yourname")
5. Generate a strong password
6. Select a region
7. Wait for the project to be created

### 2. Link to Firebase Auth

1. In the Supabase dashboard go to Authentication>Sign In/Providers>Third Party Auth
2. Click Add Provider
3. Select Firebase and add your Firebase project id from earlier.

### 3. Get Project Credentials

1. In your project dashboard, go to Settings>API Keys and Create New Keys
2. Click on Connect at the top then Mobile Frameworks then Flutter
3. Copy your project URL and anon/public key
4. Save these for your configuration file

### 3. Set Up Database Schema

1. Login to Supabase through CLI

```bash
supabase login
```

2. Link your project to the Supabase CLI using the id in the project url eg: https://{your-project-ref}.supabase.co

```bash
supabase link --project-ref your-project-ref
```

2. Open Docker Desktop

3. Run migration scripts into db

```bash
supabase db push
```

4. Add the indexes one at a time from `supabase/indexes.sql` through your project dashboard > SQL editor. These cannot be added through the migrations.

5. Insert the `seed.sql` in your project SQL editor.

6. Deploy Supabase functions (optional if wanting to test notification functionality)

```bash
supabase functions deploy
```

7. Create webhooks for each function deployed above. This is optional but required if you want to test notifications:
   - **On User Created Webhook**
     - Table: users
     - Webhook configuration: Supabase Edge Functions
     - Select which edge function to trigger: on-user-created
   - **Repeat for other Edge Functions** (`on-comment-created`, `on-follower-created`, `on-like-created`, `on-notification-created`)

   **Exception:** `on-report-created` and `on-app-feedback-created` are wired via a SQL trigger + `pg_net` (see `supabase/migrations/20260715120000_report_and_feedback_email_triggers.sql`) instead of a Dashboard webhook, since they need to reach out to Resend rather than fan out within Supabase. Skip the Dashboard webhook step for these two and instead see [Report & Feedback Email Notifications](#report--feedback-email-notifications) below.

# Optional Setup

## Weather API

The app uses a weather API for mountain weather information.

1. Sign up for [OpenWeatherMap](https://openweathermap.org/)
2. Go to your profile and API Keys
3. Give it a name and click Generate
4. Add it to your `config/dev.json` file as `WEATHER_API_KEY`
5. Go to Billing Plans and subscirbe to One Call API 3.0. This is a free tier up to 1000 calls a day.

## Report & Feedback Email Notifications

Sends an email via [Resend](https://resend.com/) whenever a row is inserted into `reports` or `app_feedbacks` (i.e. when a user submits a content/user report, or answers an in-app feedback survey). Optional — only needed if you want to test these notifications.

Unlike the other edge functions, `on-report-created` and `on-app-feedback-created` are invoked by a Postgres trigger + `pg_net` (see `supabase/migrations/20260715120000_report_and_feedback_email_triggers.sql`), not a Dashboard Database Webhook. That trigger needs two secrets in Supabase Vault (per project — dev and prod each need their own):

1. Run once in your project's SQL editor:

```sql
select vault.create_secret('<your project's anon/legacy key>', 'edge_function_invoke_key');
select vault.create_secret('https://<your-project-ref>.supabase.co', 'edge_function_base_url');
```

2. Sign up for [Resend](https://resend.com/) and get an API key.

3. Set the edge function secrets:

```bash
supabase secrets set RESEND_API_KEY=your_resend_api_key NOTIFICATION_EMAIL=your_email@example.com --project-ref your-project-ref
```

`FROM_EMAIL` is optional and defaults to `onboarding@resend.dev` (Resend's test sender, no domain verification needed).

## Mixpanel Analytics

This enables tracking of product analytics through the app such as screens visited etc.

1. Go to [Mixpanel](https://mixpanel.com/)
2. Create a new project
3. Get your project token
4. Add it to your `config/dev.json` file as `MIXPANEL_TOKEN`

## Mapbox

Required for maps to render, the app has no other map provider.

1. Go to [Mapbox](https://mapbox.com/)
2. Create an account and get an access token
3. Add it to your `config/dev.json` file as `MAPBOX_TOKEN`

## Sentry

Allows for tracking errors and crashes in the app remotely

1. Go to [Sentry](https://sentry.io/)
2. Create a new Flutter project
3. Get your DSN
4. Add it to your `config/dev.json` file as `SENTRY_DSN`

## Branch.io

Allows for deep linking to be tested

1. Go to [Branch.io](https://www.branch.io/)
2. Setup [Branch for iOS](https://help.branch.io/developers-hub/docs/ios-basic-integration#1-configure-branch-dashboard)
3. Setup [Branch for Android](https://help.branch.io/developers-hub/docs/android-basic-integration#1-configure-branch-dashboard)
4. Get your Live Key [here](https://dashboard.branch.io/account-settings/profile)
5. Copy exmaple `branch-config` file

```bash
   cp assets/branch-config.json.example assets/branch-config.json
```

6. Add your key to the `branchKey` attribute in the file.

## Google Sign-In

If you want to use Google Sign-In in the development app, you'll need to set up OAuth 2.0 client credentials:

1. **Set up OAuth consent screen**:

   - In [Google Cloud Console](https://console.cloud.google.com/), go to APIs & Services → OAuth consent screen
   - Choose "External" user type
   - Fill in required fields (App name, User support email, Developer contact)
   - Add your email to test users during development

2. **Create OAuth 2.0 Client IDs**:

   - Go to APIs & Services → Credentials
   - Click "Create Credentials" → "OAuth 2.0 Client IDs"
   - Create **two separate client IDs**:

   **For Android Development:**

   - Application type: Android
   - Package name: `com.alastairrmcneill.TwoEightTwo.dev`
   - SHA-1 certificate fingerprint: Get from your debug keystore

   **For iOS:**

   - Application type: iOS
   - Bundle ID: `com.alastairrmcneill.TwoEightTwo.dev`

3. **Download client configuration files**:

   - For each OAuth client, download the JSON configuration file
   - Rename them to match the pattern: `client_secret_[CLIENT_ID].apps.googleusercontent.com.json`
   - Place the two files in: `android/app/`

4. **Get SHA-1 fingerprints**:

   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

**Note**: Without these client secret files, Google Sign-In will not work. You can still use email/password authentication and Apple Sign-In without them.

## Sign in with Apple

If you want to use Apple Sign-In in the development app, you'll need to do the following steps:

1. **Apple Developer Account Requirements**:

   - You need an active Apple Developer Program membership ($99/year)
   - Access to Apple Developer Console

2. **Configure App ID and Capabilities**:

   - Go to [Apple Developer Console](https://developer.apple.com/account/)
   - Navigate to Certificates, Identifiers & Profiles → Identifiers
   - Find or create your App ID: `com.alastairrmcneill.TwoEightTwo.dev`
   - Edit the App ID and enable "Sign In with Apple" capability
   - Configure as "Enable as a primary App ID"

**Important Notes**:

- Sign in with Apple only works on iOS 13.0+ and macOS 10.15+
- Testing requires a physical device or iOS Simulator (not Android)

## Marketing Website

The `website/` folder is a separate Astro project (the 282app.uk marketing & SEO site) and isn't required to run the Flutter app. See [website/README.md](website/README.md) for its own setup and dev server instructions.

# Running the App

### Development flavor

```bash
flutter run --flavor development --dart-define-from-file=config/dev.json
```

## Running Tests

```bash
flutter test
```

---

**Next Steps**: Once your environment is set up, check out the [Developer Workflow Guide](DEVELOPER_WORKFLOW.md) to understand the project structure and how to implement features.

**Need Help?**

- Check existing [Issues](https://github.com/alastairrmcneill/282/issues)
- Create a new issue with detailed description
- Include logs and error messages
- Specify your development environment (OS, Flutter version, etc.)
